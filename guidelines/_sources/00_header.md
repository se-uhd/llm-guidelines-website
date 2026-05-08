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

For a compact overview of each guideline's rationale and core recommendations, see the [summary](/summary/). For an item-by-item view to walk through during reporting, see the [reporting checklist](/checklist/).

## Guidelines by Study Type

**Note:** Each guideline's study-type-specific guidance is detailed in the corresponding subsection.
{: .fs-3 }

The guideline's core recommendations:<br/>
● = **must** be followed for this study type.<br/>
<span class="marker-should">●</span> = **should** be followed for this study type.<br/>
-- = are not directly applicable for this study type.

| | <a href="/study-types/llms-as-annotators/">Annotator</a> | <a href="/study-types/llms-as-judges/">Judge</a> | <a href="/study-types/llms-for-synthesis/">Synthesis</a> | <a href="/study-types/llms-as-subjects/">Subject</a> | <a href="/study-types/studying-llm-usage-in-software-engineering/">Usage</a> | <a href="/study-types/llms-for-new-software-engineering-tools/">Tools</a> | <a href="/study-types/benchmarking-llms-for-software-engineering-tasks/">Benchmarks</a> |
|---|:---:|:---:|:---:|:---:|:---:|:---:|:---:|
| <a href="/guidelines/declare-llm-usage-and-role/">Declare Usage</a> | ● | ● | ● | ● | ● | ● | ● |
| <a href="/guidelines/report-model-version-configuration-and-customizations/">Model Version</a> | ● | ● | ● | ● | ● | ● | ● |
| <a href="/guidelines/report-system-and-prompt-design/">Design</a> | ● | ● | ● | ● | ● | ● | ● |
| <a href="/guidelines/report-session-traces/">Traces</a> | <span class="marker-should">●</span> | <span class="marker-should">●</span> | <span class="marker-should">●</span> | <span class="marker-should">●</span> | ● | <span class="marker-should">●</span> | <span class="marker-should">●</span> |
| <a href="/guidelines/use-suitable-baselines-benchmarks-and-metrics/">Benchmarks</a> | ● | <span class="marker-should">●</span> | <span class="marker-should">●</span> | <span class="marker-should">●</span> | <span class="marker-should">●</span> | <span class="marker-should">●</span> | ● |
| <a href="/guidelines/use-an-open-llm-as-a-baseline/">Open LLM</a> | <span class="marker-should">●</span> | <span class="marker-should">●</span> | <span class="marker-should">●</span> | -- | -- | <span class="marker-should">●</span> | ● |
| <a href="/guidelines/use-human-validation-for-llm-outputs/">Human Validation</a> | <span class="marker-should">●</span> | <span class="marker-should">●</span> | <span class="marker-should">●</span> | <span class="marker-should">●</span> | <span class="marker-should">●</span> | <span class="marker-should">●</span> | <span class="marker-should">●</span> |
| <a href="/guidelines/report-limitations-and-mitigations/">Limitations</a> | ● | ● | ● | ● | ● | ● | ● |

