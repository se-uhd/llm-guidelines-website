#!/usr/bin/env python3
"""Fetch Google Scholar citation counts and update _data/citations.yml.

Uses the `scholarly` library with free proxy rotation to look up each
paper by title and read its `num_citations`. Any fetch failure exits
non-zero so the workflow run turns red and the reason is visible in the
log. On failure the YAML is left untouched so the site keeps rendering
the last-known number.
"""

from __future__ import annotations

import sys
from datetime import date
from pathlib import Path

import yaml
from scholarly import ProxyGenerator, scholarly

SOURCES: dict[str, str] = {
    "position_paper": "Towards Evaluation Guidelines for Empirical Studies involving LLMs",
    "arxiv": "Guidelines for Empirical Studies in Software Engineering involving Large Language Models",
}

DATA_FILE = Path(__file__).resolve().parent.parent / "_data" / "citations.yml"


def log(msg: str) -> None:
    print(msg, flush=True)


def setup_proxy() -> None:
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
    for key, title in SOURCES.items():
        n = fetch_count(title)
        if n is None:
            log(f"{key}: fetch failed, leaving _data/citations.yml unchanged")
            return 2
        counts[key] = n
        log(f"{key}: {n}")

    counts["total"] = counts["position_paper"] + counts["arxiv"]
    counts["updated"] = date.today().isoformat()

    with DATA_FILE.open("w") as f:
        yaml.safe_dump(counts, f, default_flow_style=False, sort_keys=True)

    log(f"total={counts['total']} updated={counts['updated']}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
