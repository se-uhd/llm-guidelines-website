#!/usr/bin/env python3
"""Checks for generate-summary-tables.py.

Validates the generator against the live paper submodule (shape, link
format, determinism) and against synthetic inputs that must be rejected.
Two content assertions pin the cell severities whose hand-curated copies
drifted before the generator existed (Design x Usage and Open LLM x
Benchmarks, both **should** as of paper version 2026.06); update them if
the paper legitimately changes those severities.

Run from anywhere: paths resolve relative to this file.
"""

import shutil
import subprocess
import sys
import tempfile
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent.parent
GENERATOR = ROOT / "scripts" / "generate-summary-tables.py"
SHOULD_SPAN = '<span class="marker-should">●</span>'

failures = []


def check(name, condition, detail=""):
    if condition:
        print(f"PASS  {name}")
    else:
        print(f"FAIL  {name}  {detail}")
        failures.append(name)


def run(args, root=ROOT):
    return subprocess.run(
        [sys.executable, str(GENERATOR), "--root", str(root), *args],
        capture_output=True,
        text=True,
    )


def cells(row_line):
    return [c.strip() for c in row_line.split("|")[1:-1]]


def main():
    res = run(["--check"])
    check("check_mode_passes", res.returncode == 0, res.stderr.strip())

    res = run(["--website-matrix", "-"])
    lines = res.stdout.strip().splitlines()
    check("website_matrix_runs", res.returncode == 0, res.stderr.strip())
    check("website_matrix_has_10_lines", len(lines) == 10, f"got {len(lines)}")
    check(
        "website_matrix_header_links_study_types",
        lines and lines[0].count('href="/study-types/') == 7,
    )
    design = next((l for l in lines if "/guidelines/design/" in l), "")
    check(
        "design_x_usage_is_should",
        design and cells(design)[5] == SHOULD_SPAN,
        f"row: {design}",
    )
    open_llm = next((l for l in lines if "/guidelines/open-llm/" in l), "")
    check(
        "open_llm_x_benchmarks_is_should",
        open_llm and cells(open_llm)[7] == SHOULD_SPAN,
        f"row: {open_llm}",
    )
    check(
        "open_llm_subjects_usage_na",
        open_llm and cells(open_llm)[4] == "--" and cells(open_llm)[5] == "--",
    )

    res = run(["--summary-table", "-"])
    slines = res.stdout.strip().splitlines()
    check("summary_table_runs", res.returncode == 0, res.stderr.strip())
    check("summary_table_has_8_rows", len(slines) == 10, f"got {len(slines)}")
    hv = next((l for l in slines if "/guidelines/human-validation/" in l), "")
    check(
        "human_validation_has_replacement_lines",
        hv.count("replace humans in research tasks") == 2,
        f"row: {hv[:120]}",
    )

    res = run(["--skill-matrix", "-"])
    klines = res.stdout.splitlines()
    check("skill_matrix_runs", res.returncode == 0, res.stderr.strip())
    check(
        "skill_matrix_relative_links",
        any("(./guidelines/declare-usage.md)" in l for l in klines)
        and any("(./study-types/annotators.md)" in l for l in klines),
    )
    check(
        "skill_matrix_uses_words",
        any("| n/a |" in l for l in klines) and any("| must |" in l for l in klines),
    )

    first = run(["--website-matrix", "-", "--summary-table", "-", "--skill-matrix", "-"])
    second = run(["--website-matrix", "-", "--summary-table", "-", "--skill-matrix", "-"])
    check("deterministic_output", first.stdout == second.stdout)

    with tempfile.TemporaryDirectory() as tmp:
        fake = Path(tmp)
        (fake / "llm-guidelines-paper" / "_summary").mkdir(parents=True)
        shutil.copy(ROOT / "short-titles.sh", fake / "short-titles.sh")
        real_summary = ROOT / "llm-guidelines-paper" / "_summary"

        matrix = (real_summary / "matrix.tex").read_text(encoding="utf-8")
        (fake / "llm-guidelines-paper" / "_summary" / "rationale-recommendations.tex").write_text(
            (real_summary / "rationale-recommendations.tex").read_text(encoding="utf-8"),
            encoding="utf-8",
        )

        bad_cell = matrix.replace("\\iconM %", "\\iconX %", 1)
        (fake / "llm-guidelines-paper" / "_summary" / "matrix.tex").write_text(
            bad_cell, encoding="utf-8"
        )
        res = run(["--check"], root=fake)
        check("rejects_unknown_cell_token", res.returncode != 0)

        dropped_row = matrix.replace("\\hyperref[sec:report-session-traces]{Traces}", "Traces", 1)
        (fake / "llm-guidelines-paper" / "_summary" / "matrix.tex").write_text(
            dropped_row, encoding="utf-8"
        )
        res = run(["--check"], root=fake)
        check("rejects_wrong_row_shape", res.returncode != 0)

        (fake / "llm-guidelines-paper" / "_summary" / "matrix.tex").write_text(
            matrix, encoding="utf-8"
        )
        rationale = (real_summary / "rationale-recommendations.tex").read_text(encoding="utf-8")
        bad_macro = rationale.replace(
            "Transparency enables", "\\unknowncmd{Transparency} enables", 1
        )
        (fake / "llm-guidelines-paper" / "_summary" / "rationale-recommendations.tex").write_text(
            bad_macro, encoding="utf-8"
        )
        res = run(["--check"], root=fake)
        check("rejects_unknown_latex_command", res.returncode != 0)

    print()
    if failures:
        print(f"{len(failures)} check(s) failed: {', '.join(failures)}")
        return 1
    print("All generator checks passed.")
    return 0


if __name__ == "__main__":
    sys.exit(main())
