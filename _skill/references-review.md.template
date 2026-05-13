# Review Mode

This file is loaded by `../SKILL.md` when the user wants a concrete draft assessed against the guidelines (slash command `/llm-guidelines:review`, or when the user names a paper / hands a path to `.tex` or `.pdf` / asks to check / audit / review a draft). For the audience, tone, mode-selection rules, shared constraints, and full file indices, see [`../SKILL.md`](../SKILL.md).

## When to use

Stay in review mode when the user:

1. Asks to check a paper (or paper plus supplementary material) against the LLM reporting guidelines.
2. Is drafting the methodology, results, or limitations of an empirical study involving an LLM and wants reporting suggestions on a concrete draft.
3. Is reviewing such a paper and asks for clarifying questions to consider.

If the user is still planning a study or asking conceptual questions, switch to explore mode and follow [`./explore.md`](./explore.md).

## Inputs the user will provide

The user typically provides one or more of:

- A path to the paper. Both forms are supported:
  - A LaTeX source file (`.tex`): read it directly and follow `\input{}`/`\include{}` for files inside the project tree. A flattened `.tex` works the same way.
  - A PDF (`.pdf`): extract text using whatever tool is available in the environment (e.g., `pdftotext`, `mutool draw -F txt`, or a Python library). If no extractor is available, tell the user which one to install rather than failing silently.
  When both are available, prefer the LaTeX source: it lets you spot LaTeX-specific artifacts (e.g., commented-out disclosures, `\todo{}` notes) that get lost in the PDF.
- One or more pointers to supplementary material with prompts, traces, datasets, code, or replication packages. Each can be a local directory, a local repository, or a public URL (e.g., a GitHub repo or a Zenodo record). For URLs, **clone or download the artifact locally and read its files directly**; do not characterise the artifact from a `WebFetch` summary of its landing page (see workflow step 1).

If no paper path is supplied, ask the user for one before proceeding. Supplementary paths are optional: if the user omits them, search the paper itself for links to replication packages, datasets, prompts, traces, or code (see workflow step 1).

## Workflow

