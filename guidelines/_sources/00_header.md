---
layout: default
title: Guidelines
nav_order: 4
has_children: false
---

# Guidelines

<!-- INTRO -->

## Overview

<!-- TOC -->

## Applicability of Guidelines to Study Types

**Study types:** [S1](/study-types#llms-as-annotators-s1) = Annotators, [S2](/study-types#llms-as-judges-s2) = Judges, [S3](/study-types#llms-for-synthesis-s3) = Synthesis, [S4](/study-types#llms-as-subjects-s4) = Subjects, [S5](/study-types#studying-llm-usage-in-software-engineering-s5) = LLM Usage, [S6](/study-types#llms-for-new-software-engineering-tools-s6) = Tools, [S7](/study-types#benchmarking-llms-for-software-engineering-tasks-s7) = Benchmarking.
<br>**Note:** Each guideline's study-type-specific guidance is detailed in the corresponding subsections.
{: .fs-3 }

● = **MUST**, ○ = **SHOULD**, -- = not applicable

| | S1 | S2 | S3 | S4 | S5 | S6 | S7 |
|---|:---:|:---:|:---:|:---:|:---:|:---:|:---:|
| [G1: Declare Usage](#declare-llm-usage-and-role-g1) | ● | ● | ● | ● | ● | ● | ● |
| [G2: Model Version](#report-model-version-configuration-and-customizations-g2) | ● | ● | ● | ● | ● | ● | ● |
| [G3: Architecture](#report-tool-architecture-beyond-models-g3) | ○ | ○ | ○ | ○ | ○ | ● | ○ |
| [G4: Prompts](#report-prompts-their-development-and-interaction-logs-g4) | ● | ● | ● | ● | ● | ● | ● |
| [G5: Human Validation](#use-human-validation-for-llm-outputs-g5) | ○ | ○ | ○ | ○ | ○ | ○ | ○ |
| [G6: Open LLM](#use-an-open-llm-as-a-baseline-g6) | ○ | ○ | ○ | -- | -- | ○ | ● |
| [G7: Benchmarks](#use-suitable-baselines-benchmarks-and-metrics-g7) | ○ | ○ | ○ | ○ | ○ | ○ | ● |
| [G8: Limitations](#report-limitations-and-mitigations-g8) | ● | ● | ● | ● | ● | ● | ● |

