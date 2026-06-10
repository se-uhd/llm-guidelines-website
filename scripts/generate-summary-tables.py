#!/usr/bin/env python3
"""Generate the paper-derived summary tables from the paper submodule.

The paper repo's ``_summary/matrix.tex`` (guideline-by-study-type
applicability) and ``_summary/rationale-recommendations.tex`` (per-guideline
rationale and core recommendations) are the authoritative sources for three
rendered surfaces that were previously hand-maintained and prone to drift:

- the "Guidelines by Study Type" table on the website's guidelines index
  (``--website-matrix``, substituted for the ``<!-- MATRIX -->`` placeholder
  in ``guidelines/_sources/00_header.md``),
- the table on the website's summary page (``--summary-table``, substituted
  for the ``<!-- TABLE -->`` placeholder in ``summary/_sources/00_header.md``),
- the skill bundle's ``references/matrix.md`` (``--skill-matrix``, a
  standalone page emitted by ``generate-skill.sh``).

The parser is deliberately strict: any unexpected token, count, label, or
LaTeX command aborts with a non-zero exit so that a reshape of the paper
tables fails the build instead of silently producing wrong pages. Slugs come
from ``short-titles.sh``, the same mapping the website and skill pipelines
use, so all three surfaces stay link-compatible.

Output paths take ``-`` for stdout. ``--check`` parses and validates without
writing anything.
"""

import argparse
import re
import sys
from pathlib import Path

N_GUIDELINES = 8
N_STUDY_TYPES = 7

MUST, SHOULD, NA = "M", "S", "NA"

WEBSITE_MUST = "●"
WEBSITE_SHOULD = '<span class="marker-should">●</span>'
WEBSITE_NA = "--"


class GenerationError(Exception):
    pass


def strip_comments(text):
    """Remove unescaped % comments, line-wise."""
    out = []
    for line in text.splitlines():
        m = re.search(r"(?<!\\)%", line)
        out.append(line[: m.start()] if m else line)
    return "\n".join(out)


def split_unescaped(text, sep):
    return re.split(r"(?<!\\)" + re.escape(sep), text)


def latex_to_md(text, context):
    """Convert the small LaTeX subset used in the summary-table cells.

    Fails on anything outside that subset so new macros in the paper
    surface as build errors rather than corrupted output.
    """
    s = text
    s = re.sub(r"\\emph\{([^{}]*)\}", r"*\1*", s)
    s = re.sub(r"\\textit\{([^{}]*)\}", r"*\1*", s)
    s = s.replace("``", "“").replace("''", "”")
    for esc, plain in (("\\&", "&"), ("\\%", "%"), ("\\_", "_"), ("\\#", "#"), ("\\$", "$")):
        s = s.replace(esc, plain)
    s = s.replace("~", " ")
    leftover = re.search(r"\\[A-Za-z@]+", s)
    if leftover:
        raise GenerationError(
            f"{context}: unhandled LaTeX command '{leftover.group(0)}' in: {text.strip()!r}"
        )
    if "{" in s or "}" in s:
        raise GenerationError(f"{context}: unbalanced or unhandled braces in: {text.strip()!r}")
    return re.sub(r"\s+", " ", s).strip()


def slugify(title):
    s = title.lower()
    s = re.sub(r"[^a-z0-9 -]", "", s)
    s = re.sub(r"\s+", "-", s)
    s = re.sub(r"-{2,}", "-", s)
    return s.strip("-")


def load_short_titles(path):
    """Parse the case-statement mapping in short-titles.sh."""
    pairs = re.findall(r'"([^"]+)"\)\s+echo "([^"]+)" ;;', path.read_text(encoding="utf-8"))
    if not pairs:
        raise GenerationError(f"{path}: no short-title mappings found")
    return dict(pairs)


def parse_cell(cell, context):
    body = cell.strip()
    if "\\iconM" in body:
        return MUST
    if "\\iconS" in body:
        return SHOULD
    if body == "--":
        return NA
    raise GenerationError(f"{context}: unrecognized cell content: {cell.strip()!r}")


