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
# Layout produced in the skill submodule (single skill, two modes):
#
#   plugins/llm-guidelines/
#     skills/
#       llm-guidelines/
#         SKILL.md             router with shared frontmatter, mode-selection,
#                              shared constraints, and the file indices
#         references/
#           explore.md         explore-mode procedure (loaded by SKILL.md)
#           review.md          review-mode procedure (loaded by SKILL.md)
#           guidelines/        the eight guideline files
#           study-types/       the study-type taxonomy files
#           scope.md           scope statement
#           checklist.md       consolidated reporting checklist
#
# The two slash commands (commands/explore.md, commands/review.md) point at
# the same skill and hint which mode to enter.
#
# Does not commit or push; the user reviews and commits in the submodule manually.

set -e

ROOT="$(pwd)"
SKILL_REPO="${ROOT}/llm-guidelines-skill"
PLUGIN_DIR="${SKILL_REPO}/plugins/llm-guidelines"
SKILLS_DIR="${PLUGIN_DIR}/skills"
SKILL_DIR="${SKILLS_DIR}/llm-guidelines"
REFS_DIR="${SKILL_DIR}/references"

if [ ! -d "${SKILL_REPO}/.claude-plugin" ]; then
    echo "error: ${SKILL_REPO} is not initialized; run 'git submodule update --init' first" >&2
    exit 1
fi

# --- 1. Resolve the skill version ---
#
# Guideline version: parsed from the paper-tag URL in `_config.yml`
# (the URL form is more stable than the HTML icon label that sits in the
# same block). Bumped when the paper repo gets a new CalVer tag.
#
# Skill revision: read from `_skill/REVISION` (a single integer). Bumped
# independently for skill-only changes (SKILL.md edits, command tweaks,
# layout changes) against the same guideline version. Reset to 0 on a
# guideline-version bump.
#
# Combined skill version: `YYYY.MM` when revision is 0, else `YYYY.MM_revN`.

GUIDELINE_VERSION=$(perl -ne 'if (m{llm-guidelines-paper/tree/(\d{4}\.\d{2})}) { print $1; exit }' "${ROOT}/_config.yml")
if [ -z "$GUIDELINE_VERSION" ]; then
    echo "error: could not extract CalVer from _config.yml" >&2
    exit 1
fi

REVISION=$(tr -d '[:space:]' < "${ROOT}/_skill/REVISION" 2>/dev/null || echo 0)
case "$REVISION" in
    ''|*[!0-9]*)
        echo "error: _skill/REVISION must be a non-negative integer (got: '$REVISION')" >&2
        exit 1
        ;;
esac

if [ "$REVISION" = "0" ]; then
    VERSION="$GUIDELINE_VERSION"
else
    VERSION="${GUIDELINE_VERSION}_rev${REVISION}"
fi
echo "skill version: ${VERSION} (guideline ${GUIDELINE_VERSION}, revision ${REVISION})"

# --- 2. Slug derivation (mirrors convert-and-merge-sources.sh) ---

slugify() {
    echo "$1" | perl -CSD -pe '
        $_ = lc $_;
        s/[^a-z0-9 -]//g;
        s/\s+/-/g;
        s/-{2,}/-/g;
        s/^-|-$//g;
    '
}

