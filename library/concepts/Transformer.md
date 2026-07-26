---
title: "Transformer"
aliases:
  - Transformer Architecture
  - Transformer Model
tags:
  - type/concept
related_entries:
  - Attention Is All You Need (NeurIPS 2017)
related_concepts:
  - Self-Attention
  - Multi-Head Attention
key_papers:
  - Attention Is All You Need (NeurIPS 2017)
definition: "A neural network architecture based solely on attention mechanisms, dispensing with recurrence and convolutions entirely. The Transformer processes sequences in parallel using a stacked encoder-decoder structure built on multi-head self-attention and position-wise feed-forward networks."
created: 2026-07-26
updated: 2026-07-26
---

# Transformer

## Definition / Summary

The Transformer is a sequence transduction model that relies entirely on self-attention to compute representations of its input and output, without using sequence-aligned RNNs or convolution. It consists of an encoder (6 layers) and a decoder (6 layers), each with multi-head self-attention and feed-forward sub-layers, plus residual connections and layer normalization.

**Key innovation:** Replacing recurrent computation with attention allows full parallelization during training, making it significantly faster than RNN-based models while capturing long-range dependencies more effectively.

## Related Research

- Related entries: [[Attention Is All You Need (NeurIPS 2017)]]
- Related concepts: [[Self-Attention]], [[Multi-Head Attention]]
- Successors: BERT, GPT, ViT

## Evidence & Citations

- [x] "We propose a new simple network architecture, the Transformer, based solely on attention mechanisms, dispensing with recurrence and convolutions entirely." (Vaswani et al., 2017, p.2)
- [x] "The Transformer allows for significantly more parallelization and can reach a new state of the art in translation quality after being trained for as little as twelve hours on eight P100 GPUs." (Vaswani et al., 2017, p.2)

## Personal Notes

The Transformer is arguably the most influential architecture of the 2020s. Its key advantage is computational — by removing the sequential bottleneck of RNNs, it enabled training on orders of magnitude more data, which directly led to the scaling laws era. The "attention is all you need" claim turned out to be largely true for NLP, and later for vision (ViT) and beyond.