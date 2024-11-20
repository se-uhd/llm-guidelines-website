---
layout: default
title: Study Types
nav_order: 2
has_children: false
---

# Study Types

The development of empirical guidelines for studies involving LLMs in software engineering is crucial for ensuring the validity and reproducibility of results. However, these guidelines must be tailored for different study types as they may pose unique challenges. Therefore, understanding the classification of these studies is essential for developing appropriate guidelines.
We envision that a mature set of guidelines provides specific guidance for each of these study types, addressing their individual methodological idiosyncrasies.

## LLMs as Tools for Researchers in Empirical Studies

LLMs can be leveraged as powerful tools to assist researchers conducting empirical studies. They can automate various tasks such as data collection, preprocessing, and analysis. For example, LLMs can extract relevant information from large datasets, generate summaries of research papers, and even assist in writing literature reviews. This can significantly reduce the time and effort required by researchers, allowing them to focus on more complex aspects of their studies.

### LLMs as Annotators

LLMs can serve as annotators by automatically labeling artifacts with corresponding categories for data analysis.
For example, in a study analyzing code changes in version control systems, researchers may need to categorize each individual change.
For that, they may use LLMs to analyze commit messages and categorize them into predefined labels such as bug fixes, feature additions, or refactorings.
This automation can improve the efficiency of the annotation process, which is often a labor-intensive and error-prone task when done manually.

Moreover, in qualitative data analysis, manually annotating or coding text passages is also an often time-consuming manual process.
LLMs can be used to augment human annotations, provide suggestions for new codes, or even automate the entire process.

In such tasks, LLMs have the potential to improve the accuracy and efficiency of [automated labeling processes](https://dl.acm.org/doi/pdf/10.1145/3637528.3671647), making them valuable tools for empirical research in software engineering.
Hybrid human-LLM annotation approaches may further increase accuracy and allow for the [correction of incorrectly applied labels](https://dl.acm.org/doi/abs/10.1145/3613904.3641960).

### LLMs as Judges

In empirical studies, LLMs can act as judges to evaluate the quality of software artifacts such as code, documentation, and design patterns. 
For instance, LLMs can be trained to assess code readability, adherence to coding standards, and the quality of comments. 
By providing-depending on the model configuration-objective and consistent evaluations, LLMs can help mitigate certain biases and part of the variability that human judges might introduce. 
This can lead to more reliable and reproducible results in empirical studies.
When relying on the judgment of LLMs, researchers have to make sure to build a reliable process for generating ratings that considers the non-deterministic nature of LLMs and report the intricacies of that process transparently.

### LLMs as Subjects

LLMs can be used as subjects in empirical studies to simulate human behavior and interactions. For example, researchers can use LLMs to generate responses in user studies, simulate developer interactions in collaborative coding environments, or model user feedback in software usability studies. This approach can provide valuable insights while reducing the need to recruit human participants, which can be time-consuming and costly. Additionally, using LLMs as subjects allows for controlled experiments with consistent and repeatable conditions.
However, it is important that researchers are aware of LLMs' [inherent biases]({https://doi.org/10.1038/d41586-023-01689-4) and [limitations](https://link.springer.com/article/10.1007/s00146-023-01725-x) when using them as study subjects.

## LLMs for New Tools Supporting Software Engineers

LLMs are being integrated into new tools designed to support software engineers in their daily tasks. These tools can include intelligent code editors that provide real-time code suggestions, automated documentation generators, and advanced debugging assistants. Empirical studies can evaluate the effectiveness of these tools in improving productivity, code quality, and developer satisfaction. By assessing the impact of LLM-powered tools, researchers can identify best practices and areas for further improvement.
As an example, [Choudhuri et al.](https://dl.acm.org/doi/abs/10.1145/3597503.3639201) conducted an experiment with students in which they measured the impact of ChatGPT on the correctness and time taken to solve programming tasks.

## LLMs for Synthesis

**TODO:** E.g., literature reviews

## Studying LLM Usage

Empirical studies can also focus on understanding how software engineers use LLMs in their workflows. This involves investigating the adoption, usage patterns, and perceived benefits and challenges of LLM-based tools. Surveys, interviews, and observational studies can provide insights into how LLMs are integrated into development processes, how they influence decision-making, and what factors affect their acceptance and effectiveness. Such studies can inform the design of more user-friendly and effective LLM-based tools.
For example, [Khojah et al.](https://dl.acm.org/doi/10.1145/3660788) investigated the use of ChatGPT by professional software engineers in a week-long observational study.

Another typical type of study focuses on benchmarking the LLM output quality on large-scale datasets.
In software engineering, this may include the evaluation of LLMs' ability to produce accurate and robust outputs for input data from real-world projects or synthetically created SE datasets.
In studies with generative models, the LLM output is often compared against a ground truth from the dataset using similarity metrics such as [ROUGE, BLEU, or METEOR](https://doi.org/10.1145/3695988).
Moreover, the evaluation may be augmented by task-specific measures that focus on the type of SE artifact produced.
For example, this may include code quality or performance metrics for code generation tasks or metrics for writing quality in SE tasks with natural language artifacts, such as requirements documents or domain descriptions.
In these benchmarks, reference datasets such as [HumanEval](https://arxiv.org/abs/2107.03374) play an important role in establishing standardized evaluation methods across studies.
However, [benchmark contamination](https://arxiv.org/abs/2410.16186) has recently been identified as an issue.
The careful selection of samples and building of corresponding input prompts is particularly important, as correlations between prompts may [bias benchmark results](https://aclanthology.org/2024.acl-long.560/).
