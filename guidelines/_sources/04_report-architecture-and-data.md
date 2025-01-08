## Report Tool Architecture and Supplemental Data

Oftentimes, there is a complex layer around the LLM that preprocesses data, prepares prompts, or filters user requests.
One example is ChatGPT, which can, among others, use the GPT-4o model.
GitHub Copilot uses the same model as well, and researchers can build their own tools utilizing GPT-4o directly (e.g., via the OpenAI API).
The infrastructure around the bare model can significantly contribute to the performance of a model in a certain task.
Therefore, it is crucial that researchers clearly describe what the LLM contributes to the tool or method presented in a research paper.

**TODO:** Architecture (e.g., usage of RAG, agent-based architecture, etc.)

**TODO:** data dump of vector database if used

**TODO:** finetuning? if yes, how? also: publish data used for finetuning (if not confidential)

### Recommendations per Study Type

**TODO:** Connect guideline to study types and for each type have bullet point lists with information that MUST, SHOULD, or MAY be reported (usage of those terms according to [RFC 2119](https://www.rfc-editor.org/rfc/rfc2119)).
