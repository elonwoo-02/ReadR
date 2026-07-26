---
title: "Transformer vs RAG: Architecture Comparison"
tags:
  - type/comparison
  - direction/transformer
  - direction/rag
related_entries:
  - [[Attention Is All You Need (NeurIPS 2017)]]
  - [[RAG (NeurIPS 2020)]]
scope: "Architecture design and knowledge handling"
methods:
  - "Transformer: pure parametric knowledge"
  - "RAG: parametric + non-parametric knowledge"
decision_criteria:
  - "Knowledge freshness"
  - "Parameter efficiency"
  - "Factual accuracy"
related_concepts:
  - [[Transformer]]
  - [[RAG]]
created: 2026-07-26
updated: 2026-07-26
---

## Comparison

| Aspect | Transformer | RAG |
|--------|-------------|-----|
| Knowledge storage | All in parameters | External corpus + parameters |
| Freshness | Requires retraining | Update corpus independently |
| Context window | Fixed (limited) | Extendable via retrieval |
| Factual accuracy | Hallucination prone | Grounded in retrieved docs |
| Inference cost | O(n²) attention | Additional retrieval step |

## Decision

RAG is preferred for knowledge-intensive tasks where factual accuracy is critical. Pure Transformers are better for tasks requiring deep reasoning within a fixed context window.