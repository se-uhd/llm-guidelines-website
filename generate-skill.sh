#!/bin/sh

# Generate the llm-guidelines skill bundle into the llm-guidelines-skill/ submodule.
#
# Sources are the website-rendered Jekyll pages (guidelines/<slug>/index.md,
# study-types/<slug>/index.md, scope/index.md, checklist/index.md), which the
# website's `convert-and-merge-sources.sh` produces from the paper's LaTeX. We
# read those because they already have post-processing applied (footnote
# inlining, whitespace cleanup, short-name link rewriting, etc.). We just
# strip the Jekyll front matter and rewrite website-absolute links to
# skill-relative paths.
#
# Does not commit or push; the user reviews and commits in the submodule manually.

set -e

ROOT="$(pwd)"
SKILL_REPO="${ROOT}/llm-guidelines-skill"
SKILL_DIR="${SKILL_REPO}/plugins/llm-guidelines/skills/llm-guidelines"
PLUGIN_DIR="${SKILL_REPO}/plugins/llm-guidelines"

if [ ! -d "${SKILL_REPO}/.claude-plugin" ]; then
    echo "error: ${SKILL_REPO} is not initialized; run 'git submodule update --init' first" >&2
    exit 1
fi

# --- 1. Resolve the CalVer version from _config.yml ---
#
# Parsed from the paper-tag URL in aux_links (the URL form is more stable
# than the HTML icon label that sits in the same block).

VERSION=$(perl -ne 'if (m{llm-guidelines-paper/tree/(\d{4}\.\d{2})}) { print $1; exit }' "${ROOT}/_config.yml")
if [ -z "$VERSION" ]; then
    echo "error: could not extract CalVer from _config.yml" >&2
    exit 1
fi
echo "skill version: ${VERSION}"

# --- 2. Slug derivation (mirrors convert-and-merge-sources.sh) ---

slugify() {
    echo "$1" | perl -CSD -pe '
        $_ = lc $_;
        s/^introduction:\s*//;
        s/[^a-z0-9 -]//g;
        s/\s+/-/g;
        s/-{2,}/-/g;
        s/^-|-$//g;
    '
}

# --- 3. Convert a website-rendered Markdown page into a skill file ---
#
# Strips Jekyll front matter and any inline <style>/<script>/<button> blocks
# (the checklist embeds these for client-side state and CSV export); rewrites
# website-absolute links to skill-relative paths.
#
# Args: <source_md> <output_md> <kind: guideline|study-type|root>

convert_source() {
    src=$1
    dst=$2
    kind=$3

    case "$kind" in
        guideline|study-type) prefix="../" ;;
        root)                 prefix="./" ;;
        *) echo "error: unknown kind: $kind" >&2; exit 1 ;;
    esac

    perl -CSD -0777 -ne '
        s/^---\n.*?\n---\n\s*//s;
        s{<style>.*?</style>\s*}{}gs;
        s{<script>.*?</script>\s*}{}gs;
        s{<button[^>]*>.*?</button>\s*}{}gs;
        print;
    ' "$src" > "$dst"

    perl -CSD -i -pe "
        my \$p = '${prefix}';
        s{/guidelines#([a-z0-9-]+)}{\${p}guidelines/\$1.md}g;
        s{/guidelines/([a-z0-9-]+)/}{\${p}guidelines/\$1.md}g;
        s{/study-types/([a-z0-9-]+)/}{\${p}study-types/\$1.md}g;
        s{/scope/}{\${p}scope.md}g;
        s{/checklist/}{\${p}checklist.md}g;
        s{/guidelines/(?![a-z0-9])}{\${p}guidelines/}g;
        s{/study-types/(?![a-z0-9])}{\${p}study-types/}g;
    " "$dst"
}

# --- 4. Wipe and recreate skill content directories ---

