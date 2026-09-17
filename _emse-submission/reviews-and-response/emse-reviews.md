# Editor 

* Structure & Presentation. Make the paper more concise, reduce repetition, provide a summary tables of the guidelines.

* Terminology #1. Reconsider the use of RFC terminology. As R2 makes the case, peer review is not a standardization method.

* Terminology #2. Be careful claiming "undisputable truths" (see comments by R2). Guidelines should allow flexibility given resource constraints.

* Methodological Improvements. Provide additional details on the methodology as requested in the reviews. For the revision, we do not expect any additional experiments, evaluations, but please increase the rigor as much as possible.


# Reviewer 1: 
This is worthwhile work that can benefit from a number of improvements mainly it terms of its structure.

Regarding significance, the motivation behind this work is clearly set in the introduction. The presented contributions can clearly impact the field of software engineering theory and practice as described in the concluding sections.

Regarding novelty, the work's contributions are original with respect to the state-of-the-art. Existing work in the area is coherently analyzed and synthesized, and the study's contributions are clearly identified in its context.

Regarding soundness, the study's contributions address its research questions, but in some cases the applied research methods lack the required rigor. In particular the methods described in Section 3 could be improved by having the process informed in a systematic way from other disciplines. The contribution's evaluation can be improved perhaps with a provision (as an appendix) of a model study following the recommendations, in order to judge the recommendations' practicality and value. Threats to validity and their effect on the results' soundness are not explicitly presented.

Regarding verifiability, independent verification of the paper's claimed contributions is difficult, though this is a difficult to address issue.

Regarding presentation, the paper's structure can be improved. Several challenges and advantages are repeated in many sections. Consider codifying them, analyzing them once, and then cross-referencing them from a table. Furrthermore, the identified challenges are given without any proposed means to address them. Most are later addressed through the proposed guidelines. Consider codifying and linking the two, again in tabular form. Along similar lines,  consider splitting the provided recommendations into a hirerachically numbered set of recommendations and a separate rationale exposition. In some places the exposition is not as clear as it could be.

Furthermore, many paragraphs, such as those in Section 5.8.1, start with a long-winded rationale before arriving at the recommendation. Consider using recommendations as each paragraph's thematic sentence.  The text is free from typos and style errors. The formatting follows the provided instructions, but could be improved. Please fix the capitalization of referenced titles, see e.g. reference 96 (should be Python, ChatGPT). Consider converting the RFC 2119 MUST/SHALL/MAY verbs into lowercase. Their uppercase appearance is distracting, and the paper contains guidelines, not a technical standard. Consider reducing in-text cross-references to other sections—they are distracting. If needed, add them in a separate section, as is done in many Design Pattern catalogues. The abstract is self-standing and summarizes succinctly the paper's essence. The paper could also benefit from the addition of a few figures to help navigating it.


Below is a list of more detailed comments.

Page 3, line 16: Consider providing some details or examples as motivation, perhaps specifically targetting LLMs.


Page 3, line 29: Consider also mentioning the  ACM SIGSOFT Empirical Standards for Software Engineering.


Page 3, line 33: LLMs are also a new tool, which requires fresh mothdological guidance.


Page 4, line 7: Consider changing "recent version" into "recent version of this document".


Page 4, line 9: Remove "xw"?


Page 4, line 38: Consider changing "advise" into "advice".


Section 2: The scope includes software code in addition to natural language, right?


Page 5, line 23: Also data generation, as in 4.1.4


Page 6, line 29: The numbering is wrong.


Page 7, line 38: Consider changing "inter-rater agreement" into "accuracy".


Page 8, line 16: Please clarify.


Section 4.1: It might be worth investigating the following philosophical question. Is it sound to consider human judgmenet as the gold standard against which LLM performance is evaluated? For example, this is not the approach scientists employ when evaluating the accuracy of spectrometer measurements.


Section 4.1.2: Several of the advantages listed here also apply to 4.1.1. Consider some form of merging to avoid gratuitous differences or repetitions.


Page 10, line 11: Please explain why this is an issue.


