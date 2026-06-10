# Short titles for study types and guidelines.
#
# Maps a study-type or guideline full heading (the first `## ` line of its
# source) to its short title. The short title is the single source of truth
# for two things: the Jekyll nav label and the URL slug stem of the page
# (slugify(short_title) gives the subpage directory name, e.g. "Declare Usage"
# -> /guidelines/declare-usage/). Headings with no entry keep their full text
# as both label and slug (e.g. "Advantages and Challenges", scope, checklist).
#
# Sourced by convert-and-merge-sources.sh (page generation) and
# generate-skill.sh (skill-bundle reference filenames) so both agree on the
# slug. Keep the cross-reference macros in the paper's shared-header.tex
# (website branch) pointing at the same slugs.

short_title() {
    case "$1" in
        "Declare LLM Usage and Role")                              echo "Declare Usage" ;;
        "Report Model Version, Configuration, and Customizations") echo "Model Version" ;;
        "Report System and Prompt Design")                         echo "Design" ;;
        "Report Session Traces")                                   echo "Traces" ;;
        "Use Suitable Baselines, Benchmarks, and Metrics")         echo "Benchmarks & Metrics" ;;
        "Use an Open LLM as a Baseline")                           echo "Open LLM" ;;
        "Use Human Validation for LLM Outputs")                    echo "Human Validation" ;;
        "Report Limitations and Mitigations")                      echo "Limitations" ;;
        "LLMs as Annotators")                                      echo "Annotators" ;;
        "LLMs as Judges")                                          echo "Judges" ;;
        "LLMs for Synthesis")                                      echo "Synthesis" ;;
        "LLMs as Subjects")                                        echo "Subjects" ;;
        "Studying LLM Usage in Software Engineering")              echo "Usage" ;;
        "LLMs for New Software Engineering Tools")                 echo "Tools" ;;
        "Benchmarking LLMs for Software Engineering Tasks")        echo "Benchmarking" ;;
        "LLMs as Tools for Software Engineering Researchers")      echo "LLMs for Research" ;;
        "LLMs as Tools for Software Engineers")                    echo "LLMs for SE" ;;
        *)                                                         echo "$1" ;;
    esac
}

# Retired URL slugs, keyed by the CURRENT short title. When a short title
# changes, the previously published slug goes here (space-separated when
# several accumulate) so convert-and-merge-sources.sh emits a
# jekyll-redirect-from alias and the old URL keeps resolving.
old_slugs() {
    case "$1" in
        "Benchmarks & Metrics") echo "benchmarks" ;;
        "Benchmarking")         echo "benchmarks" ;;
        *)                      echo "" ;;
    esac
}
