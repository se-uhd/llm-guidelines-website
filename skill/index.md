---
layout: default
title: Skill
nav_order: 7
---

# Skill

`llm-guidelines` is an [Agent Skill](https://agentskills.io/home) bundle that packages these guidelines for authors to use directly inside an AI coding assistant. It bundles the same content this website renders ([scope](/scope/), [study types](/study-types/), [guidelines](/guidelines/), [checklist](/checklist/)) and provides two modes: **explore** for asking questions, discussing study designs, and deciding which study type fits; and **review** for assessing a paper draft and any supplementary material against the eight guidelines, producing an `llm-guidelines-report.md` for the paper at hand.

Agent Skills is an open standard originally developed by Anthropic. The format is now read by Cursor, GitHub Copilot, OpenAI Codex, Gemini CLI, Claude Code, and JetBrains Junie, among others; see the [client list](https://agentskills.io/clients) for the current set. The instructions below cover Claude Code and Codex CLI; for any other client, copy the `plugins/llm-guidelines/skills/llm-guidelines/` subtree from the repository into the location that client expects (the skill is self-contained: `SKILL.md` plus a `references/` directory with all bundled content). Each client's docs are linked from the client list.

The skill is published in a separate repository at [se-uhd/llm-guidelines-skill](https://github.com/se-uhd/llm-guidelines-skill). Its version reuses the guideline `YYYY.MM` tag shown in the header of this site for releases that match a paper version, and adds a `_revN` suffix for skill-only updates against the same guideline version (see the skill repo `README.md` for details).

## Install in Claude Code

```text
/plugin marketplace add se-uhd/llm-guidelines-skill
/plugin install llm-guidelines
```

## Install in Codex CLI

For regular use, install from the GitHub marketplace source:

```text
codex plugin marketplace add se-uhd/llm-guidelines-skill
codex plugin add llm-guidelines@se-uhd
```

Local path installs are for development because Codex may copy the working tree into its plugin cache.

To pick up a new Codex release:

```text
codex plugin marketplace upgrade se-uhd
codex plugin add llm-guidelines@se-uhd
```

## Invoke

In Claude Code, the bundle exposes two slash commands. In Codex CLI, use natural-language prompts that ask for the same explore or review work.

### Explore the guidelines

Use this when you want to ask a question, plan a study, walk through the checklist, or decide which study type your project falls under, before any draft exists.

```text
/llm-guidelines:explore
```

Codex CLI example:

```text
Which LLM study type fits my planned study?
```

Explore mode is a conversation; it does not write any files unless you ask.

### Review a draft

Use this when you have a draft paper (and optionally supplementary material) and want a structured pass against each of the eight guidelines.

With a LaTeX source:

```text
/llm-guidelines:review path/to/paper.tex
```

Or with a PDF:

```text
/llm-guidelines:review path/to/paper.pdf
```

The supplementary-material path is optional, and you can pass more than one when artifacts live in separate locations (e.g., code on GitHub, data on Zenodo):

```text
/llm-guidelines:review path/to/paper.tex path/to/code-repo path/to/dataset
```

Codex CLI examples:

```text
Review path/to/paper.tex against the LLM reporting guidelines.
Check path/to/paper.pdf and path/to/artifact-dir for reporting gaps.
```

If invoked without arguments, review mode asks for paths to your paper (LaTeX source or PDF) and any supplementary directories. It will not modify your files; it writes its findings to `llm-guidelines-report.md` in your working directory and prints the same content to the console.

### Auto-invocation

The skill can also load itself without an explicit slash command if the agent decides its description matches the task. Once the skill is active, its router branches into explore or review mode based on intent: mentioning a paper path or asking to "check" or "review" a draft selects review mode; asking a question about the guidelines, the study-type taxonomy, or your study design selects explore mode.

## Bundled Files

The bundle ships a set of Markdown files under `plugins/llm-guidelines/skills/llm-guidelines/`.

### Entry points

These files live only in the skill repo:

- [SKILL.md](https://github.com/se-uhd/llm-guidelines-skill/blob/main/plugins/llm-guidelines/skills/llm-guidelines/SKILL.md): skill instructions
- [references/explore.md](https://github.com/se-uhd/llm-guidelines-skill/blob/main/plugins/llm-guidelines/skills/llm-guidelines/references/explore.md): explore mode
- [references/review.md](https://github.com/se-uhd/llm-guidelines-skill/blob/main/plugins/llm-guidelines/skills/llm-guidelines/references/review.md): review mode

### Scope, Checklist, and Matrix

| File | Markdown |
|------|----------|
| [Scope](/scope/) | [references/scope.md](https://github.com/se-uhd/llm-guidelines-skill/blob/main/plugins/llm-guidelines/skills/llm-guidelines/references/scope.md) |
| [Reporting Checklist](/checklist/) | [references/checklist.md](https://github.com/se-uhd/llm-guidelines-skill/blob/main/plugins/llm-guidelines/skills/llm-guidelines/references/checklist.md) |
| [Applicability Matrix](/guidelines/#guidelines-by-study-type) | [references/matrix.md](https://github.com/se-uhd/llm-guidelines-skill/blob/main/plugins/llm-guidelines/skills/llm-guidelines/references/matrix.md) |

### Guidelines

| Guideline | Markdown |
|-----------|----------|
| [Declare LLM Usage and Role](/guidelines/declare-usage/) | [declare-usage.md](https://github.com/se-uhd/llm-guidelines-skill/blob/main/plugins/llm-guidelines/skills/llm-guidelines/references/guidelines/declare-usage.md) |
| [Report Model Version, Configuration, and Customizations](/guidelines/model-version/) | [model-version.md](https://github.com/se-uhd/llm-guidelines-skill/blob/main/plugins/llm-guidelines/skills/llm-guidelines/references/guidelines/model-version.md) |
| [Report System and Prompt Design](/guidelines/design/) | [design.md](https://github.com/se-uhd/llm-guidelines-skill/blob/main/plugins/llm-guidelines/skills/llm-guidelines/references/guidelines/design.md) |
| [Report Session Traces](/guidelines/traces/) | [traces.md](https://github.com/se-uhd/llm-guidelines-skill/blob/main/plugins/llm-guidelines/skills/llm-guidelines/references/guidelines/traces.md) |
| [Use Suitable Baselines, Benchmarks, and Metrics](/guidelines/benchmarks/) | [benchmarks.md](https://github.com/se-uhd/llm-guidelines-skill/blob/main/plugins/llm-guidelines/skills/llm-guidelines/references/guidelines/benchmarks.md) |
| [Use an Open LLM as a Baseline](/guidelines/open-llm/) | [open-llm.md](https://github.com/se-uhd/llm-guidelines-skill/blob/main/plugins/llm-guidelines/skills/llm-guidelines/references/guidelines/open-llm.md) |
| [Use Human Validation for LLM Outputs](/guidelines/human-validation/) | [human-validation.md](https://github.com/se-uhd/llm-guidelines-skill/blob/main/plugins/llm-guidelines/skills/llm-guidelines/references/guidelines/human-validation.md) |
| [Report Limitations and Mitigations](/guidelines/limitations/) | [limitations.md](https://github.com/se-uhd/llm-guidelines-skill/blob/main/plugins/llm-guidelines/skills/llm-guidelines/references/guidelines/limitations.md) |

### Study Types

| Study Type | Markdown |
|------------|----------|
| [LLMs as Tools for Software Engineering Researchers](/study-types/llms-for-research/) | [llms-for-research.md](https://github.com/se-uhd/llm-guidelines-skill/blob/main/plugins/llm-guidelines/skills/llm-guidelines/references/study-types/llms-for-research.md) |
| [LLMs as Annotators](/study-types/annotators/) | [annotators.md](https://github.com/se-uhd/llm-guidelines-skill/blob/main/plugins/llm-guidelines/skills/llm-guidelines/references/study-types/annotators.md) |
| [LLMs as Judges](/study-types/judges/) | [judges.md](https://github.com/se-uhd/llm-guidelines-skill/blob/main/plugins/llm-guidelines/skills/llm-guidelines/references/study-types/judges.md) |
| [LLMs for Synthesis](/study-types/synthesis/) | [synthesis.md](https://github.com/se-uhd/llm-guidelines-skill/blob/main/plugins/llm-guidelines/skills/llm-guidelines/references/study-types/synthesis.md) |
| [LLMs as Subjects](/study-types/subjects/) | [subjects.md](https://github.com/se-uhd/llm-guidelines-skill/blob/main/plugins/llm-guidelines/skills/llm-guidelines/references/study-types/subjects.md) |
| [Advantages and Challenges](/study-types/advantages-and-challenges/) | [advantages-and-challenges.md](https://github.com/se-uhd/llm-guidelines-skill/blob/main/plugins/llm-guidelines/skills/llm-guidelines/references/study-types/advantages-and-challenges.md) |
| [LLMs as Tools for Software Engineers](/study-types/llms-for-se/) | [llms-for-se.md](https://github.com/se-uhd/llm-guidelines-skill/blob/main/plugins/llm-guidelines/skills/llm-guidelines/references/study-types/llms-for-se.md) |
| [Studying LLM Usage in Software Engineering](/study-types/usage/) | [usage.md](https://github.com/se-uhd/llm-guidelines-skill/blob/main/plugins/llm-guidelines/skills/llm-guidelines/references/study-types/usage.md) |
| [LLMs for New Software Engineering Tools](/study-types/tools/) | [tools.md](https://github.com/se-uhd/llm-guidelines-skill/blob/main/plugins/llm-guidelines/skills/llm-guidelines/references/study-types/tools.md) |
| [Benchmarking LLMs for Software Engineering Tasks](/study-types/benchmarks/) | [benchmarks.md](https://github.com/se-uhd/llm-guidelines-skill/blob/main/plugins/llm-guidelines/skills/llm-guidelines/references/study-types/benchmarks.md) |
