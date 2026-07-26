---
title: "Self-Attention"
aliases:
  - Intra-Attention
  - Scaled Dot-Product Attention
tags:
  - type/concept
related_entries:
  - Attention Is All You Need (NeurIPS 2017)
related_concepts:
  - Transformer
  - Multi-Head Attention
key_papers:
  - Attention Is All You Need (NeurIPS 2017)
definition: "An attention mechanism that relates different positions of a single sequence to compute a representation of that sequence. The Transformer uses scaled dot-product attention: Attention(Q,K,V) = softmax(QK^T/√d_k)V."
created: 2026-07-26
updated: 2026-07-26
---

# Self-Attention

## Definition / Summary

Self-attention (also called intra-attention) computes a weighted sum of values, where the weights are derived from a compatibility function between a query and all keys. In the Transformer, this is implemented as **scaled dot-product attention**: the dot product of queries and keys is scaled by 1/√d_k before applying softmax.

**Key formula:** `Attention(Q,K,V) = softmax(QK^T / √d_k) V`

The scaling factor √d_k prevents the dot products from growing too large in magnitude, which would push the softmax into regions with extremely small gradients.

## Related Research

- Related entries: [[Attention Is All You Need (NeurIPS 2017)]]
- Related concepts: [[Transformer]], [[Multi-Head Attention]]

## Evidence & Citations

- [x] "Self-attention, sometimes called intra-attention is an attention mechanism relating different positions of a single sequence in order to compute a representation of the sequence." (Vaswani et al., 2017, p.3)
- [x] "We suspect that for large values of d_k, the dot products grow large in magnitude, pushing the softmax function into regions where it has extremely small gradients. To counteract this effect, we scale the dot products by 1/√d_k." (Vaswani et al., 2017, p.4)

## Personal Notes

The scaling factor 1/√d_k is a small but crucial detail. Without it, training becomes unstable at higher dimensions. This is a good example of the practical engineering thinking that made the Transformer work.