Page 10, line 32: The word synthesis also applies to this use, but under a different meaning: "the production of a substance from simpler materials after a chemical reaction" rather than "the mixing of different ideas, influences, or things to make a whole that is different, or new" as used at the beginning of the paragraph. To avoid confusion, consider splitting this case into a separate section with a title like "synthetic data generation".


Section 4.1.3: The examples provided here are the the wrong (meta) level compared to the other sections. If no direct examples can be found, consider mentioning this distinction.


Section 4.1.3: Several of the challenges listed here also apply to other sections. Consider some form of merging to avoid gratuitous differences or repetitions.


Page 12, line 32: Please clarify the meaning and implications of "should". Is this something the researchers should verify (if so, how) or is it a currently unatainable ideal?


Page 16, line 22: A key advantage is the automation of tasks previously executed by humans.


Page 16, line 44: Please … and replicability.


Section 5: Consider also including guidelines for reviewing papers that use LLMs. Following the providing guidelines is a start, but there are also things the reviewers should avoid, such as excessive requirements regarding verification. Furthermore, consider the space needed for fullfilling all the requirments; could much of the data be supplied as part of a replication package? If so which?


Section 5.2: Is the position regarding the requirement to disclosue version too timid? As stated, many providers do not make it possible to use a past version. I think more epistemological thought, deliberation, and discussion is needed regarding the fact that research with SAAS models may not be deterministically reproducible.  This is not neccessarily a fatal problem. Many research methods, such as ethnography, grounded theory, and action research, share this feature. However, in such cases additional emphasis is placed in methodological elements such as triangulation, reflexivity, audit trails, and peer debriefing. These measures aim to ensure trustworthiness, encompassing credibility, transferability, dependability, and confirmability—the qualitative counterparts to validity, generalizability, reliability, and objectivity in deterministic quantitative research. Consider discussing these issues and adjusting the recommendations.


Section 5.2.4: Consider expanding and explaining the drawbacks, advantages, and limitations of a 0 temperature setting regarding reproducibility.


Section 5.2.5: I recommend summarizing recommendations by study type also in a table. (Also applies to the other .5 subsections.)


Section 5.3: In general, for replicability we tend to distribute source code. So why here is the requirement only for abstract models (e.g. arghitecture diagrams, coordination logic), rather than concrete implementations? Consider requiring both.


Page 29, line 1: Why is "keeping a record of the actual conversation" "crucial for accuracy"? There are several other such statements in the paragraphs' concluding phrases, which read like AI-generated slop. Please review them carefully, removing those that don't add anything substantial and fixing those, such as this one, that read nicely but are actually incorrect.


Section 5.5.2: The text in the quotes appears to be paraphrased, so remove them (or adjust the text). Clarify what are "the first three categories".


Page 32, line 25: Please clarify how this is relevant to human validation.


Section 5.5.2: What is your recommendation given the cited low human-model and human-human agreements?


Section 5.5.4: Please clarify the relevance of the "struggle with adapting to AI-assisted work" to this section.


Section 5.6.1: Please clarify why including an open LLM baseline might not be possible if the study involves human participants.


Page 35, line 45: Consider changing "managed cloud APIs provided by proprietary vendors" into "vendor-provided managed proprietary cloud APIs".


Section 5.6: Consider tabulating the scientific advantages of moving from proprietary, to open-weight, to full-open models.


Page 37, line 15: Static analysis would be an even better example.


Page 37, line 4: Please clarify: what benchmarks is the example referring to?


Section 5.7.2: Most of the information presented here is (useful) background, not concrete examples. Consider moving it to an appropriate section.


Page 38, line 37: Please use a display equation


Page 38, line 49: The tasks mentioned here to not adhere to the problem types introduced  at the beginning of Section 5.7.2


Section 5.7: This section can benefit from a structured classification of the benchmarks described in Section 5.7.2.


Page 40, line 18: This is one of the most important issues. Consider placing it more prominently and providing concrete


Page 42, line 7: GPT-4o is a very coarse model identifier. Clarify whether the problem also applies to models sharing the same fingerprint.


