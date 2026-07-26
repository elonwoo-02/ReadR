---
title: "Self-Attention"
aliases:
  - Scaled Dot-Product Attention
tags:
  - type/concept
  - method/attention
related_entries:
  - [[Attention Is All You Need (NeurIPS 2017)]]
related_concepts:
  - [[Transformer]]
  - [[Multi-Head Attention]]
key_papers:
  - "Attention Is All You Need (NeurIPS 2017)"
definition: "A mechanism that computes weighted representations of a sequence by attending to all positions in the same sequence, using queries, keys, and values derived from the input."
created: 2026-07-26
updated: 2026-07-26
---

Self-attention computes attention scores between every pair of positions in a sequence: `Attention(Q,K,V) = softmax(QK^T / sqrt(d_k)) V`. The scaling factor `sqrt(d_k)` prevents vanishing gradients in the softmax.

**Properties:**
- Permutation invariant (requires positional encoding)
- O(n²) complexity in sequence length
- Captures long-range dependencies directly