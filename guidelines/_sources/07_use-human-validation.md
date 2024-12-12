## Use Human Validation for LLM Outputs

Especially in studies where LLMs are used to support researchers, human validation should always be employed.
While LLMs can automate many tasks, it is important to validate their outputs with human annotations, at least partially. For natural language processing tasks, a large-scale study has shown that LLMs have too large a variation in their results to be reliably used as a [substitution for human judges](https://arxiv.org/abs/2406.18403). Human validation helps ensure the accuracy and reliability of the results, as LLMs may sometimes produce incorrect or biased outputs. Incorporating human judgment in the evaluation process adds a layer of quality control and increases the trustworthiness of the study’s findings, especially when explicitly reporting inter-rater reliability metrics. For instance, "A subset of 20% of the LLM-generated annotations were reviewed and validated by experienced software engineers to ensure accuracy. An inter-rater reliability of 90% was reached."
For studies using LLMs as annotators, the proposed process by [Ahmed et al.](https://arxiv.org/abs/2408.05534), which includes an initial few-shot learning and, given good results, the replacement of *one* human annotator by an LLM, might be a way forward.

### Recommendations per Study Type

**TODO:** Connect guideline to study types and for each type have bullet point lists with information that MUST, SHOULD, or MAY be reported (usage of those terms according to [RFC 2119](https://www.rfc-editor.org/rfc/rfc2119)).