def parse_matrix(path):
    """Return (column_labels, [(row_label, [cells])]) from matrix.tex."""
    text = strip_comments(path.read_text(encoding="utf-8"))
    if "\\midrule" not in text or "\\bottomrule" not in text:
        raise GenerationError(f"{path}: expected \\midrule and \\bottomrule")
    header, body = text.split("\\midrule", 1)
    body = body.split("\\bottomrule", 1)[0]

    columns = re.findall(r"\\rot\{\\hyperref\[[^\]]+\]\{([^{}]+)\}\}", header)
    if len(columns) != N_STUDY_TYPES:
        raise GenerationError(
            f"{path}: expected {N_STUDY_TYPES} study-type columns, found {len(columns)}: {columns}"
        )

    rows = []
    for chunk in split_unescaped(body, "\\\\"):
        if not chunk.strip():
            continue
        label_match = re.search(r"\\hyperref\[[^\]]+\]\{([^{}]+)\}", chunk)
        if not label_match:
            raise GenerationError(f"{path}: row without \\hyperref label: {chunk.strip()[:60]!r}")
        label = label_match.group(1).strip()
        cells = split_unescaped(chunk, "&")[1:]
        if len(cells) != N_STUDY_TYPES:
            raise GenerationError(
                f"{path}: row '{label}' has {len(cells)} cells, expected {N_STUDY_TYPES}"
            )
        rows.append((label, [parse_cell(c, f"{path} row '{label}'") for c in cells]))

    if len(rows) != N_GUIDELINES:
        raise GenerationError(
            f"{path}: expected {N_GUIDELINES} guideline rows, found {len(rows)}: "
            f"{[r[0] for r in rows]}"
        )
    return columns, rows


def parse_rationale(path):
    """Return [(short_title, rationale, [(severity, text)])] from the table."""
    text = strip_comments(path.read_text(encoding="utf-8"))
    if "\\midrule" not in text or "\\bottomrule" not in text:
        raise GenerationError(f"{path}: expected \\midrule and \\bottomrule")
    body = text.split("\\midrule", 1)[1].split("\\bottomrule", 1)[0]
    body = body.replace("\\addlinespace", "")

    rows = []
    for chunk in split_unescaped(body, "\\\\"):
        if not chunk.strip():
            continue
        parts = split_unescaped(chunk, "&")
        if len(parts) != 3:
            raise GenerationError(
                f"{path}: row does not have 3 columns: {chunk.strip()[:60]!r}"
            )
        label = latex_to_md(parts[0], str(path))
        rationale = latex_to_md(parts[1], f"{path} row '{label}'")
        recs = []
        for seg in split_unescaped(parts[2], "\\newline"):
            seg = seg.strip()
            if not seg:
                continue
            if seg.startswith("\\iconM"):
                severity, rest = MUST, seg[len("\\iconM"):]
            elif seg.startswith("\\iconS"):
                severity, rest = SHOULD, seg[len("\\iconS"):]
            else:
                raise GenerationError(
                    f"{path} row '{label}': recommendation line lacks \\iconM/\\iconS: {seg[:60]!r}"
                )
            recs.append((severity, latex_to_md(rest, f"{path} row '{label}'")))
        if not rationale or not recs:
            raise GenerationError(f"{path} row '{label}': empty rationale or recommendations")
        rows.append((label, rationale, recs))

    if len(rows) != N_GUIDELINES:
        raise GenerationError(
            f"{path}: expected {N_GUIDELINES} rows, found {len(rows)}: {[r[0] for r in rows]}"
        )
    return rows


def validate(columns, matrix_rows, rationale_rows, short_titles):
    known_shorts = set(short_titles.values())
    for label in columns + [r[0] for r in matrix_rows]:
        if label not in known_shorts:
            raise GenerationError(
                f"label '{label}' is not a short title in short-titles.sh; "
                "matrix.tex and short-titles.sh disagree"
            )
        if not slugify(label):
            raise GenerationError(f"label '{label}' produces an empty slug")
    matrix_order = [r[0] for r in matrix_rows]
    rationale_order = [r[0] for r in rationale_rows]
    if matrix_order != rationale_order:
        raise GenerationError(
            "guideline order differs between matrix.tex and rationale-recommendations.tex: "
            f"{matrix_order} vs {rationale_order}"
        )


