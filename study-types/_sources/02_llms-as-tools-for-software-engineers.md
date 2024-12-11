## LLMs as Tools for Software Engineers

### Studying LLM Usage in Software Engineering

Empirical studies can also focus on understanding how software engineers use LLMs in their workflows. This involves investigating the adoption, usage patterns, and perceived benefits and challenges of LLM-based tools. Surveys, interviews, and observational studies can provide insights into how LLMs are integrated into development processes, how they influence decision-making, and what factors affect their acceptance and effectiveness. Such studies can inform the design of more user-friendly and effective LLM-based tools.
For example, [Khojah et al.](https://dl.acm.org/doi/10.1145/3660788) investigated the use of ChatGPT by professional software engineers in a week-long observational study.

### LLMs for new Software Engineering Tools

LLMs are being integrated into new tools designed to support software engineers in their daily tasks. These tools can include intelligent code editors that provide real-time code suggestions, automated documentation generators, and advanced debugging assistants. Empirical studies can evaluate the effectiveness of these tools in improving productivity, code quality, and developer satisfaction. By assessing the impact of LLM-powered tools, researchers can identify best practices and areas for further improvement.
As an example, [Choudhuri et al.](https://dl.acm.org/doi/abs/10.1145/3597503.3639201) conducted an experiment with students in which they measured the impact of ChatGPT on the correctness and time taken to solve programming tasks.

### Benchmarking LLMs for Software Engineering Tasks

Another typical type of study focuses on benchmarking the LLM output quality on large-scale datasets.
In software engineering, this may include the evaluation of LLMs' ability to produce accurate and robust outputs for input data from real-world projects or synthetically created SE datasets.
In studies with generative models, the LLM output is often compared against a ground truth from the dataset using similarity metrics such as [ROUGE, BLEU, or METEOR](https://doi.org/10.1145/3695988).
Moreover, the evaluation may be augmented by task-specific measures that focus on the type of SE artifact produced.
For example, this may include code quality or performance metrics for code generation tasks or metrics for writing quality in SE tasks with natural language artifacts, such as requirements documents or domain descriptions.
In these benchmarks, reference datasets such as [HumanEval](https://arxiv.org/abs/2107.03374) play an important role in establishing standardized evaluation methods across studies.
However, [benchmark contamination](https://arxiv.org/abs/2410.16186) has recently been identified as an issue.
The careful selection of samples and building of corresponding input prompts is particularly important, as correlations between prompts may [bias benchmark results](https://aclanthology.org/2024.acl-long.560/).
