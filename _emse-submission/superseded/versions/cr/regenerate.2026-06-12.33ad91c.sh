#!/usr/bin/env bash
#
# Rebuild the camera-ready submission artifacts from the current paper sources.
#
# Run this before updating files in versions/cr/. The script regenerates the
# local CR artifacts from the working-tree sources on every invocation, so the
# bundle cannot keep a stale or partially copied flat TeX file. It does not
# touch EMSE-D-25-00637_R3.pdf, which is the Editorial Manager download.
#
# Steps:
#   1. Recompile and flatten the paper so the root flat TeX/PDF reflect current
#      sources, including uncommitted edits.
#   2. Check that the root flat TeX has exactly one bibliography line to rewrite.
#   3. Copy literature.bib to literature_cr.bib.
#   4. Copy emse26-llm-guidelines-flat.tex to emse26-llm-guidelines-flat_cr.tex,
#      rewriting \bibliography{literature} to \bibliography{literature_cr}.
#   5. Compile emse26-llm-guidelines-flat_cr.pdf in versions/cr/.
#   6. Compile title-page_cr.pdf in versions/cr/.
#   7. Compile response-letter_r3.pdf in reviews-and-response/.
#   8. Remove LaTeX auxiliary files created by the CR compiles.
#
set -euo pipefail

CR_DIR="$(cd "$(dirname "$0")" && pwd)"
PAPER_DIR="$(cd "$CR_DIR/../.." && pwd)"
RESPONSE_DIR="$PAPER_DIR/reviews-and-response"

SRC_FLAT_TEX="$PAPER_DIR/emse26-llm-guidelines-flat.tex"
SRC_BIB="$PAPER_DIR/literature.bib"

CR_FLAT_TEX="$CR_DIR/emse26-llm-guidelines-flat_cr.tex"
CR_BIB="$CR_DIR/literature_cr.bib"

cleanup_latex_auxiliary_files() {
  local tex_file="$1"
  local tex_dir tex_stem
  tex_dir="$(cd "$(dirname "$tex_file")" && pwd)"
  tex_stem="$(basename "$tex_file" .tex)"

  find "$tex_dir" -maxdepth 1 -type f \( \
    -name "$tex_stem.aux" -o \
    -name "$tex_stem.bbl" -o \
    -name "$tex_stem.bcf" -o \
    -name "$tex_stem.blg" -o \
    -name "$tex_stem.fdb_latexmk" -o \
    -name "$tex_stem.fls" -o \
    -name "$tex_stem.lof" -o \
    -name "$tex_stem.log" -o \
    -name "$tex_stem.lot" -o \
    -name "$tex_stem.out" -o \
    -name "$tex_stem.run.xml" -o \
    -name "$tex_stem.synctex.gz" -o \
    -name "$tex_stem.toc" \
  \) -delete
}

echo "[1/8] compile_and_flatten.sh"
"$PAPER_DIR/compile_and_flatten.sh" >/dev/null

echo "[2/8] check flat tex has exactly one \\bibliography{literature}"
bib_lines=$(grep -c '^\\bibliography{literature}$' "$SRC_FLAT_TEX" || true)
if [ "$bib_lines" -ne 1 ]; then
  echo "ERROR: expected exactly one '\\bibliography{literature}' line in $SRC_FLAT_TEX, found $bib_lines." >&2
  echo "       The CR bundle needs the rewrite to literature_cr; investigate before copying." >&2
  exit 1
fi

echo "[3/8] copy literature.bib -> $(basename "$CR_BIB")"
cp "$SRC_BIB" "$CR_BIB"

echo "[4/8] copy flat tex -> $(basename "$CR_FLAT_TEX") (rewrite bibliography)"
sed 's|^\\bibliography{literature}$|\\bibliography{literature_cr}|' \
  "$SRC_FLAT_TEX" > "$CR_FLAT_TEX"
if ! grep -q '^\\bibliography{literature_cr}$' "$CR_FLAT_TEX"; then
  echo "ERROR: bibliography rewrite missed; expected \\bibliography{literature_cr} in $CR_FLAT_TEX" >&2
  exit 1
fi

echo "[5/8] compile $(basename "$CR_FLAT_TEX")"
cleanup_latex_auxiliary_files "$CR_FLAT_TEX"
latexmk -pdf -interaction=nonstopmode -halt-on-error -cd "$CR_FLAT_TEX" >/dev/null

echo "[6/8] compile title-page_cr.tex"
cleanup_latex_auxiliary_files "$CR_DIR/title-page_cr.tex"
latexmk -pdf -interaction=nonstopmode -halt-on-error -cd "$CR_DIR/title-page_cr.tex" >/dev/null

echo "[7/8] compile response-letter_r3.tex"
cleanup_latex_auxiliary_files "$RESPONSE_DIR/response-letter_r3.tex"
latexmk -pdf -interaction=nonstopmode -halt-on-error -cd "$RESPONSE_DIR/response-letter_r3.tex" >/dev/null

echo "[8/8] remove LaTeX auxiliary files"
cleanup_latex_auxiliary_files "$CR_FLAT_TEX"
cleanup_latex_auxiliary_files "$CR_DIR/title-page_cr.tex"
cleanup_latex_auxiliary_files "$RESPONSE_DIR/response-letter_r3.tex"

echo
echo "Done. CR bundle under versions/cr/ is rebuilt from current sources."
echo "Note: EMSE-D-25-00637_R3.pdf is the editorial-system download and is not regenerated here."
