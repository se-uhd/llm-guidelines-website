## (WIP) Report Suitable Benchmarking Metrics

### Metrics

LLM metrics capture an aspect of a model, capturing performance and quality of a model tailored for a specific task.
For example, one typical metric used for evaluating Large Language Model performance on code synthesis is pass@k.
For code synthesis, pass@k reports how the likelihood of a model to correctly complete a code snippet at least once within k tries.
However, pass@k is only one of many metrics uesd to evaluate code synthesis.

[HOUS at. el.](https://arxiv.org/pdf/2308.10620) reviewed 395 LLM for software engineering papers and reported the most used metrics for a problem type.
They categorized each metric in one of three problem categories: regression, classification and generation.
The table of used metrics for each category is shown below.

![Usage of Evaluation Metrics](/assets/images/evaluation_metrics.png)
*Usage of Evaluation Metrics taken from [HOUS at. el.](https://arxiv.org/pdf/2308.10620)*

***TODO: For each metric***
- [ ] Explain the metric in more detail?
- [ ] Explain what is considered "good" and "bad" for a given context?
- [ ] Add some examples
- [ ] Categorize metrics based on the paper in metrics used for regression, code generation and classification?
- [ ] Include mathematical notation? If yes, explain it in more detail to make it easier?/ provide python implementation/ example?

#### Code Generation

For code generation the following metrics are reported. ***TODO Note: I think we should only explain the top n***

* [pass@k](https://arxiv.org/pdf/2107.03374) Pass@1 Pass@2 Pass@5 Pass@10, reporting of k depends on the specific usecase of the tool. e.g. for code completion in an IDE pass@1 is essential because the user only get to see one result, pass@5 and pass@10 show that LLMs are somewhat capable of solving the given task (indication that through e.g. fine-tuning it might be possible to solve) or if users get multiple options to choose from (e.g. test generation)
* [BLEU-N](https://aclanthology.org/P02-1040.pdf)
* [CodeBLEU](https://arxiv.org/abs/2009.10297)
* [CrystalBLEU](https://software-lab.org/publications/ase2022_CrystalBLEU.pdf)
* [ROUGE](https://aclanthology.org/W04-1013.pdf)
* Accuracy/Accuracy@k
* Mean Reciprocal Rank
* Edit Similarity (ES)
* Edit Distance (ED)
* Exact Match (EM)
* [METEOR](https://dl.acm.org/doi/pdf/10.5555/1626355.1626389)
* Recall
* F1-score
* Mean Reciprocal Rank (MRR)
* Mean Average Ranking (MAR)
* Mean First Ranking (MFR)
* [Character n-gram F-Score (ChrF)](https://aclanthology.org/W15-3049.pdf)
* [CodeBERTScore](https://arxiv.org/pdf/2302.05527)
* Perplexity (PP)


#### Domain-specific metrics
* If a tool is analyzed, the acceptance rate of generated artifacts could be interesting (how many artifacts were accepted/rejected by the user)
* Inter-model-agreement (related to section on open LLM as baseline): Ask different LLMs or differently confidered LLMs and determine their agreement
* Cross Cutting Metrics: Costs/Energy requirements to get the results (database community often reports on how expensive it was to get results, would be interesting for LLMs too but nobody does it yet)

#### Classification

- Precision
- Recall
- F1-Score
- Accuracy
- Area Under the Receiver Operating Characteristic (ROC) Curve
- Receiver Operating Characteristic (ROC)
- False Positive Rate (FPR)
- False Negative Rate (FNR)
- Matthews Correlation Coefficient (MCC)

#### Recommendation

- Mean Reciprocal Rank (MRR)
- Precision/Precision@k
- MAP/MAP@k
- F-score/F-score@k
- Recall/Recall@k
- Accuracy

### Benchmarks

***TODO:*** Maybe something along the lines of using different benchmarks? Being aware of their biases (e.g., focus on a particular programming language such as Python)?

* [HumanEval](https://github.com/openai/human-eval)
* [REPOCOD](https://huggingface.co/datasets/lt-asset/REPOCOD)
* [ClassEval](https://arxiv.org/abs/2308.01861)

#### Code Translation

* [Avatar](https://arxiv.org/pdf/2108.11590)
* [Transcoder](https://arxiv.org/pdf/2006.03511)