---
layout: default
title: Guidelines
nav_order: 4
has_children: true
---

<style>
.marker-should { color: #ddd; }
</style>

# Guidelines

<!-- INTRO -->

## Guidelines by Study Type

**Study types:** [S1](/study-types/llms-as-annotators/) = Annotators, [S2](/study-types/llms-as-judges/) = Judges, [S3](/study-types/llms-for-synthesis/) = Synthesis, [S4](/study-types/llms-as-subjects/) = Subjects, [S5](/study-types/studying-llm-usage-in-software-engineering/) = LLM Usage, [S6](/study-types/llms-for-new-software-engineering-tools/) = Tools, [S7](/study-types/benchmarking-llms-for-software-engineering-tasks/) = Benchmarking.
<br/>**Note:** Each guideline's study-type-specific guidance is detailed in the corresponding subsection.
{: .fs-3 }

The guideline's core recommendations:<br/>
● = **MUST** be followed for this study type.<br/>
<span class="marker-should">●</span> = **SHOULD** be followed for this study type.<br/>
-- = are not directly applicable for this study type.

| | <a href="/study-types/llms-as-annotators/">S1:<br/>Annotators</a> | <a href="/study-types/llms-as-judges/">S2:<br/>Judges</a> | <a href="/study-types/llms-for-synthesis/">S3:<br/>Synthesis</a> | <a href="/study-types/llms-as-subjects/">S4:<br/>Subjects</a> | <a href="/study-types/studying-llm-usage-in-software-engineering/">S5:<br/>LLM Usage</a> | <a href="/study-types/llms-for-new-software-engineering-tools/">S6:<br/>Tools</a> | <a href="/study-types/benchmarking-llms-for-software-engineering-tasks/">S7:<br/>Benchmarking</a> |
|---|:---:|:---:|:---:|:---:|:---:|:---:|:---:|
| <a href="/guidelines/declare-llm-usage-and-role/">G1:<br/>Declare Usage</a> | ● | ● | ● | ● | ● | ● | ● |
| <a href="/guidelines/report-model-version-configuration-and-customizations/">G2:<br/>Model Version</a> | ● | ● | ● | ● | ● | ● | ● |
| <a href="/guidelines/report-tool-architecture-beyond-models/">G3:<br/>Architecture</a> | <span class="marker-should">●</span> | <span class="marker-should">●</span> | <span class="marker-should">●</span> | <span class="marker-should">●</span> | <span class="marker-should">●</span> | ● | <span class="marker-should">●</span> |
| <a href="/guidelines/report-prompts-their-development-and-interaction-logs/">G4:<br/>Prompts</a> | ● | ● | ● | ● | ● | ● | ● |
| <a href="/guidelines/use-human-validation-for-llm-outputs/">G5:<br/>Human Validation</a> | <span class="marker-should">●</span> | <span class="marker-should">●</span> | <span class="marker-should">●</span> | <span class="marker-should">●</span> | <span class="marker-should">●</span> | <span class="marker-should">●</span> | <span class="marker-should">●</span> |
| <a href="/guidelines/use-an-open-llm-as-a-baseline/">G6:<br/>Open LLM</a> | <span class="marker-should">●</span> | <span class="marker-should">●</span> | <span class="marker-should">●</span> | -- | -- | <span class="marker-should">●</span> | ● |
| <a href="/guidelines/use-suitable-baselines-benchmarks-and-metrics/">G7:<br/>Benchmarks</a> | ● | <span class="marker-should">●</span> | <span class="marker-should">●</span> | <span class="marker-should">●</span> | <span class="marker-should">●</span> | <span class="marker-should">●</span> | ● |
| <a href="/guidelines/report-limitations-and-mitigations/">G8:<br/>Limitations</a> | ● | ● | ● | ● | ● | ● | ● |

