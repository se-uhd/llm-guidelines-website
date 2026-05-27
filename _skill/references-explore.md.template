# Explore Mode

This file is loaded by `../SKILL.md` when the user is planning or discussing an empirical SE study involving an LLM (slash command `/llm-guidelines:explore`, or when intent matches "discuss / plan / which study type"). For the audience, tone, mode-selection rules, shared constraints, and full file indices, see [`../SKILL.md`](../SKILL.md).

## When to use

Stay in explore mode when the user:

1. Asks a general question about the guidelines, the scope statement, or the study-type taxonomy.
2. Is planning a study and wants to discuss design choices, what to log, what baselines to consider, or which study type the work falls under.
3. Is preparing a replication package and wants to know what to include for a study involving an LLM.

If the conversation reveals that a draft already exists and the user wants a structured pass over it, switch to review mode and follow [`./review.md`](./review.md).

## Workflow

1. **Identify which area the question touches** (scope, study type, guideline, checklist). A single question can span several.
2. **Load on demand.** Read only the file or files that bear on the question. Do not preload the full bundle.
3. **Answer with citations.** Quote or paraphrase the relevant passage and link to the file (e.g., `./guidelines/design.md`). Use the same RFC 2119 levels the guideline uses (**must**, **should**); do not invent severity.
4. **For study-design discussions**, walk the user through what the relevant guidelines would expect to see reported. This is advice for planning, not a checklist of violations. Surface the choices the guidelines call out (for example, open versus proprietary models for `open-llm`, or what to log for `traces`) and present the trade-offs the guideline discusses, then let the user decide.
5. **Stay in scope.** Only address topics the bundled files cover. If the user asks about something the guidelines do not address (general statistical methods, theoretical contribution, narrative structure, writing quality), say so explicitly and, where relevant, point them to standard SE methodology references rather than answering from training data.
6. **Do not write a report file.** Explore mode is a conversation. Nothing is written to disk unless the user asks.

## Mode-specific notes

- Explore mode writes nothing unless the user explicitly asks for a file.
- The user's view of the conversation is the deliverable; there is no report template.
- See [`../SKILL.md`](../SKILL.md) for the shared constraints (severity, scope, author-writing exclusion, no file modifications). They apply here.