Page 42, line 35: Please start the paragraph with a thematic sentence.


Page 44, line 26: The paragraph starts by discussing generalizability and then switches to a discussion of code duplication. Please structure accordingly.


Section 5.8: To aid transparency and provide context, the cost should be reported by breaking down its components, e.g. number of input tokens, output tokens, and corresponding unit costs. This allows prediciting future costs.


Section 5.8: Given that its benefits are very difficult to judge, I am not convinced regarding the value of an environmental impact assessment for scientific research. How would one evaluate CERN LHC, Mars space missions, ITER, NIF, and LLM model training in this context?


# Reviewer 2

The paper is about LLM usage in software engineering research. It first describes the main uses cases of LLMs in SE research and then proceeds with guidelines. These guidelines recommend that researchers declare LLM usage, report model versions and configurations, document tool architectures, disclose prompts, use human validation, employ open LLMs and suitable baselines, and articulate study limitations. The ultimate goal is to enable open science and ensure the reliability of research findings.

Main strengths:
- timeliness: This is a timely and well-structured contribution to the software engineering methodology literature There are already zillions of SE papers with LLMs, and there will be many more The paper provides a clear and actionable framework for improving the rigor and transparency of empirical studies involving LLMs.
- Relevance and Clear Motivation: The paper addresses a critical, contemporary problem in software engineering research: the challenge of maintaining scientific rigor (specifically reproducibility and replicability) in studies involving rapidly evolving, non-deterministic, and often opaque LLMs The motivation is clear, compelling, and immediately relevant to any researcher or practitioner in the field.
- Credible, Community-Driven Methodology: The guidelines are not the product of a single research group but are presented as a community effort that originated from discussions at a research  and was refined through workshops and reviews. This collaborative approach lends the guidelines authority and increases the likelihood of their adoption by the community.
- Actionable Guidelines: The eight guidelines are thorough, practical, and well-articulated.