def website_cell(value):
    return {MUST: WEBSITE_MUST, SHOULD: WEBSITE_SHOULD, NA: WEBSITE_NA}[value]


def render_website_matrix(columns, rows):
    head = "| | " + " | ".join(
        f'<a href="/study-types/{slugify(c)}/">{c}</a>' for c in columns
    ) + " |"
    sep = "|---|" + ":---:|" * N_STUDY_TYPES
    lines = [head, sep]
    for label, cells in rows:
        link = f'<a href="/guidelines/{slugify(label)}/">{label}</a>'
        lines.append("| " + link + " | " + " | ".join(website_cell(c) for c in cells) + " |")
    return "\n".join(lines) + "\n"


def render_summary_table(rationale_rows):
    lines = ["| Guideline | Rationale | Core Recommendations |", "|---|---|---|"]
    for label, rationale, recs in rationale_rows:
        rec_md = "<br/>".join(
            f"{WEBSITE_MUST if sev == MUST else WEBSITE_SHOULD} {text}" for sev, text in recs
        )
        lines.append(f"| [{label}](/guidelines/{slugify(label)}/) | {rationale} | {rec_md} |")
    return "\n".join(lines) + "\n"


def render_skill_matrix(columns, rows):
    intro = (
        "# Guidelines by Study Type\n"
        "\n"
        "Applicability of the eight guidelines to the seven study types: "
        "**must** = the guideline's core recommendations must be followed for "
        "this study type, **should** = they should be followed, n/a = the "
        "guideline is typically not applicable to this study type. Each "
        "guideline's study-type-specific guidance is detailed in the *Study "
        "Types* section of the guideline file.\n"
        "\n"
    )
    word = {MUST: "must", SHOULD: "should", NA: "n/a"}
    head = "| Guideline | " + " | ".join(
        f"[{c}](./study-types/{slugify(c)}.md)" for c in columns
    ) + " |"
    sep = "|---|" + "---|" * N_STUDY_TYPES
    lines = [head, sep]
    for label, cells in rows:
        link = f"[{label}](./guidelines/{slugify(label)}.md)"
        lines.append("| " + link + " | " + " | ".join(word[c] for c in cells) + " |")
    return intro + "\n".join(lines) + "\n"


def write_output(content, dest):
    if dest == "-":
        sys.stdout.write(content)
    else:
        Path(dest).write_text(content, encoding="utf-8")


def main():
    parser = argparse.ArgumentParser(description=__doc__.splitlines()[0])
    parser.add_argument(
        "--root",
        default=str(Path(__file__).resolve().parent.parent),
        help="website repo root (default: the script's parent repo)",
    )
    parser.add_argument("--website-matrix", metavar="OUT", help="write the guidelines-index table")
    parser.add_argument("--summary-table", metavar="OUT", help="write the summary-page table")
    parser.add_argument("--skill-matrix", metavar="OUT", help="write the skill bundle matrix.md")
    parser.add_argument("--check", action="store_true", help="parse and validate only")
    args = parser.parse_args()

    root = Path(args.root)
    summary_dir = root / "llm-guidelines-paper" / "_summary"
    try:
        short_titles = load_short_titles(root / "short-titles.sh")
        columns, matrix_rows = parse_matrix(summary_dir / "matrix.tex")
        rationale_rows = parse_rationale(summary_dir / "rationale-recommendations.tex")
        validate(columns, matrix_rows, rationale_rows, short_titles)
    except (GenerationError, OSError) as exc:
        print(f"generate-summary-tables: error: {exc}", file=sys.stderr)
        return 1

    if not (args.check or args.website_matrix or args.summary_table or args.skill_matrix):
        parser.error("nothing to do: pass --check or at least one output option")

    if args.website_matrix:
        write_output(render_website_matrix(columns, matrix_rows), args.website_matrix)
    if args.summary_table:
        write_output(render_summary_table(rationale_rows), args.summary_table)
    if args.skill_matrix:
        write_output(render_skill_matrix(columns, matrix_rows), args.skill_matrix)
    return 0


if __name__ == "__main__":
    sys.exit(main())
