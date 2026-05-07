---
layout: default
title: Skill
nav_order: 5
---

# Skill

`llm-guidelines` is an [Agent Skill](https://agentskills.io/home) that packages these guidelines for authors to use directly inside an AI coding assistant. It bundles the same content this website renders ([scope](/scope/), [study types](/study-types/), [guidelines](/guidelines/), [checklist](/checklist/)) and exposes two slash commands: one for **exploring** the guidelines (asking questions, discussing study designs, navigating the taxonomy) and one for **reviewing** a paper draft (and any supplementary material) against the eight guidelines, producing an `llm-guidelines-report.md` for the paper at hand.

Agent Skills is an open standard originally developed by Anthropic. The format is now read by Cursor, GitHub Copilot, OpenAI Codex, Gemini CLI, Claude Code, and JetBrains Junie, among others; see the [client list](https://agentskills.io/clients) for the current set. The instructions below cover Claude Code; for any other client, copy the `plugins/llm-guidelines/skills/llm-guidelines/` directory from the repository into the location that client expects (each client's docs are linked from the client list).

The skill is published in a separate repository at [se-uhd/llm-guidelines-skill](https://github.com/se-uhd/llm-guidelines-skill). Its version matches the tag shown in the header of this site; each release is regenerated from the same LaTeX sources, so the three forms stay in sync.

## Install

### As a Claude Code plugin

```
/plugin marketplace add se-uhd/llm-guidelines-skill
/plugin install llm-guidelines
```

### As a user skill in Claude Code (no plugin)

```bash
git clone https://github.com/se-uhd/llm-guidelines-skill.git
mkdir -p ~/.claude/skills
cp -r llm-guidelines-skill/plugins/llm-guidelines/skills/llm-guidelines ~/.claude/skills/
```

### In other Agent Skills clients

The directory `plugins/llm-guidelines/skills/llm-guidelines/` in the repository is a self-contained Agent Skill. Copy it into the skills location of the client you use; each client's docs are linked from the [Agent Skills client list](https://agentskills.io/clients).

## Invoke

The skill exposes two slash commands.

### Explore the guidelines

Use this when you want to ask a question, plan a study, walk through the checklist, or decide which study type your project falls under, before any draft exists.

```
/llm-guidelines:explore
```

Explore mode is a conversation; it does not write any files unless you ask.

### Review a draft

Use this when you have a draft paper (and optionally supplementary material) and want a structured pass against each of the eight guidelines.

With a LaTeX source:

```
/llm-guidelines:review path/to/paper.tex
```

Or with a PDF:

```
/llm-guidelines:review path/to/paper.pdf
```

The supplementary-material path is optional, and you can pass more than one when artifacts live in separate locations (e.g., code on GitHub, data on Zenodo):

```
/llm-guidelines:review path/to/paper.tex path/to/code-repo path/to/dataset
```

If invoked without arguments, review mode asks for paths to your paper (LaTeX source or PDF) and any supplementary directories. It will not modify your files; it writes its findings to `llm-guidelines-report.md` in your working directory and prints the same content to the console.

### Auto-invocation

The skill can also load itself without an explicit slash command if the agent decides its description matches the task. In that case, the skill picks the mode from your request: a paper path or a request to "check" or "review" a draft triggers review mode; a question or design discussion triggers explore mode.

## Bundled Files

The skill ships a structured set of Markdown files. The first column links to the rich rendering on this website (where one exists); the second column links to the raw Markdown source in the skill repository.

| File | Source |
|------|--------|
| Skill instructions and workflow (not rendered here) | [SKILL.md](https://github.com/se-uhd/llm-guidelines-skill/blob/main/plugins/llm-guidelines/skills/llm-guidelines/SKILL.md) |
| [Scope](/scope/) | [scope.md](https://github.com/se-uhd/llm-guidelines-skill/blob/main/plugins/llm-guidelines/skills/llm-guidelines/scope.md) |
| [Reporting Checklist](/checklist/) | [checklist.md](https://github.com/se-uhd/llm-guidelines-skill/blob/main/plugins/llm-guidelines/skills/llm-guidelines/checklist.md) |

### Guidelines

| Guideline | Source |
|-----------|--------|
| [Declare LLM Usage and Role](/guidelines/declare-llm-usage-and-role/) | [declare-llm-usage-and-role.md](https://github.com/se-uhd/llm-guidelines-skill/blob/main/plugins/llm-guidelines/skills/llm-guidelines/guidelines/declare-llm-usage-and-role.md) |
| [Report Model Version, Configuration, and Customizations](/guidelines/report-model-version-configuration-and-customizations/) | [report-model-version-configuration-and-customizations.md](https://github.com/se-uhd/llm-guidelines-skill/blob/main/plugins/llm-guidelines/skills/llm-guidelines/guidelines/report-model-version-configuration-and-customizations.md) |
| [Report System and Prompt Design](/guidelines/report-system-and-prompt-design/) | [report-system-and-prompt-design.md](https://github.com/se-uhd/llm-guidelines-skill/blob/main/plugins/llm-guidelines/skills/llm-guidelines/guidelines/report-system-and-prompt-design.md) |
| [Report Session Traces](/guidelines/report-session-traces/) | [report-session-traces.md](https://github.com/se-uhd/llm-guidelines-skill/blob/main/plugins/llm-guidelines/skills/llm-guidelines/guidelines/report-session-traces.md) |
| [Use Suitable Baselines, Benchmarks, and Metrics](/guidelines/use-suitable-baselines-benchmarks-and-metrics/) | [use-suitable-baselines-benchmarks-and-metrics.md](https://github.com/se-uhd/llm-guidelines-skill/blob/main/plugins/llm-guidelines/skills/llm-guidelines/guidelines/use-suitable-baselines-benchmarks-and-metrics.md) |
| [Use an Open LLM as a Baseline](/guidelines/use-an-open-llm-as-a-baseline/) | [use-an-open-llm-as-a-baseline.md](https://github.com/se-uhd/llm-guidelines-skill/blob/main/plugins/llm-guidelines/skills/llm-guidelines/guidelines/use-an-open-llm-as-a-baseline.md) |
| [Use Human Validation for LLM Outputs](/guidelines/use-human-validation-for-llm-outputs/) | [use-human-validation-for-llm-outputs.md](https://github.com/se-uhd/llm-guidelines-skill/blob/main/plugins/llm-guidelines/skills/llm-guidelines/guidelines/use-human-validation-for-llm-outputs.md) |
| [Report Limitations and Mitigations](/guidelines/report-limitations-and-mitigations/) | [report-limitations-and-mitigations.md](https://github.com/se-uhd/llm-guidelines-skill/blob/main/plugins/llm-guidelines/skills/llm-guidelines/guidelines/report-limitations-and-mitigations.md) |

### Study Types

| Study Type | Source |
|------------|--------|
| [LLMs as Tools for Software Engineering Researchers](/study-types/llms-as-tools-for-software-engineering-researchers/) | [llms-as-tools-for-software-engineering-researchers.md](https://github.com/se-uhd/llm-guidelines-skill/blob/main/plugins/llm-guidelines/skills/llm-guidelines/study-types/llms-as-tools-for-software-engineering-researchers.md) |
| [LLMs as Annotators](/study-types/llms-as-annotators/) | [llms-as-annotators.md](https://github.com/se-uhd/llm-guidelines-skill/blob/main/plugins/llm-guidelines/skills/llm-guidelines/study-types/llms-as-annotators.md) |
| [LLMs as Judges](/study-types/llms-as-judges/) | [llms-as-judges.md](https://github.com/se-uhd/llm-guidelines-skill/blob/main/plugins/llm-guidelines/skills/llm-guidelines/study-types/llms-as-judges.md) |
| [LLMs for Synthesis](/study-types/llms-for-synthesis/) | [llms-for-synthesis.md](https://github.com/se-uhd/llm-guidelines-skill/blob/main/plugins/llm-guidelines/skills/llm-guidelines/study-types/llms-for-synthesis.md) |
| [LLMs as Subjects](/study-types/llms-as-subjects/) | [llms-as-subjects.md](https://github.com/se-uhd/llm-guidelines-skill/blob/main/plugins/llm-guidelines/skills/llm-guidelines/study-types/llms-as-subjects.md) |
| [Advantages and Challenges](/study-types/advantages-and-challenges/) | [advantages-and-challenges.md](https://github.com/se-uhd/llm-guidelines-skill/blob/main/plugins/llm-guidelines/skills/llm-guidelines/study-types/advantages-and-challenges.md) |
| [LLMs as Tools for Software Engineers](/study-types/llms-as-tools-for-software-engineers/) | [llms-as-tools-for-software-engineers.md](https://github.com/se-uhd/llm-guidelines-skill/blob/main/plugins/llm-guidelines/skills/llm-guidelines/study-types/llms-as-tools-for-software-engineers.md) |
| [Studying LLM Usage in Software Engineering](/study-types/studying-llm-usage-in-software-engineering/) | [studying-llm-usage-in-software-engineering.md](https://github.com/se-uhd/llm-guidelines-skill/blob/main/plugins/llm-guidelines/skills/llm-guidelines/study-types/studying-llm-usage-in-software-engineering.md) |
| [LLMs for New Software Engineering Tools](/study-types/llms-for-new-software-engineering-tools/) | [llms-for-new-software-engineering-tools.md](https://github.com/se-uhd/llm-guidelines-skill/blob/main/plugins/llm-guidelines/skills/llm-guidelines/study-types/llms-for-new-software-engineering-tools.md) |
| [Benchmarking LLMs for Software Engineering Tasks](/study-types/benchmarking-llms-for-software-engineering-tasks/) | [benchmarking-llms-for-software-engineering-tasks.md](https://github.com/se-uhd/llm-guidelines-skill/blob/main/plugins/llm-guidelines/skills/llm-guidelines/study-types/benchmarking-llms-for-software-engineering-tasks.md) |
