#!/usr/bin/env python3
"""Fetch Google Scholar citation counts and update _data/citations.yml.

Preserves the previous value whenever a fetch fails or Scholar returns a
CAPTCHA. The `updated` date only advances when every source page was
scraped successfully, so the displayed date always reflects a fully fresh
snapshot.
"""

from __future__ import annotations

import re
import sys
import urllib.error
import urllib.request
from datetime import date
from pathlib import Path

import yaml

URLS = {
    "position_paper": "https://scholar.google.com/scholar?oi=bibs&hl=en&cites=10292768743544802913&as_sdt=5",
    "arxiv": "https://scholar.google.com/scholar?oi=bibs&hl=en&cites=16126919270545554010,11554931200167593565&as_sdt=5",
}

USER_AGENT = (
    "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 "
    "(KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36"
)

DATA_FILE = Path(__file__).resolve().parent.parent / "_data" / "citations.yml"

RESULT_COUNT_RE = re.compile(r"About\s+([\d,]+)\s+results?", re.IGNORECASE)
FALLBACK_COUNT_RE = re.compile(r"([\d,]+)\s+results?\s*\(", re.IGNORECASE)


def fetch_count(url: str) -> int | None:
    req = urllib.request.Request(
        url,
        headers={
            "User-Agent": USER_AGENT,
            "Accept-Language": "en-US,en;q=0.9",
        },
    )
    try:
        with urllib.request.urlopen(req, timeout=30) as resp:
            html = resp.read().decode("utf-8", errors="replace")
    except (urllib.error.URLError, TimeoutError) as e:
        print(f"fetch failed for {url}: {e}", file=sys.stderr)
        return None

    lowered = html.lower()
    if "not a robot" in lowered or "unusual traffic" in lowered:
        print(f"captcha returned for {url}", file=sys.stderr)
        return None

    for pattern in (RESULT_COUNT_RE, FALLBACK_COUNT_RE):
        m = pattern.search(html)
        if m:
            return int(m.group(1).replace(",", ""))

    print(f"no result count found in {url}", file=sys.stderr)
    return None


def main() -> int:
    existing: dict = {}
    if DATA_FILE.exists():
        with DATA_FILE.open() as f:
            existing = yaml.safe_load(f) or {}

    counts: dict = {}
    all_fresh = True
    for key, url in URLS.items():
        n = fetch_count(url)
        if n is None:
            all_fresh = False
            if key in existing:
                counts[key] = existing[key]
                print(f"keeping last known {key}={existing[key]}", file=sys.stderr)
            else:
                print(f"no previous value for {key}, aborting", file=sys.stderr)
                return 1
        else:
            counts[key] = n

    counts["total"] = counts["position_paper"] + counts["arxiv"]
    counts["updated"] = (
        date.today().isoformat()
        if all_fresh
        else existing.get("updated", date.today().isoformat())
    )

    with DATA_FILE.open("w") as f:
        yaml.safe_dump(counts, f, default_flow_style=False, sort_keys=True)
    return 0


if __name__ == "__main__":
    sys.exit(main())
