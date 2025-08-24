#!/bin/sh

convert_tex_to_md() {
    directory=$1
    cd "$directory"
    for tex_file in *.tex; do
        [ -e "$tex_file" ] || continue
        md_file="${tex_file%.tex}.md"
        # debug: --verbose --log="pandoc.log"
        pandoc --wrap=none --bibliography="../../literature.bib" -s "$tex_file" -t markdown_strict --citeproc --webtex | perl -ne 'print if not /^---/.../^---/; END { print "\n" }' > "$md_file"
    done
}

current_dir="$(pwd)"
convert_tex_to_md "scope/_sources"
cd "$current_dir"
convert_tex_to_md "study-types/_sources"
cd "$current_dir"
convert_tex_to_md "guidelines/_sources"
cd "$current_dir"

cat scope/_sources/*.md > scope/index.md
cat guidelines/_sources/*.md > guidelines/index.md
cat study-types/_sources/*.md > study-types/index.md
