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
    # Convert \condition{slug} sentinel from the LaTeX macro into a styled chip
    # span. The website-side macro emits @@cond:slug@@; @@ is the only form
    # we found that survives pandoc's markdown_strict output verbatim (literal
    # `[[...]]` gets escaped, and `--` inside HTML comments gets smart-quoted
    # to an en-dash). The span provides a CSS hook and a data attribute the
    # JS filter can match against.
    perl -CSD -pi -e 's{\@\@cond:([a-z0-9-]+)\@\@}{<span class="condition" data-condition="$1">[$1]</span>}g' checklist/index.md
    # Remove duplicate "# Checklist" heading (already have "# Reporting Checklist" from header)
    perl -CSD -pi -e 's/^# Checklist$//' checklist/index.md
    # Promote paper section headings: #### **Name** → ## Name
    perl -CSD -pi -e 's/^#### \*\*(.+?)\*\*$/## $1/' checklist/index.md
    # Promote sub-category italic lines to headings: *Name* → ### Name
    # (standalone italic lines that are not list items)
    perl -CSD -pi -e 's/^(?:  \n)?\*([A-Z][^*]+)\*$/### $1/' checklist/index.md
    # Remove stray whitespace-only lines (from \mbox{}\\)
    perl -CSD -pi -e 's/^  $//' checklist/index.md
    # Place the filter UI and reset/export buttons between the intro paragraph
    # and the first checklist section (replaces placeholder; anchors on the
    # end of the intro paragraph, which now closes with the bracket-convention
    # sentence "...filter to the tags relevant to their study.").
    perl -CSD -0777 -pi -e '
        s/<!-- RESET_BUTTON -->\n*/\n/;
        my $filters = q{<details id="condition-filters"><summary>Filter checklist by study features</summary>
<p class="filter-parent-heading">Research Design and Methods</p>
<div class="filter-section">
<p class="filter-section-title">Model Selection and Configuration</p>
<div class="filter-grid">
<label title="Study fine-tunes one or more LLMs with additional training data."><input type="checkbox" class="cond-filter" data-condition="fine-tuning" checked> fine-tuning</label>
<label title="Study uses a quantized model variant (e.g., 4-bit, 8-bit) to reduce memory or compute requirements."><input type="checkbox" class="cond-filter" data-condition="quantization" checked> quantization</label>
<label title="Study uses commercial (closed-weight) LLMs or services."><input type="checkbox" class="cond-filter" data-condition="commercial-models" checked> commercial models</label>
</div>
</div>
<div class="filter-section">
<p class="filter-section-title">System and Prompt Design / Session Traces</p>
<div class="filter-grid">
<label title="Study uses an autonomous agent that plans and executes tasks (single- or multi-agent system)."><input type="checkbox" class="cond-filter" data-condition="agents" checked> agents</label>
<label title="Study augments the prompt with stored data via retrieval-augmented generation (RAG) or similar retrieval mechanisms."><input type="checkbox" class="cond-filter" data-condition="context-augmentation" checked> context augmentation</label>
<label title="Study uses context file mechanisms (e.g., CLAUDE.md, AGENTS.md) to steer model behavior."><input type="checkbox" class="cond-filter" data-condition="context-files" checked> context files</label>
<label title="Study exposes tools, skills, sub-agents, or MCP servers to the LLM for runtime invocation."><input type="checkbox" class="cond-filter" data-condition="tool-use" checked> tool use</label>
<label title="Study uses an ensemble of multiple models with routing logic or an output-combination strategy."><input type="checkbox" class="cond-filter" data-condition="ensemble" checked> ensemble</label>
<label title="Study constructs prompts programmatically at runtime, beyond filling templates with study-specific inputs."><input type="checkbox" class="cond-filter" data-condition="dynamic-prompts" checked> dynamic prompts</label>
<label title="Study involves human participants who create or modify the prompts."><input type="checkbox" class="cond-filter" data-condition="participant-prompts" checked> participant prompts</label>
<label title="Prompts in the study are long or complex enough to warrant input-length handling or token-optimization strategies."><input type="checkbox" class="cond-filter" data-condition="long-prompts" checked> long/complex prompts</label>
</div>
</div>
<div class="filter-section">
<p class="filter-section-title">Benchmarks and Metrics</p>
<div class="filter-grid">
<label title="Study creates or releases a new benchmark."><input type="checkbox" class="cond-filter" data-condition="new-benchmark" checked> new benchmark</label>
<label title="Study uses non-probability sampling (e.g., convenience) to select benchmark items."><input type="checkbox" class="cond-filter" data-condition="non-probability-sampling" checked> non-probability sampling</label>
<label title="Multiple human raters or non-deterministic LLM-as-judge runs assess the same item, with possible disagreement."><input type="checkbox" class="cond-filter" data-condition="multi-rater-scoring" checked> multi-rater scoring</label>
</div>
</div>
<div class="filter-section">
<p class="filter-section-title">Human Validation</p>
<div class="filter-grid">
<label title="Study uses human raters or annotators to validate LLM outputs."><input type="checkbox" class="cond-filter" data-condition="human-validation" checked> human validation</label>
<label title="Study measures value-laden or culturally contingent constructs (e.g., fairness, code quality, usability)."><input type="checkbox" class="cond-filter" data-condition="subjective-constructs" checked> subjective constructs</label>
</div>
</div>
<div class="filter-section">
<p class="filter-section-title">Reproducibility and Ethics</p>
<div class="filter-grid">
<label title="Study involves sensitive, proprietary, or otherwise restricted materials (data, prompts, traces, code) that cannot be fully shared publicly."><input type="checkbox" class="cond-filter" data-condition="restricted-sharing" checked> restricted sharing</label>
</div>
</div>
<p class="filter-parent-heading">Results</p>
<div class="filter-section filter-section-no-title">
<div class="filter-grid">
<label title="Study compares multiple models or tools and reports their relative performance."><input type="checkbox" class="cond-filter" data-condition="comparing-models" checked> model comparison</label>
</div>
</div>
<div class="filter-actions">
<button id="filters-toggle" type="button" class="btn btn-outline"><i class="fa-solid fa-toggle-on"></i> Toggle all filters</button>
</div>
</details>
};
        my $buttons = qq{<button id="checklist-reset" type="button" class="btn btn-outline"><i class="fa-solid fa-rotate-left"></i> Reset checkboxes</button>\n<button id="checklist-export" type="button" class="btn btn-outline"><i class="fa-solid fa-file-csv"></i> Export to CSV</button>\n};
        s/(use the filter panel to hide items that do not apply to their study\.)\n/$1\n\n$buttons\n$filters/;
    ' checklist/index.md
    # Replace ○ (SHOULD) with gray-filled ● to match paper styling
    perl -pi -e 's/○/<span class="marker-should">●<\/span>/g' checklist/index.md
    # Short-name references like (Declare Usage) are now produced by the
    # \refdeclareusage / \refmodelversion / ... macros in shared-header.tex,
    # which the website branch defines as \href{/guidelines/<slug>/}{<short>}.
    # Pandoc converts the \href to a markdown link automatically; no further
    # post-processing is needed.
fi

# --- Skill bundle (optional; runs only if the skill submodule is initialized) ---

if [ -d llm-guidelines-skill/.claude-plugin ] && [ -x ./generate-skill.sh ]; then
    ./generate-skill.sh
fi
