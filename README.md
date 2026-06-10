# LLM Guidelines Website

This website is built using [Jekyll](https://jekyllrb.com/), [Just the Docs](https://just-the-docs.github.io/just-the-docs/), and [GitHub Pages](https://pages.github.com/).
Changes are made to Latex files, which are then converted to Markdown and rendered on the website.

## Local testing

You can test changes to the website locally as follows:

1. Either install `ruby`, `pandoc`, and a TeX distribution directly or using [mise](https://mise.jdx.dev/) (see [mise.toml](https://github.com/se-uhd/llm-guidelines-website/blob/main/mise.toml)). If you're on Windows, we suggest using [WSL](https://learn.microsoft.com/en-us/windows/wsl/install).
2. Run `gem install bundler jekyll`.
3. Run `bundle install` in the root directory of this repo.
4. Run `git submodule update --init` to populate both submodules: the [paper repo](https://github.com/se-uhd/llm-guidelines-paper) (authoritative content) and the [skill repo](https://github.com/se-uhd/llm-guidelines-skill) (Agent Skill distribution target).
5. Run `./compile-latex.sh` to validate that the LaTeX entry points still compile.
6. Run `./convert-and-merge-sources.sh` to convert the LaTeX files to Markdown.
7. Run `bundle exec jekyll serve` to host the website locally.
8. Open `http://localhost:4000/` in your browser.

When you change the LaTeX and convert them to Markdown, the local version of the website will automatically refresh (this does not apply to changes in the [configuration](https://github.com/se-uhd/llm-guidelines-website/blob/main/_config.yml), which you as a contributor usually don't need to modify).
Do not modify the converted Markdown files, as your changes will be lost after the next conversion.
The converted files are also not versioned, as they are generated when the website is deployed using a GitHub Actions workflow (see below).

Once you push your changes to the `main` branch or once a pull request is merged, the website is automatically redeployed via a GitHub Actions [workflow](https://github.com/se-uhd/llm-guidelines-website/blob/main/.github/workflows/build-and-deploy.yml), which you can monitor [here](https://github.com/se-uhd/llm-guidelines-website/actions).

You are free to use any LaTeX editor you like.
To double-check the generated Markdown files, you can use any Markdown editor you like, preferably one that supports [kramdown](https://kramdown.gettalong.org/), which is the [default Markdown renderer for Jekyll](https://jekyllrb.com/docs/configuration/markdown/#kramdown).

If you add references to [literature.bib](https://github.com/se-uhd/llm-guidelines-paper/blob/main/literature.bib), please use the [DBLP](https://dblp.org/) Bibtex entries, if available.

## Skill bundle

`./convert-and-merge-sources.sh` ends by invoking `./generate-skill.sh` if `llm-guidelines-skill/` is initialized. That script regenerates the [Agent Skill](https://agentskills.io/home) bundle inside the skill submodule. The skill version, plugin manifest, and marketplace entry are all stamped from the CalVer tag in `_config.yml`. The script does not commit; review the diff under `llm-guidelines-skill/` and commit/push there manually, then bump the submodule pointer in this repo.

The skill landing page is at [`/skill/`](https://llm-guidelines.org/skill/) and links to install instructions, downloads, and the source files in the skill repository.

## Versioning

Guidelines are versioned with date-based tags (CalVer, `YYYY.MM`) on the [paper repo](https://github.com/se-uhd/llm-guidelines-paper). The current version is shown in the top-right of the website, left of the GitHub link, and links to the tagged sources. The skill bundle inherits the same tag. To publish a new version:

1. In `llm-guidelines-paper/`, tag the target commit: `git tag YYYY.MM <sha>` and `git push --tags`.
2. In this repo, bump the paper submodule pointer to that commit: `git submodule update --remote llm-guidelines-paper` (or check out the tag inside the submodule).
3. Update `_config.yml` `aux_links`: replace both occurrences of the old `YYYY.MM` (label and URL) with the new tag.
4. Run `./compile-latex.sh && ./convert-and-merge-sources.sh` to regenerate website pages and the skill bundle.
5. In `llm-guidelines-skill/`, review the diff, commit with the new tag, push, and tag the commit `YYYY.MM` there as well.
6. Bump the skill submodule pointer in this repo and open a PR.

## Information for authors

* Edit content in the [paper repo](https://github.com/se-uhd/llm-guidelines-paper) (`_guidelines/`, `_studytypes/`, `_scope/`, `_tldr/`, `literature.bib`), not in this repo. The website pulls these in via the `llm-guidelines-paper/` git submodule.
* Apply the prose conventions in [`llm-guidelines-paper/WRITING.md`](https://github.com/se-uhd/llm-guidelines-paper/blob/main/WRITING.md) to any prose you write or edit (banned and restricted words, em-dash budget, citation grounding, statistical formatting).
* Custom LaTeX commands live in [`shared-header.tex`](https://github.com/se-uhd/llm-guidelines-paper/blob/main/shared-header.tex) (paper repo) and [`header-website.tex`](https://github.com/se-uhd/llm-guidelines-website/blob/main/header-website.tex) (website repo). Use `\todo{...}` for editorial notes. For recommendation strength, use the RFC 2119 macros (`\must`, `\mustnot`, `\should`, `\shouldnot`) defined in the shared header.
* Before adding new references to [`literature.bib`](https://github.com/se-uhd/llm-guidelines-paper/blob/main/literature.bib), check whether the entry already exists (search for parts of the title) and prefer [DBLP](https://dblp.org/) BibTeX entries when available.
* Before pushing changes, validate locally that the modified LaTeX still compiles (`./compile-latex.sh`) and that the conversion runs cleanly (`./convert-and-merge-sources.sh`).
* Study types reference guidelines, not the other way around. To connect a study type with a guideline, update the study type subsection in the corresponding guideline.
* Outside contributors should open pull requests against `main`. Maintainers may push directly.
* Cite entries from `literature.bib` with the standard `\cite{}` and `\citeauthor{}` commands. To refer to other sections of the study types and guidelines, do *not* use `\label{}` / `\ref{}` (those won't render on the website); use the cross-reference macros defined in [`shared-header.tex`](https://github.com/se-uhd/llm-guidelines-paper/blob/main/shared-header.tex) (e.g., `\scope`, `\studytypes`, `\guidelines`, `\annotators`, `\design`).
