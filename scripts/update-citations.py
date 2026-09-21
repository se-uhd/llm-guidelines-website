#!/usr/bin/env python3
"""Fetch Google Scholar citation counts and update _data/citations.yml.

Counts are read straight from each work's Scholar "cited by" cluster page,
the same pages the homepage links from `index.md`. For every source we hit
`/scholar?cites=<cluster-ids>` via the `scholarly` library and read the
"About N results" total. A comma-joined cluster value is a merged cited-by
page, which Scholar deduplicates across the listed clusters; that is how the
preprint's two renamed versions collapse into one count.

This replaces an earlier title-search approach that summed per-title
`num_citations`. Title matching resolved to the wrong record when the titles
drifted, and summing two clusters of the same paper double-counted the citing
works that Scholar's merged page deduplicates. Pinning to cluster IDs removes
both failure modes.

Resilience:

1. Each cluster is read up to `SAMPLES` times and the highest reading wins.
   The "About N results" line is an estimate, and Google documents it as
   unstable between requests. In practice Scholar spends stretches of several
   minutes reporting a low, erratic value for a cited-by page (readings of
   13-27 for a page whose settled value is 48), so a single reading can land
   far below the true count. A reading is never too high, so the maximum is
   the best estimator. Sampling stops as soon as a reading reaches the
   last-known count, which is the usual case and keeps the job to two
   requests.
2. A plausibility guard rejects a value that drops or jumps implausibly
   against the last-known count, reusing the previous value so group totals
   don't regress. After sampling this catches a real decline, not a bad
   reading, but the jump half still caps an estimate that overshoots.
3. If a lookup still fails, the last-known per-source value in the YAML is
   reused.
4. The script always exits 0 unless the file write itself fails. Partial
   failures are surfaced as GitHub Actions `::warning::` lines so CI stays
   green but the failure is still visible in the run summary.
"""

from __future__ import annotations

import os
import random
import sys
import time
from datetime import date
from pathlib import Path

import yaml
from scholarly import ProxyGenerator, scholarly

# Keys are the group names written to _data/citations.yml and summed into
# `total`. Values are Google Scholar cluster IDs for each work's "cited by"
# page; keep them in sync with the `cites=` links in index.md. A comma-joined
# value is a merged cited-by page (deduplicated across the listed clusters).
SOURCES: dict[str, str] = {
    "position_paper": "10292768743544802913",
    "arxiv": "16126919270545554010,11554931200167593565",
}

DATA_FILE = Path(__file__).resolve().parent.parent / "_data" / "citations.yml"

SAMPLES = 5  # readings per cluster before giving up on a fresh value
REQUEST_MIN = 75  # seconds; randomized gap between consecutive requests
REQUEST_MAX = 105

# Plausibility band for a fresh count relative to the last-known value. These
# papers are recent, so their weekly citation growth is small and monotonic; a
# large jump or any real drop almost always means Scholar served a bad page.
GUARD_MIN_RATIO = 0.7  # reject a drop below 70% of the previous value
GUARD_MAX_RATIO = 1.5  # reject a jump above 150% of the previous value ...
GUARD_MAX_SLACK = 10  # ... plus this absolute slack, so small values can still grow


def log(msg: str) -> None:
    print(msg, flush=True)


def warn(msg: str) -> None:
    """Surface a non-fatal problem in the GitHub Actions run summary."""
    print(f"::warning::{msg}", flush=True)


def setup_proxy() -> None:
    if os.environ.get("SKIP_PROXY_SETUP") == "1":
        log("scholarly: SKIP_PROXY_SETUP=1, using direct requests")
        return
    try:
        pg = ProxyGenerator()
        if pg.FreeProxies():
            scholarly.use_proxy(pg)
            log("scholarly: free proxy rotation enabled")
        else:
            log("scholarly: no free proxy available, using direct requests")
    except Exception as e:
        log(f"scholarly: proxy setup raised {type(e).__name__}: {e}, falling back to direct requests")


