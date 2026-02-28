#!/bin/sh

compile_tex() {
    directory=$1
    cd "$directory"
    for tex_file in *.tex; do
        [ -e "$tex_file" ] || continue
        pdflatex -halt-on-error "$tex_file"
        if [ $? = 0 ] ; then
            aux_file="${tex_file%.tex}.aux"
            if grep -q '\\bibdata' "$aux_file" 2>/dev/null; then
                bibtex "${tex_file%.tex}"
                if [ $? != 0 ] ; then
                    echo "Processing of Bibtex file for Latex file $tex_file failed."
                    exit 1
                fi
            fi
            pdflatex -halt-on-error "$tex_file"
            pdflatex -halt-on-error "$tex_file"
        else 
            echo "Compilation of Latex file $tex_file failed."
            exit 1
        fi
    done
}

current_dir="$(pwd)"
compile_tex "scope/_sources"
cd "$current_dir"
compile_tex "study-types/_sources"
cd "$current_dir"
compile_tex "guidelines/_sources"
cd "$current_dir"
compile_tex "checklist/_sources"
cd "$current_dir"

echo "Latex compilation successful."
