---
type: "Academic Paper"
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
keywords:
  - Transformer
  - Self-Attention
  - Multi-Head Attention
  - Sequence-to-Sequence
  - Machine Translation
status: browsed
direction: nlp
source: "[[Vaswani et al. - 2023 - Attention Is All You Need.pdf]]"
doi: ""
url: ""
annotation: ""
concepts:
  - Self-Attention
  - Multi-Head Attention
  - Transformer
datasets:
  - WMT 2014
github: ""
generated: human
verified: unverified
created: 2026-07-26
updated: 2026-07-27
---

# Attention Is All You Need — Transformer 架构

提出 **Transformer**，一种完全基于注意力机制的新型序列转换模型，彻底摒弃递归和卷积。该架构依赖**multi-head self-attention**机制和**位置级前馈网络**，实现了更优的并行化和最先进的翻译质量。

**关键洞见：** Self-attention 可完全替代 RNN 进行序列建模，在所有位置上实现并行计算，同时捕获长程依赖。

**关键词：** Transformer, Self-Attention, Multi-Head Attention, Sequence-to-Sequence, Machine Translation

## Browse Summary

### Problem & Motivation

循环神经网络（RNN、LSTM、GRU）是序列转换的主导方法，但其序列性质阻碍了训练样本内部的并行化，在长序列长度时形成瓶颈。

### Method Overview

Transformer 使用编码器-解码器架构，用 **multi-head self-attention** 替代递归。每层有两个子层：multi-head self-attention 和位置级前馈网络，配合残差连接和层归一化。位置编码注入序列顺序信息。

### Key Results

| Task | Metric | Score | Previous SOTA |
|------|--------|-------|---------------|
| WMT 2014 En-De | BLEU | 28.4 | 26.9（集成） |
| WMT 2014 En-Fr | BLEU | 41.8 | 40.7（集成） |

- 在 8 个 GPU 上训练 3.5 天（远低于之前模型的耗时）
- 在大规模和有限训练数据下均能泛化到英语依存句法分析

### Significance & Impact

Transformer 成为几乎所有后续 NLP 突破（BERT、GPT、T5）的基础，后来扩展到视觉（ViT）、音频和多模态模型。
