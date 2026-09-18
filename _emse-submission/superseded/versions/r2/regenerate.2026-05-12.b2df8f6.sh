#!/usr/bin/env bash
#
# Rebuild every R2 resubmission artifact from the current paper sources.
#
# Run this before uploading to EMSE Editorial Manager. The script regenerates
# every derived file in versions/r2/ and reviews-and-response/response-letter_r2.*
# from the working-tree sources on every invocation, so the bundle cannot
# carry forward a stale flat tex, bibliography, or PDF. The only file it does
# not touch is EMSE-D-25-00637_R2.pdf (downloaded from Editorial Manager).
#
# Steps:
#   1. Recompile and flatten the paper (compile_and_flatten.sh) so the flat
#      tex and PDF reflect current sources, including uncommitted edits.
#   2. Sanity-check that the freshly written flat tex contains exactly one
#      \bibliography{literature} line we can rewrite (no silent miss).
#   3. Copy literature.bib -> literature_r2.bib.
#   4. Copy emse26-llm-guidelines-flat.tex -> emse26-llm-guidelines-flat_r2.tex,
#      rewriting \bibliography{literature} -> \bibliography{literature_r2}
#      so the R2 bundle is self-contained.
#   5. Compile emse26-llm-guidelines-flat_r2.pdf in versions/r2/.
#   6. Compile title-page_r2.pdf in versions/r2/.
#   7. Compile response-letter_r2.pdf in reviews-and-response/.
#
set -euo pipefail

R2_DIR="$(cd "$(dirname "$0")" && pwd)"
PAPER_DIR="$(cd "$R2_DIR/../.." && pwd)"
RESPONSE_DIR="$PAPER_DIR/reviews-and-response"

SRC_FLAT_TEX="$PAPER_DIR/emse26-llm-guidelines-flat.tex"
SRC_BIB="$PAPER_DIR/literature.bib"

R2_FLAT_TEX="$R2_DIR/emse26-llm-guidelines-flat_r2.tex"
R2_BIB="$R2_DIR/literature_r2.bib"

echo "[1/7] compile_and_flatten.sh"
"$PAPER_DIR/compile_and_flatten.sh" >/dev/null

echo "[2/7] check flat tex has exactly one \\bibliography{literature}"
bib_lines=$(grep -c '^\\bibliography{literature}$' "$SRC_FLAT_TEX" || true)
if [ "$bib_lines" -ne 1 ]; then
  echo "ERROR: expected exactly one '\\bibliography{literature}' line in $SRC_FLAT_TEX, found $bib_lines." >&2
  echo "       The R2 bundle needs the rewrite to literature_r2; investigate before resubmitting." >&2
  exit 1
fi

echo "[3/7] copy literature.bib -> $(basename "$R2_BIB")"
cp "$SRC_BIB" "$R2_BIB"

echo "[4/7] copy flat tex -> $(basename "$R2_FLAT_TEX") (rewrite bibliography)"
sed 's|^\\bibliography{literature}$|\\bibliography{literature_r2}|' \
  "$SRC_FLAT_TEX" > "$R2_FLAT_TEX"
if ! grep -q '^\\bibliography{literature_r2}$' "$R2_FLAT_TEX"; then
  echo "ERROR: bibliography rewrite missed; expected \\bibliography{literature_r2} in $R2_FLAT_TEX" >&2
  exit 1
fi

echo "[5/7] compile $(basename "$R2_FLAT_TEX")"
latexmk -pdf -interaction=nonstopmode -halt-on-error -cd "$R2_FLAT_TEX" >/dev/null

echo "[6/7] compile title-page_r2.tex"
latexmk -pdf -interaction=nonstopmode -halt-on-error -cd "$R2_DIR/title-page_r2.tex" >/dev/null

echo "[7/7] compile response-letter_r2.tex"
latexmk -pdf -interaction=nonstopmode -halt-on-error -cd "$RESPONSE_DIR/response-letter_r2.tex" >/dev/null

echo
echo "Done. R2 bundle under versions/r2/ and response-letter_r2.pdf are rebuilt from current sources."
echo "Note: EMSE-D-25-00637_R2.pdf is the editorial-system download and is not regenerated here."
