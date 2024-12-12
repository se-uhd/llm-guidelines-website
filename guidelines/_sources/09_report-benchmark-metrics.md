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
* [CoderEval](https://github.com/CoderEval/CoderEval)
* ...

### Recommendations per Study Type

**TODO:** Connect guideline to study types and for each type have bullet point lists with information that MUST, SHOULD, or MAY be reported (usage of those terms according to [RFC 2119](https://www.rfc-editor.org/rfc/rfc2119)).