def fetch_once(cluster: str) -> int | None:
    """Return one 'cited by' reading for a cluster (or merged clusters), or None."""
    try:
        # A blocked/captcha page yields no parseable count (None) or a bogus 0.
        return scholarly.search_citedby(cluster).total_results or None
    except Exception as e:
        log(f"scholarly failed for cites={cluster}: {type(e).__name__}: {e}")
        return None


def implausible(new: int, prev: int | None) -> str | None:
    """Return a reason string if `new` is an implausible move from `prev`, else None."""
    if prev is None or prev <= 0:
        return None  # no usable baseline; accept the fresh value
    if new < prev * GUARD_MIN_RATIO:
        return f"dropped from {prev} to {new}"
    if new > prev * GUARD_MAX_RATIO + GUARD_MAX_SLACK:
        return f"jumped from {prev} to {new}"
    return None


def load_existing() -> dict:
    if not DATA_FILE.exists():
        return {}
    with DATA_FILE.open() as f:
        return yaml.safe_load(f) or {}


def main() -> int:
    setup_proxy()

    previous = load_existing()
    prevs = {k: (previous.get(k) if isinstance(previous.get(k), int) else None) for k in SOURCES}

    # Read every cluster once per round, dropping a cluster as soon as one of
    # its readings reaches the last-known count. Rounds interleave the clusters
    # so they share the waiting rather than each paying for it.
    readings: dict[str, list[int]] = {key: [] for key in SOURCES}
    pending = dict(SOURCES)
    first = True

    for round_no in range(1, SAMPLES + 1):
        for key in list(pending):
            if not first:
                delay = random.uniform(REQUEST_MIN, REQUEST_MAX)
                log(f"sleeping {delay:.1f}s before next reading")
                time.sleep(delay)
            first = False

            cluster = pending[key]
            n = fetch_once(cluster)
            if n is None:
                log(f"{key} reading {round_no}/{SAMPLES} [cites={cluster}]: none (block page or error)")
                continue

            readings[key].append(n)
            log(f"{key} reading {round_no}/{SAMPLES} [cites={cluster}]: {n}")
            if prevs[key] is not None and n >= prevs[key]:
                del pending[key]  # a healthy reading never undershoots; stop here
        if not pending:
            break

    group_counts: dict[str, int] = {}
    fallbacks: list[str] = []
    skipped: list[str] = []
    successes = 0

    for key in SOURCES:
        prev = prevs[key]
        samples = readings[key]
        n = max(samples) if samples else None
        if samples:
            log(f"{key}: readings={samples} -> {n}")

        reason = None if n is None else implausible(n, prev)
        if n is not None and reason:
            warn(f"{key}: best of {len(samples)} readings {reason}; rejecting as implausible and reusing previous")
            n = None

        if n is None:
            if prev is None:
                warn(f"{key}: no usable reading and no previous value available; group total will be incomplete")
                skipped.append(key)
                continue
            warn(f"{key}: reusing previous value {prev}")
            group_counts[key] = prev
            fallbacks.append(key)
        else:
            group_counts[key] = n
            successes += 1

    if successes == 0 and not any(isinstance(previous.get(k), int) for k in SOURCES):
        warn("no counts fetched and no previous data to fall back to; leaving file unchanged")
        return 0

    out: dict = dict(group_counts)
    out["total"] = sum(group_counts.values())
    if successes > 0:
        out["updated"] = date.today().isoformat()
    elif previous.get("updated"):
        out["updated"] = previous["updated"]
        warn("no fresh fetches this run; preserving previous 'updated' date")

    with DATA_FILE.open("w") as f:
        yaml.safe_dump(out, f, default_flow_style=False, sort_keys=True)

    parts = [f"total={out['total']}", f"updated={out.get('updated')}"]
    if fallbacks:
        parts.append(f"fallbacks={len(fallbacks)}")
    if skipped:
        parts.append(f"skipped={len(skipped)}")
    log(" ".join(parts))
    return 0


if __name__ == "__main__":
    sys.exit(main())
