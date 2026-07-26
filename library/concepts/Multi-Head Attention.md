---
title: "Multi-Head Attention"
aliases:
  - MHA
tags:
  - type/concept
related_entries:
  - Attention Is All You Need (NeurIPS 2017)
related_concepts:
  - Transformer
  - Self-Attention
key_papers:
  - Attention Is All You Need (NeurIPS 2017)
definition: "An extension of self-attention that runs multiple attention operations in parallel (heads), each operating on linearly projected queries, keys, and values. The outputs are concatenated and projected again, allowing the model to jointly attend to information from different representation subspaces."
created: 2026-07-26
updated: 2026-07-26
---

# Multi-Head Attention

## Definition / Summary

Multi-head attention projects queries, keys, and values h times with different learned linear projections, performs attention in parallel on each projected version, concatenates the results, and projects again. With 8 heads in the base Transformer, each head operates on d_k = d_model/h = 64 dimensions.

**Key formula:** `MultiHead(Q,K,V) = Concat(head_1,...,head_h) W^O`, where `head_i = Attention(QW_i^Q, KW_i^K, VW_i^V)`

## Related Research

- Related entries: [[Attention Is All You Need (NeurIPS 2017)]]
- Related concepts: [[Transformer]], [[Self-Attention]]

## Evidence & Citations

- [x] "Multi-head attention allows the model to jointly attend to information from different representation subspaces at different positions. With a single attention head, averaging inhibits this." (Vaswani et al., 2017, p.4)
- [x] The base Transformer uses h=8 parallel attention heads, with d_k = d_v = d_model/h = 64. (Vaswani et al., 2017, p.5)

## Personal Notes

Multi-head attention is the key mechanism that gives the Transformer its representational power. Each head can learn to focus on different types of relationships (e.g., syntactic vs. semantic), and the concatenation reunifies these perspectives. This is conceptually similar to having multiple independent attention "experts".