# --- 3. Convert a website-rendered Markdown page into a references file ---
#
# Strips Jekyll front matter and any inline <style>/<script>/<button> blocks
# (the checklist embeds these for client-side state and CSV export); rewrites
# website-absolute links to paths relative to the file's location inside
# `references/` (guidelines and study-types files sit one directory deep so
# their cross-links use `../`; files at the `references/` root use `./`).
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
        use utf8;
        s/^---\n.*?\n---\n\s*//s;
        s{<style>.*?</style>\s*}{}gs;
        s{<script>.*?</script>\s*}{}gs;
        s{<button[^>]*>.*?</button>\s*}{}gs;
        s{<details id="condition-filters".*?</details>\s*}{}gs;
        # Wrap the bracketed condition slug in backticks so it renders as
        # inline code in the skill bundle. Without backticks, [fine-tuning]
        # is a CommonMark shortcut reference link: any matching [slug]: URL
        # definition (now or later) would silently turn the tag into a link.
        s{<span class="condition" data-condition="[^"]+">(\[[^\]]+\])</span>}{`$1`}g;
        # Rewrite the intro paragraph sentence about ●/○ markers to a
        # skill-only phrasing (no ● glyphs, no marker-should span). This
        # must run before the generic should-span substitution below so it
        # can match the original sentence containing the span. \h+ matches
        # horizontal whitespace including the NBSP that pandoc emits in
        # place of the LaTeX \xspace after each marker.
        s{Items marked ●\h+are requirements \(\*\*must\*\*\), and items marked <span class="marker-should">●</span>\h+are recommendations \(\*\*should\*\*\)\.}{Items prefixed with **must** are requirements; items prefixed with **should** are recommendations.};
        # Rewrite the intro paragraph sentence about bracketed tags / the
        # filter panel to reflect the skill-bundle representation
        # (backticked tags) and drop the website-only filter-panel mention.
        # This regex must match POST-chip-backticking text (the substitution
        # above this one already wrapped the chips in backticks).
        s{Items prefixed with a bracketed tag apply only to studies with that characteristic \(e\.g\., `\[fine-tuning\]`, `\[agents\]`\)\. Readers can hover each tag to read its description and use the filter panel to hide items that do not apply to their study\.}{Items prefixed with a backticked tag (e.g., `[fine-tuning]`, `[agents]`) apply only to studies with that characteristic.};
        # Replace the should-marker bullet on remaining list items with the
        # literal **should** prefix. The optional \h after the span eats
        # the NBSP that follows, so the output uses a regular space.
        s{<span class="marker-should">[^<]*</span>\h?}{**should** }g;
        # Replace the must-marker bullet on list items with the literal
        # **must** prefix. ● appears as a list bullet only on must items
        # in the checklist; the intro mention has already been rewritten.
        # \h+ tolerates the NBSP from \xspace.
        s{^- ●\h+}{- **must** }gm;
        # Pandoc wraps acronyms or title-case fragments in <span class="nocase">
        # so bibliography styles do not lowercase them. The class has no
        # meaning in the skill bundle; keep the inner text only.
        s{<span class="nocase">([^<]*)</span>}{$1}g;
        # Pandoc renders inline math via codecogs PNG image references by
        # default. The image title attribute carries the original LaTeX;
        # replace the image reference with that LaTeX inside $...$ so the
        # skill consumer sees the source, not an unfetchable image URL.
        s{!\[[^\]]*\]\(https://latex\.codecogs\.com/png\.latex\?[^)\s]+ "([^"]+)"\)}{\$$1\$}g;
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

# --- 4. Wipe old layout and recreate target directories ---
#
# Transition cleanup: previous layouts placed content under
# skills/llm-guidelines/ directly (very old), or split into skills/explore/
# + skills/review/ + shared/ (intermediate). Remove all three so we don't
# ship stale content alongside the current single-skill layout.

rm -rf "${PLUGIN_DIR}/shared" "${SKILLS_DIR}/explore" "${SKILLS_DIR}/review"

mkdir -p "${REFS_DIR}/guidelines" "${REFS_DIR}/study-types"
find "${REFS_DIR}/guidelines" -maxdepth 1 -name '*.md' -delete
find "${REFS_DIR}/study-types" -maxdepth 1 -name '*.md' -delete
rm -f "${REFS_DIR}/scope.md" "${REFS_DIR}/checklist.md"
rm -f "${REFS_DIR}/explore.md" "${REFS_DIR}/review.md"
rm -f "${SKILL_DIR}/SKILL.md"

# --- 5. Generate guideline files ---
#
# Iterate the source LaTeX-derived Markdown for ordering and heading
# extraction; read content from the website's already-rendered subpage.
# Index entries are emitted relative to SKILL.md, which sits one level
# above references/, so the prefix is `references/`.

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
    convert_source "$site_md" "${REFS_DIR}/guidelines/${slug}.md" guideline
    guidelines_index="${guidelines_index}- [${heading}](references/guidelines/${slug}.md)\n"
done

# --- 6. Generate study-type files ---
#
# Same two-level structure as the website nav: each parent's children are
# indented in the index so the consuming agent sees the taxonomy at a glance.
# File numbering encodes structure (see convert-and-merge-sources.sh comments).

emit_study_type() {
    src=$1
    indent=$2
    [ -e "$src" ] || return 0
    heading=$(grep -m1 '^## ' "$src" | sed 's/^## //')
    slug=$(slugify "$heading")
    [ -z "$slug" ] && { echo "warn: no slug for $src" >&2; return 0; }
    site_md="study-types/${slug}/index.md"
    if [ ! -f "$site_md" ]; then
        echo "warn: $site_md missing; run convert-and-merge-sources.sh first" >&2
        return 0
    fi
    convert_source "$site_md" "${REFS_DIR}/study-types/${slug}.md" study-type
    study_types_index="${study_types_index}${indent}- [${heading}](references/study-types/${slug}.md)\n"
}

study_types_index=""

# Group 1: parent + four children
for src in study-types/_sources/02_*.md; do emit_study_type "$src" ""; done
for prefix in 03 04 05 06; do
    for src in study-types/_sources/${prefix}_*.md; do emit_study_type "$src" "    "; done
done

# Group 2: parent + three children
for src in study-types/_sources/07_*.md; do emit_study_type "$src" ""; done
for prefix in 08 09 10; do
    for src in study-types/_sources/${prefix}_*.md; do emit_study_type "$src" "    "; done
done

# Cross-cutting sibling
for src in study-types/_sources/11_*.md; do emit_study_type "$src" ""; done

# --- 7. Generate scope.md and checklist.md ---

convert_source "scope/index.md"     "${REFS_DIR}/scope.md"     root
convert_source "checklist/index.md" "${REFS_DIR}/checklist.md" root

# --- 8. Render SKILL.md and the two mode reference files ---
#
# Templates live in the website repo under `_skill/` (build-time artifacts
# that should not ship in the consumer-facing skill repo). SKILL.md is the
# router; references/{explore,review}.md hold the mode-specific procedures.

GUIDELINES_INDEX=$(printf '%b' "$guidelines_index")
STUDY_TYPES_INDEX=$(printf '%b' "$study_types_index")
export VERSION GUIDELINES_INDEX STUDY_TYPES_INDEX

substitute_template() {
    src=$1
    dst=$2
    if [ ! -e "$src" ]; then
        echo "error: $src missing" >&2
        exit 1
    fi
    perl -CSD -pe '
        s/\{\{VERSION\}\}/$ENV{VERSION}/g;
        s/\{\{GUIDELINES_INDEX\}\}/$ENV{GUIDELINES_INDEX}/g;
        s/\{\{STUDY_TYPES_INDEX\}\}/$ENV{STUDY_TYPES_INDEX}/g;
    ' "$src" > "$dst"
}

mkdir -p "${SKILL_DIR}"
substitute_template "${ROOT}/_skill/SKILL.md.template"              "${SKILL_DIR}/SKILL.md"
substitute_template "${ROOT}/_skill/references-explore.md.template" "${REFS_DIR}/explore.md"
substitute_template "${ROOT}/_skill/references-review.md.template"  "${REFS_DIR}/review.md"

# --- 9. Stamp version into manifests and VERSION ---
#
# plugin.json and marketplace.json are committed in the skill repo with
# concrete version strings; we rewrite the version field in place each run.

for f in "${PLUGIN_DIR}/.claude-plugin/plugin.json" "${SKILL_REPO}/.claude-plugin/marketplace.json"; do
    [ -e "$f" ] || continue
    perl -CSD -i -pe 's/("version"\s*:\s*)"[^"]*"/$1"$ENV{VERSION}"/g;' "$f"
done

echo "$VERSION" > "${SKILL_REPO}/VERSION"

# --- 10. Render skill/index.md (website) and README.md (skill repo) ---
#
# Both files share the literal slash-command and install-command strings.
# `_skill/commands.env` is the single source of truth for those literals;
# both templates reference them as {{CMD_*}} placeholders. Editing a value
# in commands.env propagates to both rendered files on the next run.

. "${ROOT}/_skill/commands.env"
export CMD_MARKETPLACE_ADD CMD_PLUGIN_INSTALL \
       CMD_MARKETPLACE_UPDATE CMD_RELOAD_PLUGINS \
       CMD_INVOKE_EXPLORE CMD_INVOKE_REVIEW \
       CMD_INVOKE_REVIEW_TEX CMD_INVOKE_REVIEW_PDF CMD_INVOKE_REVIEW_SUPP

render_with_commands() {
    src=$1
    dst=$2
    perl -CSD -pe '
        s/\{\{CMD_MARKETPLACE_ADD\}\}/$ENV{CMD_MARKETPLACE_ADD}/g;
        s/\{\{CMD_PLUGIN_INSTALL\}\}/$ENV{CMD_PLUGIN_INSTALL}/g;
        s/\{\{CMD_MARKETPLACE_UPDATE\}\}/$ENV{CMD_MARKETPLACE_UPDATE}/g;
        s/\{\{CMD_RELOAD_PLUGINS\}\}/$ENV{CMD_RELOAD_PLUGINS}/g;
        s/\{\{CMD_INVOKE_EXPLORE\}\}/$ENV{CMD_INVOKE_EXPLORE}/g;
        s/\{\{CMD_INVOKE_REVIEW\}\}/$ENV{CMD_INVOKE_REVIEW}/g;
        s/\{\{CMD_INVOKE_REVIEW_TEX\}\}/$ENV{CMD_INVOKE_REVIEW_TEX}/g;
        s/\{\{CMD_INVOKE_REVIEW_PDF\}\}/$ENV{CMD_INVOKE_REVIEW_PDF}/g;
        s/\{\{CMD_INVOKE_REVIEW_SUPP\}\}/$ENV{CMD_INVOKE_REVIEW_SUPP}/g;
    ' "$src" > "$dst"
    if grep -q '{{CMD_' "$dst"; then
        leftover=$(grep -o '{{CMD_[A-Z_]*}}' "$dst" | sort -u | tr '\n' ' ')
        echo "error: unresolved placeholder(s) in $dst: $leftover" >&2
        echo "       add the missing variable(s) to _skill/commands.env" >&2
        exit 1
    fi
}

render_with_commands "${ROOT}/_skill/skill-index.md.template" "${ROOT}/skill/index.md"
render_with_commands "${ROOT}/_skill/README.md.template"      "${SKILL_REPO}/README.md"

echo "skill bundle written to ${PLUGIN_DIR}"
echo "to publish: cd llm-guidelines-skill && git add -A && git commit && git push"
