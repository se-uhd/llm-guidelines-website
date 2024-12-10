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

## Overview

1. [Declare LLM Usage and Role](#declare-llm-usage-and-role)
2. [Report Model Version and Date](#report-model-version-and-date)
3. [Report Model Configuration](#report-model-configuration)
4. [Report Tool Architecture and Supplemental Data](#report-tool-architecture-and-supplemental-data)
5. [Report Prompts and their Development](#report-prompts-and-their-development)
6. [Report Interaction Logs](#report-interaction-logs)
7. [Use Human Validation for LLM Outputs](#use-human-validation-for-llm-outputs)
8. [Use an Open LLM as a Baseline](#use-an-open-llm-as-a-baseline)
9. [Report Suitable Benchmarking Metrics](#report-suitable-benchmarking-metrics)
10. [Report Limitations and Mitigations](#report-limitations-and-mitigations)

## Declare LLM Usage and Role

When conducting any kind of empirical study involving LLMs, it is essential to clearly declare the an LLM was used. This includes specifying the purpose of using the LLM in the study, the tasks it was applied to, and the expected outcomes. Transparency in the usage of LLMs helps in understanding the context and scope of the study, facilitating better interpretation and comparison of results.
Beyond this declaration, we recommend authors to be explicit about the LLM's exact role.
Oftentimes, there is a complex layer around the LLM that preprocesses data, prepares prompts, or filters user requests.
One example is ChatGPT, which can, among others, use the GPT-4o model.
GitHub Copilot uses the same model as well, and researchers can build their own tools utilizing GPT-4o directly (e.g., via the OpenAI API).
The infrastructure around the bare model can significantly contribute to the performance of a model in a certain task.
Therefore, it is crucial that researchers clearly describe what the LLM contributes to the tool or method presented in a research paper.

### Application

This recommendation applies to...

### Essential Attributes

### Desirable Attributes

### Extraordinary Attributes

### Exemplars

## Report Model Version and Date

It is also crucial for all types of studies to document the specific version of the LLM used in the study, along with the date when the experiments were conducted. LLMs are frequently updated, and different versions may produce varying results. 
By providing this information, researchers enable others to reproduce the study under the same conditions. Different model providers have varying degrees of information. For example, OpenAI provides a model version and a system fingerprint describing the backend configuration that can also influence the output. Therefore, stating "We used gpt-4o-2024-08-0, system fingerprint fp_6b68a8204b" provides clarity on the [exact model and runtime environment](https://platform.openai.com/docs/api-reference/chat/object).

### Application

This recommendation applies to...

### Essential Attributes

### Desirable Attributes

### Extraordinary Attributes

### Exemplars


## Report Model Configuration

Detailed documentation of the configuration and parameters used during any study is necessary for reproducibility. This includes settings such as the temperature that controls randomness, the maximum token length, and any other relevant parameters such as the consideration of historical context.
Additionally, a thorough description of the hosting environment of the LLM or LLM-based tool should be provided, especially in studies focusing on performance or any time-sensitive measurement.
For instance, researchers might report that "the model was integrated via the Azure OpenAI Service, and configured with a temperature of 0.7, top\_p set to 0.8, and a maximum token length of 512," providing a clear overview of the experimental setup.

**TODO:** Experimenting with parameters

### Application

This recommendation applies to...

### Essential Attributes

### Desirable Attributes

### Extraordinary Attributes

### Exemplars


## Report Tool Architecture and Supplemental Data

**TODO:** Architecture (e.g., usage of RAG, agent-based architecture, etc.)
**TODO:** data dump of vector database if used
**TODO:** finetuning? if yes, how? also: publish data used for finetuning (if not confidential)

### Application

This recommendation applies to...

### Essential Attributes

### Desirable Attributes

### Extraordinary Attributes

### Exemplars


## Report Prompts and their Development

Reporting the exact prompts used in the study is essential for transparency and reproducibility.
Prompts can significantly influence the [output of LLMs](https://dl.acm.org/doi/full/10.1145/3643674), and sharing them allows other researchers to understand and reproduce the conditions of the study.

For example, including the specific questions or tasks given to the LLM helps in assessing the validity of the results and comparing them with other studies.
This is an example where different types of studies require different information.
When studying LLM usage, the researchers ideally collect and publish the prompts written by the users (if confidentiality allows).
Otherwise, summaries and examples can be provided.
Prompts also need to be reported when LLMs are integrated into new tools, especially if study participants were able to formulate (parts of) the prompts.
For all other types of studies, researchers should discuss how they arrived at their final set of prompts.
If a systematic approach was used, this process should be described in detail.

## Report Interaction Logs

Reporting full interaction logs, that is all prompts and responses, is especially important when reporting a study targeting commercial SaaS solutions based on LLMs (e.g., ChatGPT) or novel tools that integrate LLMs via cloud APIs.
Given that commercial LLMs and LLM-based tools are evolving systems (minor upgrades of a major version are likely to be [deployed frequently](https://arxiv.org/abs/2307.09009)) and that they [behave non-deterministically](https://152334h.github.io/blog/non-determinism-in-gpt-4/) even with a temperature of 0, reporting the prompts and model versions alone will not be enough to enable reproducibility.
Even for models such as [Llama](https://www.llama.com/) that researchers can host and configure themselves, reaching complete determinism is challenging.
While decoding strategies and parameters can be fixed (e.g., by defining seeds, using deterministic decoding strategies, setting temperature to 0, etc.), non-determinism can also arise from batching, input preprocessing, and floating point arithmetic on GPUs.
Thus, for complete transparency, a researcher should report the answers generated by the LLM or LLM-based tool in the context of the presented study.
In this sense, the way an LLM has to be treated is similar to the way a human participant in an interview would be treated, because both the human and the LLM might provide different answers if presented with the same questions at different times.
The difference is that, while for human participants conversations often cannot be reported due to confidentiality, LLM conversations can.

### Application

This recommendation applies to...

### Essential Attributes

### Desirable Attributes

### Extraordinary Attributes

### Exemplars


## Use Human Validation for LLM Outputs

Especially in studies where LLMs are used to support researchers, human validation should always be employed.
While LLMs can automate many tasks, it is important to validate their outputs with human annotations, at least partially. For natural language processing tasks, a large-scale study has shown that LLMs have too large a variation in their results to be reliably used as a [substitution for human judges](https://arxiv.org/abs/2406.18403). Human validation helps ensure the accuracy and reliability of the results, as LLMs may sometimes produce incorrect or biased outputs. Incorporating human judgment in the evaluation process adds a layer of quality control and increases the trustworthiness of the study’s findings, especially when explicitly reporting inter-rater reliability metrics. For instance, "A subset of 20% the LLM-generated annotations were reviewed and validated by experienced software engineers to ensure accuracy. An inter-rater reliability of 90% was reached."
For studies using LLMs as annotators, the proposed process by [Ahmed et al.](https://arxiv.org/abs/2408.05534), which includes an initial few-shot learning and, given good results, the replacement of *one* human annotator by an LLM, might be a way forward.

### Application

This recommendation applies to...

### Essential Attributes

### Desirable Attributes

### Extraordinary Attributes

### Exemplars


## Use an Open LLM as a Baseline

To ensure the reproducibility of results, we recommended findings to be reported with an open LLM as a baseline.
This applies both when using LLMs as tools for supporting researchers in empirical studies and when benchmarking LLMs for SE tasks.
In case LLMs are integrated into new tools, this is also preferable if the architecture of the tool allows it.
If the effort of changing models is too high, researchers should at least report an initial benchmarking with open models, which enables more objective comparisons.
Open LLMs can either be hosted via cloud platforms such as *Hugging Face* or used locally via tools such as *ollama* or *LM Studio*.
A replication package for papers using LLMs should include clear instructions that allow other researchers to reproduce the findings using open models.
This practice enhances the credibility of the study and allows for independent verification of the results. 
Researchers could, e.g., mention that "results were compared with those obtained using Meta’s Code LLAMA, available on the Hugging Face platform" and point to a replication package.

We are aware that the definition of an "open" model is actively being discussed, and many open models are essentially only ["open weight"](https://doi.org/10.1038/d41586-024-02012-5).
We consider the [*Open Source AI Definition*](https://opensource.org/ai/open-source-ai-definition) proposed by the *Open Source Initiative* (OSI) to be a first step towards defining true open-source models.

**TODO:** Inter-model agreement, model confidence

### Application

This recommendation applies to...

### Essential Attributes

### Desirable Attributes

### Extraordinary Attributes

### Exemplars


## Report Suitable Benchmarking Metrics

**TODO:** What are suitable metrics and benchmarks for evaluating LLMs?

### Metrics

* pass@k (**TODO:** What are common values for k? Who came up with that metric?), but also others such as [CodeBLEU](https://arxiv.org/pdf/2009.10297), [CrystalBLEU](https://software-lab.org/publications/ase2022_CrystalBLEU.pdf), etc.
* If a tool is analyzed, the acceptance rate of generated artifacts could be interesting (how many artifacts were accepted/rejected by the user)
* Inter-model-agreement (related to section on open LLM as baseline): Ask different LLMs or differently considered LLMs and determine their agreement 

### Benchmarks

**TODO:** Maybe something along the lines of using different benchmarks? Being aware of their biases (e.g., focus on a particular programming language such as Python)?

* [HumanEval](https://github.com/openai/human-eval)
* [REPOCOD](https://huggingface.co/datasets/lt-asset/REPOCOD)
* [CoderVal](https://github.com/CoderEval/CoderEval)
* ...

### Application

This recommendation applies to...

### Essential Attributes

### Desirable Attributes

### Extraordinary Attributes

### Exemplars


## Report Limitations and Mitigations

**TODO:** Number of repetitions, how were repetitions aggregated?, discuss limitations and mitigations

### Application

This recommendation applies to...

### Essential Attributes

### Desirable Attributes

### Extraordinary Attributes

### Exemplars

