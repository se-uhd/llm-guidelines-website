---
layout: default
title: Guidelines
nav_order: 4
has_children: false
---

# Guidelines

This set of guidelines is currently a DRAFT and based on a discussion session with researchers at the 2024 International Software Engineering Research Network ([ISERN](https://isern.fraunhofer.de})) meeting and at the 2nd [Copenhagen Symposium on Human-Centered Software Engineering AI](https://www.danielrusso.org/copenhagen-symposium-human-centered-ai-software-engineering/). 
This draft is meant as a starting point for further discussions in the community with the aim of developing a common understanding of how we should conduct and report empirical studies involving large language models (LLMs).
See also the pages on [study types](/study-types) and [scope](/scope).

The wording of the recommendations follows [RFC 2119](https://www.rfc-editor.org/rfc/rfc2119) and [8174](https://www.rfc-editor.org/rfc/rfc8174).

## Overview

1. [Declare LLM Usage and Role](#declare-llm-usage-and-role)
2. [Report Model Version, Configuration, and Customizations](#report-model-version-configuration-and-customizations)
3. [Report Tool Architecture beyond Models](#report-tool-architecture-beyond-models)
4. [Report Prompts, their Development, and Interaction Logs](#report-prompts-their-development-and-interaction-logs)
5. [Use Human Validation for LLM Outputs](#use-human-validation-for-llm-outputs)
6. [Use an Open LLM as a Baseline](#use-an-open-llm-as-a-baseline)
7. [Report Suitable Baselines, Benchmarks, and Metrics](#report-suitable-baselines-benchmarks-and-metrics)
8. [Report Limitations and Mitigations](#report-limitations-and-mitigations)

