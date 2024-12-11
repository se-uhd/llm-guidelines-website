## Use an Open LLM as a Baseline

To ensure the reproducibility of results, we recommended findings be reported with an open LLM as a baseline.
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
