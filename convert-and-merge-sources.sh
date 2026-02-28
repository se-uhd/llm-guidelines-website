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

current_dir="$(pwd)"
convert_tex_to_md "scope/_sources"
cd "$current_dir"
convert_tex_to_md "study-types/_sources"
cd "$current_dir"
convert_tex_to_md "guidelines/_sources"
cd "$current_dir"
convert_tex_to_md "checklist/_sources"
cd "$current_dir"

# Generate guidelines TOC from converted markdown headings
guidelines_toc=$(grep -h "^## " guidelines/_sources/0[1-8]_*.md | perl -ne '
    chomp;
    s/^## //;
    my $heading = $_;
    my $anchor = lc $heading;
    $anchor =~ s/[^a-z0-9 -]//g;
    $anchor =~ s/ /-/g;
    $anchor =~ s/-{2,}/-/g;
    print "$.. [$heading](#$anchor)\n";
')

# Generate study types TOC from converted markdown headings
study_types_toc=$(grep -h "^## " study-types/_sources/01_study-types.md | perl -e '
    my $top = 0;
    my $sub = 0;
    while (<>) {
        chomp;
        s/^## //;
        my $heading = $_;
        next if $heading =~ /^Advantages and Challenges/;
        my $anchor = lc $heading;
        $anchor =~ s/[^a-z0-9 -]//g;
        $anchor =~ s/ /-/g;
        $anchor =~ s/-{2,}/-/g;
        if ($heading =~ /^Introduction:\s*(.+)/) {
            $top++;
            $sub = 0;
            my $display = $1;
            print "${top}. [${display}](#${anchor})\n";
        } elsif ($heading =~ /\(S\d+\)/) {
            $sub++;
            print "    ${sub}. [${heading}](#${anchor})\n";
        } elsif ($heading eq "References") {
            $top++;
            print "${top}. [${heading}](#${anchor})\n";
        }
    }
')

# Read converted intro content (strip pandoc-generated References heading and everything after it)
guidelines_intro=$(perl -ne 'print unless /^#{2,3}\s+References\s*$/ .. eof' guidelines/_sources/00_intro.md)
study_types_intro=$(cat study-types/_sources/00_intro.md)

# Merge sources into index.md files, replacing <!-- INTRO --> and <!-- TOC --> markers
cat scope/_sources/*.md > scope/index.md

cat guidelines/_sources/00_header.md guidelines/_sources/0[1-8]_*.md \
    | GUIDELINES_INTRO="$guidelines_intro" GUIDELINES_TOC="$guidelines_toc" \
      perl -pe 's/<!-- INTRO -->/$ENV{GUIDELINES_INTRO}/; s/<!-- TOC -->/$ENV{GUIDELINES_TOC}/' \
    > guidelines/index.md

cat study-types/_sources/00_header.md study-types/_sources/01_study-types.md \
    | STUDY_TYPES_INTRO="$study_types_intro" STUDY_TYPES_TOC="$study_types_toc" \
      perl -pe 's/<!-- INTRO -->/$ENV{STUDY_TYPES_INTRO}/; s/<!-- TOC -->/$ENV{STUDY_TYPES_TOC}/' \
    > study-types/index.md

cat checklist/_sources/*.md > checklist/index.md

# Remove unresolved \ref{} anchors that pandoc cannot resolve (labels only exist in the paper).
# Pattern: <a href="#LABEL" data-reference-type="ref" data-reference="LABEL">[LABEL]</a>
# Note: LaTeX ~ produces UTF-8 non-breaking spaces (\xC2\xA0) that \s does not match by default.
for md_file in scope/index.md guidelines/index.md study-types/index.md checklist/index.md; do
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
        s/(Each item references its source guideline \(G1.G8\)\.)\n/\1\n\n<button id="checklist-reset" class="btn btn-outline"><i class="fa-solid fa-rotate-left"><\/i> Reset checkboxes<\/button>\n/;
    ' checklist/index.md
    # Link (G1)–(G8) references to the corresponding guideline anchors
    perl -CSD -pi -e '
        my %g = (
            1 => "declare-llm-usage-and-role-g1",
            2 => "report-model-version-configuration-and-customizations-g2",
            3 => "report-tool-architecture-beyond-models-g3",
            4 => "report-prompts-their-development-and-interaction-logs-g4",
            5 => "use-human-validation-for-llm-outputs-g5",
            6 => "use-an-open-llm-as-a-baseline-g6",
            7 => "use-suitable-baselines-benchmarks-and-metrics-g7",
            8 => "report-limitations-and-mitigations-g8",
        );
        s/\(G([1-8])\)/"([G$1]\(\/guidelines#" . $g{$1} . "\))"/ge;
    ' checklist/index.md
fi
