#!/usr/bin/env python3
"""Fetch Google Scholar citation counts and update _data/citations.yml.

Uses the `scholarly` library with free proxy rotation to look up each
paper by title and read its `num_citations`. Resilient to Scholar's
intermittent refusals via three layers:

1. Each lookup is retried with exponential backoff before being declared
   dead.
2. The YAML carries a `titles` map of last-known per-title counts; if a
   lookup still fails after retries, the last-known value is reused so
   group totals don't regress.
3. The script always exits 0 unless the file write itself fails. Partial
   failures are surfaced as GitHub Actions `::warning::` lines so CI
   stays green but the failure is still visible in the run summary.
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

SOURCES: dict[str, list[str]] = {
    "position_paper": [
        "Towards evaluation guidelines for empirical studies involving llms",
    ],
    "arxiv": [
        "Guidelines for empirical studies in software engineering involving large language models",
        "Evaluation guidelines for empirical studies in software engineering involving llms",
    ],
}

DATA_FILE = Path(__file__).resolve().parent.parent / "_data" / "citations.yml"

RETRY_ATTEMPTS = 3
RETRY_BASE_DELAY = 5  # seconds; doubles each retry
INTER_TITLE_MIN = 10  # seconds; randomized gap between consecutive title lookups
INTER_TITLE_MAX = 30


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


def fetch_count(title: str) -> int | None:
    for attempt in range(1, RETRY_ATTEMPTS + 1):
        try:
            pub = scholarly.search_single_pub(title)
        except Exception as e:
            log(f"scholarly attempt {attempt}/{RETRY_ATTEMPTS} failed for '{title}': {e}")
            if attempt < RETRY_ATTEMPTS:
                delay = RETRY_BASE_DELAY * (2 ** (attempt - 1))
                log(f"retrying in {delay}s")
                time.sleep(delay)
            continue
        n = pub.get("num_citations") if pub else None
        if n is None:
            log(f"scholarly: no num_citations for '{title}'")
        return n
    return None


def load_existing() -> dict:
    if not DATA_FILE.exists():
        return {}
    with DATA_FILE.open() as f:
        return yaml.safe_load(f) or {}


def main() -> int:
    setup_proxy()

    previous = load_existing()
    previous_titles: dict[str, int] = previous.get("titles") or {}

    title_counts: dict[str, int] = {}
    group_counts: dict[str, int] = {}
    fallbacks: list[str] = []
    skipped: list[str] = []
    successes = 0
    first_title = True

    for key, titles in SOURCES.items():
        subtotal = 0
        complete = True
        for title in titles:
            if not first_title:
                delay = random.uniform(INTER_TITLE_MIN, INTER_TITLE_MAX)
                log(f"sleeping {delay:.1f}s before next title")
                time.sleep(delay)
            first_title = False
            n = fetch_count(title)
            if n is None:
                fallback = previous_titles.get(title)
                if fallback is None:
                    warn(f"{key}: '{title}' fetch failed and no previous value available; group total will be incomplete")
                    skipped.append(title)
                    complete = False
                    continue
                warn(f"{key}: '{title}' fetch failed, reusing previous value {fallback}")
                title_counts[title] = fallback
                subtotal += fallback
                fallbacks.append(title)
            else:
                log(f"{key} [{title!r}]: {n}")
                title_counts[title] = n
                subtotal += n
                successes += 1

        if complete:
            group_counts[key] = subtotal
        elif key in previous and isinstance(previous[key], int):
            warn(f"{key}: keeping previous group total {previous[key]} due to incomplete fetch")
            group_counts[key] = previous[key]
        else:
            group_counts[key] = subtotal  # best-effort partial

    if successes == 0 and not previous_titles:
        warn("no titles fetched and no previous data to fall back to; leaving file unchanged")
        return 0

    out: dict = dict(group_counts)
    out["titles"] = title_counts
    out["total"] = sum(group_counts.values())
    if successes > 0:
        out["updated"] = date.today().isoformat()
    elif previous.get("updated"):
        out["updated"] = previous["updated"]
        warn("no fresh fetches this run; preserving previous 'updated' date")

    with DATA_FILE.open("w") as f:
        yaml.safe_dump(out, f, default_flow_style=False, sort_keys=True)

    parts = [f"total={out['total']}", f"updated={out['updated']}"]
    if fallbacks:
        parts.append(f"fallbacks={len(fallbacks)}")
    if skipped:
        parts.append(f"skipped={len(skipped)}")
    log(" ".join(parts))
    return 0


if __name__ == "__main__":
    sys.exit(main())