Major Weaknesses:
- Too long: we want to encourage the community to read this, the longer the paper, the fewer the readers. Trim, cut. For example, the "study types" subsections in Sec 5 are heavy and confusing (it took me some time to understand they're referring to Sec 4), I would simply get rid of those subsections.
- Lack of overview: we should be able to read the paper in one page. Consolidate all guidelines in a table at the beginnning
- Usage of RFC terminology MUST/SHOULD: a paper, even community driven, cannot speak for the whole community, the paper it not a standard and EMSE is not a stndardization body. Peer-review is not a standardization method. I would recommend to NOT take the style a standard, this is unsound and confusing.
- Usage of MUST: this is too strong. even if I agree with the utmost importance of some guidelines, my general philosophy of science is to be be very cautious with undisputable truth and hard rules. Science is about taking a critical standpoint at everything, and about being able to take one's own path, regardless of the others command. I would remove the MUST.
- If some guidelines are too strong, it decreases the credibility of the whole effort. for example the suggestion to test results on commercial models "over an extended period of time" is methodologically sound but may be infeasible given the time and cost constraints of typical academic projects.
- Cherry-picking examples: there are many more example papers to cite, but it is not the goal of the paper to be a survey. Yet, how were the examples selected? bias towards the authors' paper? their collaborators

Minor:
Focus on Natural Language Use Cases -> Focus on Textual Use Cases. Code is not natural language.

Disclaimer: LLM Gemini 2.5 Pro has contributed to this review.



# Reviewer 3

PAPER SUMMARY:

This paper establishes guidelines and recommendations for software engineering researchers conducting empirical studies that use Large Language Models (LLMs). The guidelines are structured around a taxonomy of study types where LLMs serve various roles, such as tools for SE researchers (Annotators, Judges, Synthesis, and Subjects) or tools for software engineers (Studying LLM Usage, LLMs for New Tools, and Benchmarking). Furthermore, the paper presents concrete reporting guidelines covering essential aspects of reproducibility, including declaring LLM usage, documenting model versions and configurations, describing tool architectures, reporting prompts and interaction logs, advocating for human validation, using open LLMs as baselines, and meticulously reporting limitations and mitigations. Overall, the paper aims to promote validity and transparency in LLM-related SE research, recognizing the challenges posed by their non-deterministic nature, evolving versions, and
potential biases.

Strengths:

This research is timely for the SE community.

Covering the SE cycle and benchmarks highlights the importance of benchmarking every step and the challenges faced.

The guidelines enhance the validity, transparency, reproducibility, and replicability of empirical studies in SE that involve LLMs.

The taxonomy organizing LLM usage into seven distinct study types is well-structured and covers the landscape systematically.

The eight guidelines use MUST, SHOULD, MAY terminology to distinguish between essential and desired practices.

The methodology demonstrates real community engagement.

Weaknesses:

Insufficient Discussion of Trade-offs and Conflicts Between Guidelines. For example, using an open LLM baseline (Guideline 6) while also requiring multiple experimental repetitions (Guideline 7) and human validation (Guideline 5) could be prohibitively expensive for many researchers. How to prioritize the guidelines? Do you recommend any decision tree to define which study type is the most appropriate?

An Insufficient Treatment of Data Contamination and Leakage. While Section 5.8.1 mentions data leakage, the discussion is buried in the limitations section rather than being a standalone guideline. Given that benchmark contamination is acknowledged as a "major challenge," this deserves more prominence. What recommendations or validation strategies do you recommend?

Insufficient Guidance on Statistical Power and Sample Sizes. While the paper mentions power analysis in Guideline 5, there's no systematic guidance on determining appropriate sample sizes for LLM experiments, especially given non-determinism.

DETAILED COMMENTS:

This is a highly pertinent and timely paper for empirical SE community. While I think this paper should definitely be accepted, I have a few suggestions for the authors to improve before a possible publication. Hence, I recommend a Major Revision.

Several guidelines contain SHOULD recommendations that may be difficult to follow:

* Guideline 5.4 (Report full interaction logs): For large-scale studies with thousands of LLM calls, storage and privacy concerns may prohibit full disclosure
* Guideline 5.6 (Open LLM baseline): When state-of-the-art proprietary models significantly outperform open alternatives, including an underperforming baseline may provide limited scientific value
* Guideline 5.8 (Report costs): Cloud API costs fluctuate; reported costs may not reflect what future researchers will pay

The paper does not adequately address situations where guidelines conflict or where following all guidelines simultaneously is infeasible due to resource, privacy, or technical constraints. For instance, guideline 5 (human validation) and guideline 6 (open baseline) imply validating both commercial and open models, which increases human effort and cost. Small research groups might not even be able to run open-source baseline models, and models might be outdated compared to the access to commercial models. For studies where commercial models are 2-3x better than open alternatives, the baseline may not provide meaningful scientific insight.

Similarly, some guidelines depend on others in non-obvious ways; for example, guideline 5.3 assumes a documented model per guideline 5.2. Guideline 5.7 interacts with guideline 5.6 for the open LLM baseline. Please elaborate or add a dependency diagram or a checklist showing the logical flow of applying the guidelines.

While Guideline 5.7 mentions repeating experiments due to non-determinism, there is no systematic guidance on determining appropriate sample sizes or the number of repetitions for different study types. For a researcher working with LLM experiments, what would be a valid statistical sample and parameters to reproduce the experiment? What are the recommendations to compare models or outputs? How to select a metric to compare models or experiments as researchers mitigate data contamination, and metrics evolve?

While the RFC 2119 distinction is clear in principle, how should it be enforced?  What constitutes an acceptable justification for not meeting "should" criteria? How should reviewers handle partial compliance? Provide reviewer guidance or a compliance checklist to operationalize the guidelines in peer review.

While including examples from other domains (healthcare, social sciences) provides context, some readers may question their relevance to SE-specific challenges.
Ensure every cross-domain example is explicitly connected back to SE contexts.

Please consider the following references:

https://arxiv.org/html/2406.04244v1

https://arxiv.org/abs/2502.00678
