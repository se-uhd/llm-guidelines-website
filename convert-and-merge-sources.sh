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
# Usage: generate_subpage <md_file> <parent_dir> <parent_title> <nav_order> [grand_parent] [has_children]
generate_subpage() {
    md_file=$1
    parent_dir=$2
    parent_title=$3
    nav_order=$4
    grand_parent=$5
    has_children=$6

    # Extract the first ## heading
    heading=$(grep -m1 "^## " "$md_file" | sed 's/^## //')
    [ -z "$heading" ] && return 1

    # Derive slug: lowercase, remove non-alphanumeric chars except hyphens and
    # spaces, collapse spaces to hyphens
    slug=$(echo "$heading" | perl -pe '
        $_ = lc $_;
        s/[^a-z0-9 -]//g;
        s/\s+/-/g;
        s/-{2,}/-/g;
        s/^-|-$//g;
    ')
    [ -z "$slug" ] && return 1

    # Derive nav title: map full heading text to short name where one is defined
    nav_title=$(echo "$heading" | perl -pe '
        my %short = (
            "Declare LLM Usage and Role"                              => "Declare Usage",
            "Report Model Version, Configuration, and Customizations" => "Model Version",
            "Report System and Prompt Design"                         => "Design",
            "Report Session Traces"                                   => "Traces",
            "Use Suitable Baselines, Benchmarks, and Metrics"         => "Benchmarks",
            "Use an Open LLM as a Baseline"                           => "Open LLM",
            "Use Human Validation for LLM Outputs"                    => "Human Validation",
            "Report Limitations and Mitigations"                      => "Limitations",
            "LLMs as Annotators"                                      => "Annotator",
            "LLMs as Judges"                                          => "Judge",
            "LLMs for Synthesis"                                      => "Synthesis",
            "LLMs as Subjects"                                        => "Subject",
            "Studying LLM Usage in Software Engineering"              => "Usage",
            "LLMs for New Software Engineering Tools"                 => "Tools",
            "Benchmarking LLMs for Software Engineering Tasks"        => "Benchmarks",
            "LLMs as Tools for Software Engineering Researchers"      => "LLMs for Research",
            "LLMs as Tools for Software Engineers"                    => "LLMs for SE",
        );
        chomp(my $key = $_);
        $_ = "$short{$key}\n" if exists $short{$key};
    ')

    # Create sub-page directory
    mkdir -p "${parent_dir}/${slug}"

    # Generate the sub-page: front matter + page heading + content with headings promoted
    {
        printf -- '---\n'
        printf 'layout: default\n'
        printf 'title: "%s"\n' "$nav_title"
        printf 'parent: %s\n' "$parent_title"
        [ -n "$grand_parent" ] && printf 'grand_parent: %s\n' "$grand_parent"
        printf 'nav_order: %s\n' "$nav_order"
        [ -n "$has_children" ] && printf 'has_children: true\n'
        printf -- '---\n\n'
        printf '# %s\n\n' "$heading"

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
#
# Two-level structure: each "LLMs as Tools for..." parent is a top-level page
# under "Study Types" with its specific study types nested under it.
# "Advantages and Challenges" is a top-level sibling because the prose covers
# both groups.
#
# File numbering encodes the structure:
#   02     = parent #1 (LLMs as Tools for Software Engineering Researchers)
#   03-06  = children of #1 (annotators, judges, synthesis, subjects)
#   07     = parent #2 (LLMs as Tools for Software Engineers)
#   08-10  = children of #2 (usage, tools, benchmarks)
#   11     = advantages and challenges (cross-cutting sibling)

# Group 1: parent + four children
generate_subpage study-types/_sources/02_*.md study-types "Study Types" 1 "" "true"
n=1
for prefix in 03 04 05 06; do
    for md_file in study-types/_sources/${prefix}_*.md; do
        [ -e "$md_file" ] || continue
        generate_subpage "$md_file" "study-types" "LLMs for Research" "$n" "Study Types"
        n=$((n + 1))
    done
done

# Group 2: parent + three children
generate_subpage study-types/_sources/07_*.md study-types "Study Types" 2 "" "true"
n=1
for prefix in 08 09 10; do
    for md_file in study-types/_sources/${prefix}_*.md; do
        [ -e "$md_file" ] || continue
        generate_subpage "$md_file" "study-types" "LLMs for SE" "$n" "Study Types"
        n=$((n + 1))
    done
done

# Cross-cutting sibling
generate_subpage study-types/_sources/11_*.md study-types "Study Types" 3

# Read converted intro content
study_types_intro=$(cat study-types/_sources/00_intro.md)

# Generate study types parent page (header + intro)
STUDY_TYPES_INTRO="$study_types_intro" \
    perl -pe 's/<!-- INTRO -->/$ENV{STUDY_TYPES_INTRO}/' \
    study-types/_sources/00_header.md > study-types/index.md

# --- Scope and checklist (unchanged) ---

cat scope/_sources/*.md > scope/index.md
cat checklist/_sources/*.md > checklist/index.md

# --- Changelog (plain Markdown copy from paper repo) ---

if [ -e llm-guidelines-paper/CHANGELOG.md ]; then
    cat changelog/_sources/00_header.md llm-guidelines-paper/CHANGELOG.md > changelog/index.md
fi

# Post-process pandoc output:
# 1. Trim the trailing space pandoc emits after \href cross-reference macros
#    (their LaTeX expansion ends with `~`, which becomes a regular space and
#    lands before punctuation like `)` or `,`).
# 2. Inline footnotes: pandoc emits "[N]" markers and "[N] URL" definitions at
#    the bottom of the file; rewrite each marker as a superscript link.
for md_file in scope/index.md guidelines/index.md guidelines/*/index.md \
               study-types/index.md study-types/*/index.md checklist/index.md; do
    [ -e "$md_file" ] || continue
    perl -CSD -pi -e '
        my $sp = qr/[\s\x{a0}]/;
        s/(?<=\S)$sp{2,}/ /g;
        s/$sp([,.;:!?)>\]])/\1/g;
    ' "$md_file"
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
        s/(unmarked items may be reported in either\.)\n/\1\n\n<button id="checklist-reset" class="btn btn-outline"><i class="fa-solid fa-rotate-left"><\/i> Reset checkboxes<\/button>\n<button id="checklist-export" class="btn btn-outline"><i class="fa-solid fa-file-csv"><\/i> Export to CSV<\/button>\n/;
    ' checklist/index.md
    # Replace ○ (SHOULD) with gray-filled ● to match paper styling
    perl -pi -e 's/○/<span class="marker-should">●<\/span>/g' checklist/index.md
    # Link short-name references like (Declare Usage) to the corresponding guideline sub-pages
    perl -CSD -pi -e '
        my %g = (
            "Declare Usage"    => "declare-llm-usage-and-role",
            "Model Version"    => "report-model-version-configuration-and-customizations",
            "Design"           => "report-system-and-prompt-design",
            "Traces"           => "report-session-traces",
            "Benchmarks"       => "use-suitable-baselines-benchmarks-and-metrics",
            "Open LLM"         => "use-an-open-llm-as-a-baseline",
            "Human Validation" => "use-human-validation-for-llm-outputs",
            "Limitations"      => "report-limitations-and-mitigations",
        );
        my $names = join("|", map { quotemeta } sort { length($b) <=> length($a) } keys %g);
        s/\(($names)\)/"([$1](\/guidelines\/" . $g{$1} . "\/))"/ge;
    ' checklist/index.md
fi

# --- Skill bundle (optional; runs only if the skill submodule is initialized) ---

if [ -d llm-guidelines-skill/.claude-plugin ] && [ -x ./generate-skill.sh ]; then
    ./generate-skill.sh
fi
