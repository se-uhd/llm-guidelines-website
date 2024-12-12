## Declare LLM Usage and Role

When conducting any kind of empirical study involving LLMs, it is essential to clearly declare the an LLM was used. This includes specifying the purpose of using the LLM in the study, the tasks it was applied to, and the expected outcomes. Transparency in the usage of LLMs helps in understanding the context and scope of the study, facilitating better interpretation and comparison of results.
Beyond this declaration, we recommend authors to be explicit about the LLM's exact role.
Oftentimes, there is a complex layer around the LLM that preprocesses data, prepares prompts, or filters user requests.
One example is ChatGPT, which can, among others, use the GPT-4o model.
GitHub Copilot uses the same model as well, and researchers can build their own tools utilizing GPT-4o directly (e.g., via the OpenAI API).
The infrastructure around the bare model can significantly contribute to the performance of a model in a certain task.
Therefore, it is crucial that researchers clearly describe what the LLM contributes to the tool or method presented in a research paper.

### Recommendations per Study Type

**TODO:** Connect guideline to study types and for each type have bullet point lists with information that MUST, SHOULD, or MAY be reported (usage of those terms according to [RFC 2119](https://www.rfc-editor.org/rfc/rfc2119)).
