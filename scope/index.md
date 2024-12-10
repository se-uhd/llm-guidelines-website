---
layout: default
title: Scope
nav_order: 2
has_children: false
---

# Motivation and Scope

## Motivation

In the short period since the release of ChatGPT in November 2022, large language models (LLMs) have changed the software engineering research landscape.
While there are numerous opportunities to use LLMs for supporting research or software engineering tasks, solid science needs rigorous empirical evaluations.
Such evaluations might explore the effectiveness, performance, and robustness of LLMs in different contexts, such as improving code quality, reducing development time, or supporting software documentation.
However, it is often unclear how valid and reproducible results can be achieved with empirical studies involving LLMs - or what effect their usage has on the validity of empirical results.
This uncertainty poses significant challenges for researchers aiming to draw reliable conclusions from empirical studies.

One of the primary risks in creating unreproducible results stems from the variability in LLM performance due to differences in training data, model architecture, evaluation metrics, and the inherent non-determinism that those models possess.
For example, slight changes in the training dataset or the hyperparameters can lead to significantly different outcomes, making it difficult to replicate studies.
Additionally, the lack of standardized benchmarks and evaluation protocols further complicates the reproducibility of results.
These issues highlight the need for clear guidelines and best practices to ensure that empirical studies with LLMs yield valid and reproducible results.

There has been extensive work developing guidelines for conducting and reporting specific types of empirical studies such as controlled experiments (e.g., [Experimentation in Software Engineering](https://link.springer.com/book/10.1007/978-3-662-69306-3)) or [Guide to Advanced Empirical Software Engineering](https://link.springer.com/book/10.1007/978-1-84800-044-5)) or their replications (e.g., [A Procedure and Guidelines for Analyzing Groups of Software Engineering Replications](https://doi.org/10.1109/TSE.2019.2935720)).
We believe that LLMs have specific intrinsic characteristics that require specific guidelines for researchers to achieve an acceptable level of reproducability.
However, so far, there are no specific guidelines for conducting and assessing studies involving LLMs in software engineering research.

For example, even if we know the specific version of an LLM used for an empirical study, the reported performance for the studied tasks can change over time, especially for commercial models that [evolve beyond version identifiers](https://arxiv.org/abs/2307.09009).
Moreover, commercial providers do not guarantee the availability of old versions indefinitely.
Besides versions, LLMs' performance widely varies depending on configured parameters such as temperature.
Therefore, not reporting the parameter settings impacts the reproducibility of the research.
Even for *open* models such as Llama, [we do not know](https://doi.org/10.1038/d41586-024-02012-5) how they were fine-tuned for specific tasks and what the exact training data was.
For example, when evaluating LLMs' performance for certain programming tasks, it would be relevant to know whether the solution to a certain problem was part of the training data or not.

## Scope

Given the exponential growth in LLM usage across all research domains, it is useful to clarify the scope of study types to which these guidelines apply.
First, as mentioned in the [study types](/study-types), we currently focus on large language models, that is, on natural language processing, and not on multimodal foundation models in general.
Second, LLMs are already widely used to support several aspects of the overall research process – from fairly simple tasks such as proof-reading, spell-checking, text translation though to more significant activities such as data coding and synthesis of literature reviews.
Simpler activities that are closely related to authorship as, for instance, documented in the [ACM Policy on Authorship](https://www.acm.org/publications/policies/frequently-asked-questions) are research-topic agnostic.
At best, researchers might be asked at the time of paper submission to clarify the role played by LLMs in paper preparation.
It is clear that many of the guidelines suggested here are more specific than such research-agnostic LLM usage.
The scope of our guidelines focuses on LLM usage that is more research-centric, specifically in the context of software engineering.
However, in any domain where LLM usage is central aspect of the actual research topic itself, the guidelines would be a good starting point.
