---
title: "Attention Is All You Need"
authors:
  - Vaswani, Ashish
  - Shazeer, Noam
  - Parmar, Niki
  - Uszkoreit, Jakob
  - Jones, Llion
  - Gomez, Aidan N.
  - Kaiser, Łukasz
  - Polosukhin, Illia
venue: "NeurIPS 2017"
tags:
  - direction/nlp
  - method/transformer
  - task/translation
  - status/to-read
  - venue/NeurIPS
pdf: ../../sources/papers/Vaswani et al. - 2023 - Attention Is All You Need.pdf
doi: ""
rating: ⭐⭐⭐⭐⭐
annotation:
concepts:
  - Self-Attention
  - Multi-Head Attention
  - Transformer
authors_related:
  - Vaswani, Ashish
  - Shazeer, Noam
datasets:
  - WMT 2014
benchmarks:
  - BLEU
---
# Attention Is All You Need — Transformer architecture

Proposes the **Transformer**, a novel sequence transduction model based *solely* on attention mechanisms, dispensing with recurrence and convolutions entirely. The architecture relies on a **multi-head self-attention** mechanism and **position-wise feed-forward networks**, achieving superior parallelization and state-of-the-art translation quality.

**Key insight:** Self-attention can replace RNNs entirely for sequence modeling, enabling parallel computation across all positions while capturing long-range dependencies.

**Keywords:** Transformer, Self-Attention, Multi-Head Attention, Sequence-to-Sequence, Machine Translation