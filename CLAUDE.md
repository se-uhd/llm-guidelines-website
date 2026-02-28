# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

A Jekyll + Just the Docs website publishing community guidelines for reporting empirical studies in software engineering involving LLMs. Content is authored in LaTeX, converted to Markdown via pandoc, and deployed to GitHub Pages at https://llm-guidelines.org.

The companion paper repo is included as a git submodule at `llm-guidelines-paper/`. **The paper is authoritative** — content tex files, `literature.bib`, and `shared-header.tex` all live in the paper repo. Content files are copied here; `shared-header.tex` is referenced directly from the submodule. After cloning, run `git submodule update --init` to populate it.

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

**Typical workflow:** Edit `.tex` files in the paper repo → copy to website → `./compile-latex.sh` → `./convert-and-merge-sources.sh` → `bundle exec jekyll serve`

## Content Pipeline

LaTeX source files (`_sources/` directories) → pdflatex + bibtex → pandoc conversion → merged Markdown `index.md` files → Jekyll rendering

**Critical rule:** Content tex files (in `_sources/_guidelines/`, `_sources/_studytypes/`, `_sources/_scope/`, `_sources/_tldr/`) and `literature.bib` are copied from the paper repo. Edit them there, not here. Never edit generated Markdown files (`scope/index.md`, `study-types/index.md`, `guidelines/index.md`) — they are overwritten on every conversion and not version-controlled.

## Repository Structure

- `header-website.tex` — Minimal website wrapper (documentclass, geometry, parskip) that inputs `shared-header.tex` from the paper repo
- `scope/_sources/` — Motivation and scope LaTeX sources (entry-point + content from paper)
- `study-types/_sources/` — Study type taxonomy LaTeX sources (entry-point + content from paper)
- `guidelines/_sources/` — Eight guideline LaTeX sources, TL;DR summaries (entry-point + content from paper)
- `literature.bib` — Bibliography (copied from paper repo; use DBLP BibTeX entries when available)
- `_config.yml` — Jekyll configuration (theme, search, callouts, footer)
- `.github/workflows/` — CI validates LaTeX on PRs; auto-deploys on merge to main

## LaTeX Header Architecture

The preamble is split into three files:

1. **`shared-header.tex`** (paper repo root) — All shared packages and commands. Uses `\ifpaper` conditionals for commands that differ between paper and website (RFC 2119 keywords, cross-references, section formatting, icons, framed environment, etc.). No `\documentclass` or `\newif`.
2. **`header-website.tex`** (website root) — Sets `\documentclass{article}`, `\newif\ifpaper` (false), website layout packages (geometry, parskip), then inputs `shared-header.tex` from the paper repo.
3. **Paper's `emse25-llm-guidelines.tex`** — Sets `\newif\ifpaper\papertrue`, loads paper-only packages (tikz, xcolor, mdframed, etc.) before `\input{shared-header.tex}`.

Entry-point files in `_sources/` directories use `\input{../../header-website.tex}`. LaTeX `\input` resolves relative to pdflatex's working directory (the `_sources/` folder), so `../../` reaches the website root. From there, `header-website.tex` references `shared-header.tex` via `../../llm-guidelines-paper/shared-header.tex` (submodule path).

## LaTeX Conventions

**Custom commands defined in `shared-header.tex`:**
- Editorial: `\todo{...}`
- RFC 2119 keywords: `\must`, `\mustnot`, `\should`, `\shouldnot` (paper: small-caps, website: bold)
- Reporting location: `\paper`, `\supplementarymaterial` (paper: italic, website: ALLCAPS)
- Cross-references: `\scope`, `\guidelines`, `\annotators`, `\modelversion`, etc. (paper: `\hyperref` to labels, website: `\href` to URLs) — do NOT use standard `\label{}`/`\ref{}` in content files
- Section formatting: `\guidelinesubsubsection{}`, `\studytypesubsection{}`, `\studytypeparagraph{}`, `\scopeparagraph{}`
- Icons: `\iconM`, `\iconS` (paper: TikZ circles, website: Unicode)
- Framed environment: `\begin{framed}...\end{framed}` (paper: mdframed, website: quote)

**Citations:** Use `\cite{}` and `\citeauthor{}` with entries from `literature.bib`.

## Git Workflow

Direct pushes to main are disabled. Use branches and pull requests. The CI workflow validates LaTeX compilation and conversion on PRs before merge.

Study types reference guidelines, not the other way around. To connect a study type with a guideline, update the study type subsection in the corresponding guideline.
