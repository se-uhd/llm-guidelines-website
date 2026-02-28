# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

A Jekyll + Just the Docs website publishing community guidelines for reporting empirical studies in software engineering involving LLMs. Content is authored in LaTeX, converted to Markdown via pandoc, and deployed to GitHub Pages at https://llm-guidelines.org.

## Build & Development Commands

**Prerequisites:** Ruby 3.4, pandoc 3.6 (pinned in `mise.toml`), texlive-full (installed via CI)

```bash
gem install bundler jekyll    # one-time setup
bundle install                # install gem dependencies

./compile-latex.sh            # compile LaTeX (validates .tex files)
./convert-and-merge-sources.sh  # convert LaTeX → Markdown, merge into index.md files
bundle exec jekyll serve      # local dev server at http://localhost:4000/
bundle exec jekyll build      # build static site to _site/
```

**Typical workflow:** Edit `.tex` files → `./compile-latex.sh` → `./convert-and-merge-sources.sh` → `bundle exec jekyll serve`

## Content Pipeline

LaTeX source files (`_sources/` directories) → pdflatex + bibtex → pandoc conversion → merged Markdown `index.md` files → Jekyll rendering

**Critical rule:** Only edit `.tex` files in `_sources/` directories. Never edit generated Markdown files (`scope/index.md`, `study-types/index.md`, `guidelines/index.md`) — they are overwritten on every conversion and not version-controlled.

## Repository Structure

- `scope/_sources/` — Motivation and scope LaTeX sources
- `study-types/_sources/` — Study type taxonomy LaTeX sources
- `guidelines/_sources/` — Eight guideline LaTeX sources plus a TL;DR summary
- `header.tex` — Shared LaTeX preamble included by all `.tex` files (custom commands, packages)
- `literature.bib` — Central bibliography (use DBLP BibTeX entries when available; check for existing entries before adding)
- `_config.yml` — Jekyll configuration (theme, search, callouts, footer)
- `.github/workflows/` — CI validates LaTeX on PRs; auto-deploys on merge to main

## LaTeX Conventions

**Custom commands defined in `header.tex`:**
- Editorial: `\todo{...}`, `\comment{...}`
- RFC 2119 keywords: `\must`, `\mustnot`, `\should`, `\shouldnot`, `\may`
- Reporting location: `\paper`, `\supplementarymaterial`
- Cross-references: Use custom `\href`-based commands (e.g., `\scope`, `\guidelines`, `\annotators`, `\modelversion`) — do NOT use standard `\label{}`/`\ref{}` as they won't render correctly on the website

**Citations:** Use `\cite{}` and `\citeauthor{}` with entries from `literature.bib`.

**Section headings:** Use the custom commands `\guidelinesubsubsection{}`, `\studytypesubsection{}`, `\studytypeparagraph{}`, `\scopeparagraph{}` instead of raw LaTeX sectioning commands.

## Git Workflow

Direct pushes to main are disabled. Use branches and pull requests. The CI workflow validates LaTeX compilation and conversion on PRs before merge.

Study types reference guidelines, not the other way around. To connect a study type with a guideline, update the study type subsection in the corresponding guideline.
