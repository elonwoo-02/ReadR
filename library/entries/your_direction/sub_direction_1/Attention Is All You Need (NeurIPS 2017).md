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
method: "Transformer"
task: "Machine Translation"
status: browsed
direction: nlp
source: ../../../../sources/papers/Vaswani et al. - 2023 - Attention Is All You Need.pdf
doi: ""
annotation_path: ""
concepts:
  - Self-Attention
  - Multi-Head Attention
  - Transformer
datasets:
  - WMT 2014
benchmarks:
  - BLEU
created: 2026-07-26
updated: 2026-07-27
---
# Attention Is All You Need — Transformer architecture

Proposes the **Transformer**, a novel sequence transduction model based *solely* on attention mechanisms, dispensing with recurrence and convolutions entirely. The architecture relies on a **multi-head self-attention** mechanism and **position-wise feed-forward networks**, achieving superior parallelization and state-of-the-art translation quality.

**Key insight:** Self-attention can replace RNNs entirely for sequence modeling, enabling parallel computation across all positions while capturing long-range dependencies.

**Keywords:** Transformer, Self-Attention, Multi-Head Attention, Sequence-to-Sequence, Machine Translation

## Browse Summary

### Problem
Recurrent neural networks (RNNs, LSTMs, GRUs) were the dominant approach for sequence transduction, but their sequential nature precludes parallelization within training examples, creating a bottleneck at longer sequence lengths.

### Method
The Transformer uses an encoder-decoder architecture with **multi-head self-attention** instead of recurrence. Each layer has two sub-layers: multi-head self-attention and a position-wise feed-forward network, with residual connections and layer normalization. Positional encodings inject sequence order information.

### Key Results
| Task | Metric | Score | Previous SOTA |
|------|--------|-------|---------------|
| WMT 2014 En-De | BLEU | 28.4 | 26.9 (ensemble) |
| WMT 2014 En-Fr | BLEU | 41.8 | 40.7 (ensemble) |

- Trained in 3.5 days on 8 GPUs (a fraction of previous models)
- Generalizes to English constituency parsing with both large and limited training data

### Significance
The Transformer became the foundation for virtually all subsequent NLP breakthroughs (BERT, GPT, T5) and later extended to vision (ViT), audio, and multimodal models.