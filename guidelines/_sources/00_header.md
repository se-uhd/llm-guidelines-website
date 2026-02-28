---
layout: default
title: Guidelines
nav_order: 4
has_children: false
---

# Guidelines

Our guidelines focus on LLMs, that is, foundational models that use *text* as in- and output.
We do not address multi-modal foundation models that support other media such as images.
However, many of our recommendations apply to multi-modal models as well.

The main goal of our guidelines is to *enable reproducibility and replicability* of empirical studies involving LLMs in software engineering.
While we consider LLM-based studies to have characteristics that differ from traditional empirical studies (e.g., their inherent non-determinism and the fact that truly open models are rare), previous guidelines regarding open science and empirical studies still apply.
Although full reproducibility of LLM study results is very challenging given LLM's non-determinism, transparency on LLM usage, methods, data, and architecture, as suggested by our guidelines, is an essential prerequisite for future replication studies.

The wording of our guidelines (**MUST**, **SHOULD**, **MAY**) follows [RFC 2119](https://www.rfc-editor.org/rfc/rfc2119) and [RFC 8174](https://www.rfc-editor.org/rfc/rfc8174).
Throughout the following sections, we mention the information we expect researchers to report in the PAPER and/or in the SUPPLEMENTARY MATERIAL.
We are aware that different publication venues have different page limits and that not all aspects can be reported in the PAPER.
If information **MUST** be reported in the PAPER, we explicitly mention this in the specific guidelines.
Of course, it is better to report essential information in the SUPPLEMENTARY MATERIAL than not at all.
The SUPPLEMENTARY MATERIAL **SHOULD** be published according to the [ACM SIGSOFT Open Science Policies](https://zenodo.org/records/10796477).

At the beginning of each section, we provide a brief <u><em>tl;dr</em></u> summary that lists the most important aspects of the corresponding guideline.
In addition to our **recommendations**, we provide **examples** from the SE research community and beyond, as well as the **advantages** and potential **challenges** of following the respective guidelines.
We conclude each guideline by linking it to the **study types**.
We start with an aggregation of all <u><em>tl;dr</em></u> summaries, followed by the individual guidelines:

## Overview

<!-- TOC -->

