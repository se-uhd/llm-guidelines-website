#!/usr/bin/env python3
"""Fetch Google Scholar citation counts and update _data/citations.yml.

Uses the `scholarly` library with free proxy rotation to look up each
paper by title and read its `num_citations`. Any fetch failure exits
non-zero so the workflow run turns red and the reason is visible in the
log. On failure the YAML is left untouched so the site keeps rendering
the last-known number.
"""

from __future__ import annotations

import os
import sys
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


def log(msg: str) -> None:
    print(msg, flush=True)


def setup_proxy() -> None:
    if os.environ.get("SKIP_PROXY_SETUP") == "1":
        log("scholarly: SKIP_PROXY_SETUP=1, using direct requests")
        return
    pg = ProxyGenerator()
    if pg.FreeProxies():
        scholarly.use_proxy(pg)
        log("scholarly: free proxy rotation enabled")
    else:
        log("scholarly: no free proxy available, using direct requests")


def fetch_count(title: str) -> int | None:
    try:
        pub = scholarly.search_single_pub(title)
    except Exception as e:
        log(f"scholarly lookup failed for '{title}': {e}")
        return None
    n = pub.get("num_citations") if pub else None
    if n is None:
        log(f"scholarly: no num_citations for '{title}'")
    return n


def main() -> int:
    setup_proxy()

    counts: dict = {}
    for key, titles in SOURCES.items():
        subtotal = 0
        for title in titles:
            n = fetch_count(title)
            if n is None:
                log(f"{key}: fetch failed for '{title}', leaving _data/citations.yml unchanged")
                return 2
            log(f"{key} [{title!r}]: {n}")
            subtotal += n
        counts[key] = subtotal

    counts["total"] = sum(counts.values())
    counts["updated"] = date.today().isoformat()

    with DATA_FILE.open("w") as f:
        yaml.safe_dump(counts, f, default_flow_style=False, sort_keys=True)

    log(f"total={counts['total']} updated={counts['updated']}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
