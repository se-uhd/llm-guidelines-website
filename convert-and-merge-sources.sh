#!/bin/sh

convert_tex_to_md() {
    directory=$1
    cd "$directory"
    for tex_file in *.tex; do
        [ -e "$tex_file" ] || continue
        md_file="${tex_file%.tex}.md"
        # debug: --verbose --log="pandoc.log"
        pandoc --wrap=none --lua-filter="../../pandoc-filters.lua" --bibliography="../../llm-guidelines-paper/literature.bib" -s "$tex_file" -t markdown_strict --citeproc --webtex | perl -ne 'print if not /^---/.../^---/; END { print "\n" }' > "$md_file"
    done
}

# Generate a sub-page index.md from a converted .md file
# Usage: generate_subpage <md_file> <parent_dir> <parent_title> <nav_order>
generate_subpage() {
    md_file=$1
    parent_dir=$2
    parent_title=$3
    nav_order=$4

    # Extract the first ## heading
    heading=$(grep -m1 "^## " "$md_file" | sed 's/^## //')
    [ -z "$heading" ] && return 1

    # Derive slug: lowercase, strip (G1)/(S1) suffixes, strip "Introduction: " prefix,
    # remove non-alphanumeric chars except hyphens and spaces, collapse spaces to hyphens
    slug=$(echo "$heading" | perl -pe '
        $_ = lc $_;
        s/\s*\([gs]\d+\)\s*$//;
        s/^introduction:\s*//;
        s/[^a-z0-9 -]//g;
        s/\s+/-/g;
        s/-{2,}/-/g;
        s/^-|-$//g;
    ')
    [ -z "$slug" ] && return 1

    # Derive nav title: use short name from lookup table, strip "Introduction: " prefix
    nav_title=$(echo "$heading" | perl -pe '
        my %short = (
            G1 => "Usage and Role",
            G2 => "Version and Configuration",
            G3 => "Architecture",
            G4 => "Prompts and Logs",
            G5 => "Human Validation",
            G6 => "Open LLMs",
            G7 => "Benchmarks and Metrics",
            G8 => "Limitations and Mitigations",
            S1 => "LLMs as Annotators",
            S2 => "LLMs as Judges",
            S3 => "LLMs for Synthesis",
            S4 => "LLMs as Subjects",
            S5 => "Studying LLM Usage",
            S6 => "LLMs for Tools",
            S7 => "Benchmarking LLMs",
        );
        if (s/\s*\(([GS]\d+)\)\s*$//) {
            my $id = $1;
            $_ = exists $short{$id} ? "$id: $short{$id}" : "$id: $_";
        }
        s/^Introduction:\s*//;
        my %cat = (
            "LLMs as Tools for Software Engineering Researchers" => "LLMs for Research",
            "LLMs as Tools for Software Engineers" => "LLMs for SE",
        );
        for my $long (keys %cat) {
            if ($_ eq "$long\n") { $_ = "$cat{$long}\n"; last }
        }
    ')

    # Create sub-page directory
    mkdir -p "${parent_dir}/${slug}"

    # Generate the sub-page: front matter + page heading + content with headings promoted
    {
        cat <<EOF
---
layout: default
title: "${nav_title}"
parent: ${parent_title}
nav_order: ${nav_order}
---

# ${heading}

EOF
        # Strip the first ## heading, promote remaining headings one level
        perl -pe '
            if (!$done && /^## /) { $done = 1; $_ = ""; next }
            s/^## /# /;
            s/^### /## /;
            s/^#### /### /;
        ' "$md_file"
    } > "${parent_dir}/${slug}/index.md"

    echo "$slug"
}

current_dir="$(pwd)"
convert_tex_to_md "scope/_sources"
cd "$current_dir"
convert_tex_to_md "study-types/_sources"
cd "$current_dir"
convert_tex_to_md "guidelines/_sources"
cd "$current_dir"
convert_tex_to_md "checklist/_sources"
cd "$current_dir"

# --- Guidelines sub-pages ---

# Generate sub-pages for each guideline
guidelines_nav=1
for md_file in guidelines/_sources/0[1-8]_*.md; do
    [ -e "$md_file" ] || continue
    generate_subpage "$md_file" "guidelines" "Guidelines" "$guidelines_nav"
    guidelines_nav=$((guidelines_nav + 1))
done

# Read converted intro content (strip pandoc-generated References heading and everything after it)
guidelines_intro=$(perl -ne 'print unless /^#{2,3}\s+References\s*$/ .. eof' guidelines/_sources/00_intro.md)

# Generate guidelines parent page (header + intro + matrix)
GUIDELINES_INTRO="$guidelines_intro" \
    perl -pe 's/<!-- INTRO -->/$ENV{GUIDELINES_INTRO}/' \
    guidelines/_sources/00_header.md > guidelines/index.md

# --- Study types sub-pages ---

# Generate sub-pages for each study type
study_types_nav=1
for md_file in study-types/_sources/0[2-9]_*.md study-types/_sources/1[0-1]_*.md; do
    [ -e "$md_file" ] || continue
    generate_subpage "$md_file" "study-types" "Study Types" "$study_types_nav"
    study_types_nav=$((study_types_nav + 1))
done

# Read converted intro content
study_types_intro=$(cat study-types/_sources/00_intro.md)

# Generate study types parent page (header + intro)
STUDY_TYPES_INTRO="$study_types_intro" \
    perl -pe 's/<!-- INTRO -->/$ENV{STUDY_TYPES_INTRO}/' \
    study-types/_sources/00_header.md > study-types/index.md

# --- Scope and checklist (unchanged) ---

cat scope/_sources/*.md > scope/index.md
cat checklist/_sources/*.md > checklist/index.md

# Remove unresolved \ref{} anchors that pandoc cannot resolve (labels only exist in the paper).
# Pattern: <a href="#LABEL" data-reference-type="ref" data-reference="LABEL">[LABEL]</a>
# Note: LaTeX ~ produces UTF-8 non-breaking spaces (\xC2\xA0) that \s does not match by default.
for md_file in scope/index.md guidelines/index.md guidelines/*/index.md \
               study-types/index.md study-types/*/index.md checklist/index.md; do
    [ -e "$md_file" ] || continue
    perl -CSD -pi -e '
        my $sp = qr/[\s\x{a0}]/;
        # Remove "(Section/Table/Appendix <ref>)" parentheticals entirely
        s/\((Section|Table|Appendix|Figure)$sp*<a[^>]*data-reference-type="ref"[^>]*>\[[^\]]*\]<\/a>\)//g;
        # Remove "Table/Appendix/Figure <ref>" (prefix word + anchor)
        s/(Table|Appendix|Figure)$sp*<a[^>]*data-reference-type="ref"[^>]*>\[[^\]]*\]<\/a>$sp*//g;
        # Remove "(Section <ref>)" where only Section text remains (anchor already stripped)
        s/\((Section|Table|Appendix|Figure)$sp*\)//g;
        # Remove any remaining unresolved ref anchors
        s/<a[^>]*data-reference-type="ref"[^>]*>\[[^\]]*\]<\/a>//g;
        # Clean up orphaned sentence fragments left after removing Table/Appendix refs
        s/,?\s*then consult to determine/. Determine/g;
        s/the checklist in,/the checklist,/g;
        s/\.\s*provides a quick reference[^.]*\.//g;
        s/,?\s*and maps each[^.]*\.//g;
        s/\.\s*helps reviewers[^.]*\.//g;
        # Inline footnotes: replace "[N]" marker + "[N] URL" footer with a linked marker
        # Collect footnote definitions (e.g., "[1] https://...") into a hash, then inline them.
        # Fix Markdown inside HTML tags: <u>*...*</u> → <u><em>...</em></u>
        s/<u>\*([^*]+)\*<\/u>/<u><em>$1<\/em><\/u>/g;
        # Clean up: "in , which" → ", which"; collapse spaces; trim space before punctuation
        s/\bin$sp*,/,/g;
        s/(?<=\S)$sp{2,}/ /g;
        s/$sp([,.;:!?)>\]])/\1/g;
    ' "$md_file"
    # Inline footnotes: convert "[N] URL" at end of file into superscript links at the marker site
    perl -CSD -0777 -pi -e '
        my %fn;
        while (s/^\[(\d+)\]\s*<?(\S+?)>?\s*$//m) {
            $fn{$1} = $2;
        }
        for my $n (keys %fn) {
            my $url = $fn{$n};
            if ($url =~ m{^https?://}) {
                s{\[${n}\]}{<sup>[$n]($url)</sup>}g;
            }
        }
        s/\n{3,}/\n\n/g;
    ' "$md_file"
done

# Checklist-specific post-processing
if [ -e checklist/index.md ]; then
    # Remove webtex $\square$ images (interactive checkboxes replace them)
    perl -CSD -pi -e 's/!\[\\square\]\([^)]*\)\s*//g' checklist/index.md
    # Remove duplicate "# Checklist" heading (already have "# Reporting Checklist" from header)
    perl -CSD -pi -e 's/^# Checklist$//' checklist/index.md
    # Promote paper section headings: #### **Name** → ## Name
    perl -CSD -pi -e 's/^#### \*\*(.+?)\*\*$/## $1/' checklist/index.md
    # Promote sub-category italic lines to headings: *Name* → ### Name
    # (standalone italic lines that are not list items)
    perl -CSD -pi -e 's/^(?:  \n)?\*([A-Z][^*]+)\*$/### $1/' checklist/index.md
    # Remove stray whitespace-only lines (from \mbox{}\\)
    perl -CSD -pi -e 's/^  $//' checklist/index.md
    # Place the reset button after the intro paragraph (replace placeholder)
    perl -CSD -0777 -pi -e '
        s/<!-- RESET_BUTTON -->\n*/\n/;
        s/(Each item references its source guideline \(G1.G8\)\.)\n/\1\n\n<button id="checklist-reset" class="btn btn-outline"><i class="fa-solid fa-rotate-left"><\/i> Reset checkboxes<\/button>\n<button id="checklist-export" class="btn btn-outline"><i class="fa-solid fa-file-csv"><\/i> Export to CSV<\/button>\n/;
    ' checklist/index.md
    # Link (G1)–(G8) references to the corresponding guideline sub-pages
    perl -CSD -pi -e '
        my %g = (
            1 => "declare-llm-usage-and-role",
            2 => "report-model-version-configuration-and-customizations",
            3 => "report-tool-architecture-beyond-models",
            4 => "report-prompts-their-development-and-interaction-logs",
            5 => "use-human-validation-for-llm-outputs",
            6 => "use-an-open-llm-as-a-baseline",
            7 => "use-suitable-baselines-benchmarks-and-metrics",
            8 => "report-limitations-and-mitigations",
        );
        s/\(G([1-8])\)/"([G$1](\/guidelines\/" . $g{$1} . "\/))"/ge;
    ' checklist/index.md
fi