1. **Resolve inputs.** For a LaTeX paper, read the entry-point file and follow `\input{}`/`\include{}` for files inside the project tree. For a PDF paper, extract text with a tool available in the environment (`pdftotext`, `mutool`, `pdfminer.six`, etc.). For supplementary directories, start with the top-level `README*` or `INDEX*` and the directory layout to orient yourself, then read whatever the layout points at as relevant: prompts, traces, datasets, code, replication scripts. Drill deeper only where the structure suggests evidence for a guideline; do not try to read every file in a large package.

    **Search the paper for supplementary-material links** even when the user has supplied supplementary paths, and especially when they have not. Look across the abstract, introduction, methodology, data-availability / artifact-availability statements, footnotes, acknowledgments, appendices, and the references list for URLs that point to replication packages, datasets, code, prompts, or traces. Common hosts include `github.com`, `gitlab.com`, `zenodo.org`, `figshare.com`, `huggingface.co`, `anonymous.4open.science`, and institutional archives; also check for DOIs (`doi.org/10.5281/...`) and any sentence containing phrases such as "available at", "we release", "we open-source", "replication package", "artifact", or "supplementary material". Record every link you find and the surrounding sentence. If the paper claims to release something but does not anchor the claim to a concrete URL, note the unanchored claim too. The findings populate the *Supplementary material availability* section of the report (see template).

    **Fetch every supplementary URL locally and inspect the actual files.** Confirming that a link resolves is necessary but **not sufficient**. For each URL found in the paper or supplied by the user, materialise it on disk before saying anything about its contents:

    - **Git repositories** (`github.com`, `gitlab.com`, `bitbucket.org`, `anonymous.4open.science`, institutional GitLabs): `git clone --depth 1 <url> <local-path>`. If the default branch fails because the URL points at a specific branch or tag, retry with `--branch`. For GitHub specifically, `gh repo clone` works too when the `gh` CLI is available.
    - **Zenodo / Figshare / Hugging Face datasets / institutional archives**: download the archive (`curl -L -O`, `wget`, or the host's API) and extract it (`unzip`, `tar -xzf`). Hugging Face repos can also be cloned via `git clone https://huggingface.co/<owner>/<repo>` (LFS may be required).
    - **arXiv source tarballs** (when the paper is on arXiv): `curl -sL -o source.tar.gz https://arxiv.org/src/<id>` then `tar -xzf source.tar.gz`. This often contains the LaTeX source plus prompt/figure files not visible in the PDF.
    - **Direct file URLs** (PDFs, JSON datasets, CSVs): `curl -L -O` and inspect with the appropriate tool.

    Once the artifact is on disk, read it with `Read`, `Bash` (e.g., `ls`, `find`, `wc -l`, `grep`), or the language-appropriate tool. **Cite specific paths in the report**, the same way you cite paper sections — e.g., "`prompts/judge_prompt.txt:1-40`" for a text file with meaningful line ranges, or just "`benchmark/python_api_usage/instance_0042.json`" (or the path plus a key, e.g., `... → .golden_completion`) for a binary/structured data file where line ranges do not apply. A finding such as "the repo includes prompts" must be backed by a file that was actually read, not by a model rendering of the repo's GitHub landing page.

    **Do not use `WebFetch` to characterise a code repository, dataset archive, or replication package.** `WebFetch` summarises a rendered HTML page (typically the host's directory-listing UI), not the files inside. Relying on it produces hedged language like *"the repo appears to include …"*, which is exactly the failure this step is designed to prevent. `WebFetch` remains appropriate for: (a) confirming that a URL resolves at all; (b) reading a hosted blog post, paper landing page, or other genuinely web-only content that has no underlying file to fetch.

    **When fetching genuinely fails**, say so explicitly in the report — name the URL, the failure mode (404, archive corrupt, repo private, auth/approval wall, rate limit, LFS pull failed, network blocked), and what is therefore unverified. Do not paper over the gap with a `WebFetch` summary.

2. **Identify the study type(s).** Use the files under `./study-types/` to classify the study. A single paper can fall under multiple types (e.g., a new tool that also benchmarks LLMs). Note the classification at the top of the report.

3. **Consult [`./scope.md`](./scope.md)** to confirm the work is in scope. The guidelines cover LLM use that materially affects the research method or its outcomes; peripheral uses (proofreading, spell-checking, translation, writing assistance) are explicitly out of scope, even though venue policies such as the ACM Policy on Authorship may still require an author-writing disclosure separately.

4. **Per-guideline assessment.** For each of the eight guidelines listed in [`../SKILL.md`](../SKILL.md), load the corresponding file in `./guidelines/` on demand, then for that guideline produce:
   - `Status`: one of `covered`, `partial`, `not found`, or `not applicable` (with a one-line reason if N/A).
   - `Evidence`: 1 to 3 items, each a **verbatim quote** from the paper or supplementary material (or, for binary/structured data files, a direct file-or-key pointer), with its source location (e.g., `_s4_evaluation.tex:34` or `benchmark/python/api_usage/instance_0042.json`). Do not paraphrase. See the *Constraints* section for the full grounding rule.
   - `Gaps`: bullet list of specific missing items (`must`/`should`-level), each phrased as an author-facing suggestion (e.g., "Consider naming the exact model version and access date in the methodology."). Each gap's premise must be supported either by an Evidence item above or by a verified absence (state what you searched for and how, e.g., "`grep -i 'experiment date' _s*.tex` returned no hit").
   - `Pointers`: links to the relevant section(s) of the consulted guideline file.

   Apply the RFC 2119 levels from the guideline text: **must** items become "required for full reporting"; **should** items become "recommended". Do not invent severity levels not present in the guideline.

5. **Cross-cutting concerns.** After the per-guideline pass, scan [`./checklist.md`](./checklist.md) for any item that did not surface during step 4 and add it to a `Checklist gaps` section if missing.

6. **Write the report.** Save the assessment as `llm-guidelines-report.md` in the user's current working directory **and** print the same content to the console. Use the [report template](#report-template) below.

    Then run `python3 ${CLAUDE_SKILL_DIR}/scripts/lint_markdown.py --fix llm-guidelines-report.md`. If the linter exits non-zero, read its stdout findings (one per line, tab-separated `<file>:<line>\t<rule>\t<message>`), revise the report in place to address each, and re-run the linter. Repeat at most three iterations; after the third pass proceed regardless of the linter's state. The lint loop is internal quality control — do not mention lint output, rule names, exit codes, or iteration counts in the user-facing summary.

7. **Stop after the report.** Do not modify the user's paper or supplementary material. If the user asks for follow-up edits, treat that as a new request.

## Report template

```markdown
# LLM Guidelines Assessment

**Paper:** <path or title>
**Supplementary material:** <paths>
**Identified study type(s):** <one or more from study-types/>
**Skill version:** <VERSION>

> This report applies the community LLM reporting guidelines from
> <https://llm-guidelines.org> as a self-check for authors. It is not a
> rejection rubric; missing items are reporting gaps to consider, not
> grounds for rejection.

## Summary

<Two-to-four-sentence overall summary: what is reported well, what is missing.>

## Supplementary material availability

<Report what the user provided and what you found in the paper itself:
- User-supplied paths: <list, or "none provided">.
- Links found in the paper: <bulleted list of each URL, with a verbatim quote of the surrounding sentence and its source location (file:line for LaTeX, section/page for PDF). For each URL, state whether it was fetched locally (cloned/downloaded) or only checked for HTTP reachability; if neither was possible, say why.>
- Unanchored release claims: <quote verbatim any "we release" / "available at" / "we open-source" / "publicly available" sentence that does not anchor to a concrete URL, with its source location; this is a reporting gap for the relevant guideline.>
- Coverage: <one sentence on what the fetched supplementary material actually contains, each component anchored to a specific path you read (e.g., "prompts: `prompts/python/api_usage.txt:1-220`; raw completions: `completions/claude-4-sonnet/python_0042.json`; benchmark instances: `benchmark/python/api_usage/`; evaluation code: `execute_benchmark.py`"). If you could not fetch the material, say "not verified — could not fetch" and list the failure mode; do not characterise contents from a `WebFetch` summary.>

If nothing was supplied and nothing was found, say so explicitly and flag it under
the relevant guideline (typically *Report System and Prompt Design* and *Report
Session Traces*).>

## Per-guideline findings

### Declare LLM Usage and Role

- Status: <covered | partial | not found | not applicable>
- Evidence: <1-3 items, each a verbatim quote from the paper or a verbatim excerpt from a file in the supplementary material (or, for binary/structured data files, a direct file-or-key pointer), with source location (e.g., `_s3_realistic.tex:140`, `prompts/judge_prompt.txt:1-12`, or `benchmark/python/api_usage/instance_0042.json`). Do not paraphrase here; gaps and interpretation belong in the Gaps bullet.>
- Gaps: <author-facing bullets; each bullet's premise must be supported by an Evidence item or by an absence you actually checked for (state what you searched and how, e.g., "grep for '\\bdate\\b' across all .tex files returned no experiment date").>
- Pointers: <links to ./guidelines/declare-llm-usage-and-role.md>

<... repeat for each of the remaining guidelines ...>

## Checklist gaps

<Items from ./checklist.md that were not surfaced above.>

## Notes for reviewers

<If invoked by a reviewer, surface 3 to 5 clarifying questions worth asking the
authors. Otherwise omit this section.>
```

## Mode-specific constraints

These add to the shared constraints in [`../SKILL.md`](../SKILL.md):

- **Ground every claim in a verbatim quote or a file pointer.** Every factual statement in the report about what the paper or the supplementary material does, says, contains, or omits **must** be backed by one of: (a) a verbatim quote from the paper with a source location (e.g., `_s4_evaluation.tex:34` or "§4.2, p. 7"), or (b) a pointer to a specific file (or file plus line range / key) in the supplementary material that was actually read (e.g., `prompts/judge_prompt.txt:1-40`, `benchmark/python/instance_0042.json`). Statements that paraphrase or summarise the paper **must** cite the underlying source the same way. **Do not write hedged language** such as *"the repo appears to include …"*, *"the README seems to describe …"*, *"presumably …"*, *"likely contains …"*, *"suggests that …"*, *"indicates that …"*, *"based on the structure …"*, *"it can be inferred …"* — if you cannot back the claim with a verbatim quote or a file pointer, do not make the claim. Instead, state the gap explicitly: name what you tried to verify, what you read, and what is therefore unknown. Absence of evidence is reported as absence, not as a guess.
- **Only quote what you have read.** Quotation marks in the report must contain text that appears verbatim in a source you opened (the paper's `.tex` / extracted PDF text, or a file in the materialised supplementary directory). Do not "quote" a `WebFetch` summary or a rendering of an HTML directory listing — that is paraphrase, not source text. If a quote spans an ellipsis, use `[...]` and keep the rest verbatim.
- **Review mode writes only `llm-guidelines-report.md`** in the working directory. No other user files are touched.
