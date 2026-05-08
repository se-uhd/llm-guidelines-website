---
layout: default
title: Summary
nav_order: 5
has_children: false
---

# Rationale and Recommendations

Each guideline is summarized below by its rationale and core recommendations. ● = **must**, ○ = **should**. See the [guidelines](/guidelines/) for the full statements, the [applicability matrix](/guidelines/#guidelines-by-study-type) for per-study-type severities, and the [reporting checklist](/checklist/) for an item-by-item breakdown.

| Guideline | Rationale | Core Recommendations |
|---|---|---|
| [Declare Usage](/guidelines/declare-llm-usage-and-role/) | Transparency enables informed assessment of scope and limitations. | ● Declare which LLM, how it was used, and where in the research process. |
| [Model Version](/guidelines/report-model-version-configuration-and-customizations/) | Reproducibility requires precise identification of the system used in a study. | ● Report exact version, date, configuration, and fine-tuning details. |
| [Design](/guidelines/report-system-and-prompt-design/) | Static artifacts determine what the model sees on every call and must be documented in full. | ● Describe architecture, infrastructure, prompts and templates (with development strategy), context files, tool catalog, agent architecture, and retrieval mechanisms.<br/>○ For LLM usage, describe the tool architecture to the extent accessible. |
| [Traces](/guidelines/report-session-traces/) | Runtime traces make LLM and agent behavior verifiable despite non-determinism and tool opacity. | ● For studies of LLM usage, share full interaction logs subject to privacy constraints.<br/>○ Otherwise, share interaction logs, runtime traces, and plans where feasible. |
| [Benchmarks](/guidelines/use-suitable-baselines-benchmarks-and-metrics/) | Meaningful evaluation requires reasoned valid measurement. | ● Justify metric and benchmark choices; discuss their validity.<br/>○ Define the phenomenon and sampling strategy; isolate confounders; analyze errors; repeat experiments and report distributions. |
| [Open LLM](/guidelines/use-an-open-llm-as-a-baseline/) | Reproducibility depends on access to the model under study. | ● For benchmarking studies, include an open LLM.<br/>○ Otherwise, include an open LLM as a baseline; provide a replication package. |
| [Human Validation](/guidelines/use-human-validation-for-llm-outputs/) | Automated metrics alone cannot ensure validity of subjective constructs. | ● Define the measured construct and share any custom measurement instruments.<br/>○ Validate against human judgment with inter-rater reliability; describe rater demographics for value-laden constructs. |
| [Limitations](/guidelines/report-limitations-and-mitigations/) | Honest acknowledgment of threats strengthens a study. | ● Discuss threats to internal validity (data leakage), reliability (non-determinism), construct and external validity.<br/>○ Employ mitigations where possible. |