mkdir -p "${SKILL_DIR}/guidelines" "${SKILL_DIR}/study-types"
find "${SKILL_DIR}/guidelines" -maxdepth 1 -name '*.md' -delete
find "${SKILL_DIR}/study-types" -maxdepth 1 -name '*.md' -delete
rm -f "${SKILL_DIR}/scope.md" "${SKILL_DIR}/checklist.md"

# --- 5. Generate guideline files ---
#
# Iterate the source LaTeX-derived Markdown for ordering and heading
# extraction; read content from the website's already-rendered subpage.

guidelines_index=""
for src in guidelines/_sources/0[1-8]_*.md; do
    [ -e "$src" ] || continue
    heading=$(grep -m1 '^## ' "$src" | sed 's/^## //')
    slug=$(slugify "$heading")
    [ -z "$slug" ] && { echo "warn: no slug for $src" >&2; continue; }
    site_md="guidelines/${slug}/index.md"
    if [ ! -f "$site_md" ]; then
        echo "warn: $site_md missing; run convert-and-merge-sources.sh first" >&2
        continue
    fi
    convert_source "$site_md" "${SKILL_DIR}/guidelines/${slug}.md" guideline
    guidelines_index="${guidelines_index}- [${heading}](guidelines/${slug}.md)\n"
done

# --- 6. Generate study-type files ---

study_types_index=""
for src in study-types/_sources/0[2-9]_*.md study-types/_sources/1[0-1]_*.md; do
    [ -e "$src" ] || continue
    heading=$(grep -m1 '^## ' "$src" | sed 's/^## //')
    slug=$(slugify "$heading")
    [ -z "$slug" ] && { echo "warn: no slug for $src" >&2; continue; }
    site_md="study-types/${slug}/index.md"
    if [ ! -f "$site_md" ]; then
        echo "warn: $site_md missing; run convert-and-merge-sources.sh first" >&2
        continue
    fi
    convert_source "$site_md" "${SKILL_DIR}/study-types/${slug}.md" study-type
    display=$(echo "$heading" | sed 's/^Introduction: //')
    study_types_index="${study_types_index}- [${display}](study-types/${slug}.md)\n"
done

# --- 7. Generate scope.md and checklist.md ---

convert_source "scope/index.md"     "${SKILL_DIR}/scope.md"     root
convert_source "checklist/index.md" "${SKILL_DIR}/checklist.md" root

# --- 8. Fill placeholders ---
#
# The SKILL.md template lives in the website repo at `_skill/SKILL.md.template`
# (a build-time artifact that should not ship in the consumer-facing skill repo).
# The rendered SKILL.md is written into the skill submodule. plugin.json and
# marketplace.json are committed in the skill repo with concrete version
# strings; we rewrite the version field in place each run.

TEMPLATE="${ROOT}/_skill/SKILL.md.template"
if [ ! -e "$TEMPLATE" ]; then
    echo "error: $TEMPLATE missing" >&2
    exit 1
fi

GUIDELINES_INDEX=$(printf '%b' "$guidelines_index")
STUDY_TYPES_INDEX=$(printf '%b' "$study_types_index")
export VERSION GUIDELINES_INDEX STUDY_TYPES_INDEX
perl -CSD -pe '
    s/\{\{VERSION\}\}/$ENV{VERSION}/g;
    s/\{\{GUIDELINES_INDEX\}\}/$ENV{GUIDELINES_INDEX}/g;
    s/\{\{STUDY_TYPES_INDEX\}\}/$ENV{STUDY_TYPES_INDEX}/g;
' "$TEMPLATE" > "${SKILL_DIR}/SKILL.md"

for f in "${PLUGIN_DIR}/.claude-plugin/plugin.json" "${SKILL_REPO}/.claude-plugin/marketplace.json"; do
    [ -e "$f" ] || continue
    perl -CSD -i -pe 's/("version"\s*:\s*)"[^"]*"/$1"$ENV{VERSION}"/g;' "$f"
done

echo "$VERSION" > "${SKILL_REPO}/VERSION"

echo "skill bundle written to ${SKILL_DIR}"
echo "to publish: cd llm-guidelines-skill && git add -A && git commit && git push"
