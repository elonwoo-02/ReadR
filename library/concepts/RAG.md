---
title: "RAG"
aliases:
  - Retrieval-Augmented Generation
tags:
  - type/concept
  - method/retrieval-augmented
related_entries:
  - [[RAG (NeurIPS 2020)]]
related_concepts:
  - [[Dense Passage Retrieval]]
  - [[Retrieval-Augmented Generation]]
key_papers:
  - "RAG (NeurIPS 2020)"
definition: "A paradigm that combines a retriever (dense or sparse) with a generative model, allowing the model to access external knowledge from a corpus during generation."
created: 2026-07-26
updated: 2026-07-26
---

RAG architectures consist of a retriever module that fetches relevant documents from a knowledge corpus, and a generator that conditions on both the input and the retrieved documents. This enables knowledge-intensive tasks without storing all knowledge in model parameters.

**Variants:**
- RAG-Sequence: same documents used for entire output sequence
- RAG-Token: different documents per output token
- Dense vs. sparse retrieval backends