---
title: "Transformer"
aliases:
  - Transformer Architecture
tags:
  - type/concept
  - direction/transformer
related_entries:
  - [[Attention Is All You Need (NeurIPS 2017)]]
  - [[BERT (NAACL 2019)]]
  - [[LLaMA (arXiv 2023)]]
related_concepts:
  - [[Self-Attention]]
  - [[Multi-Head Attention]]
key_papers:
  - "Attention Is All You Need (NeurIPS 2017)"
definition: "A neural architecture based solely on attention mechanisms, replacing recurrent and convolutional layers. The core innovation is the scaled dot-product attention applied in parallel across multiple heads."
created: 2026-07-26
updated: 2026-07-26
---

The Transformer is the foundational architecture for modern LLMs. It consists of an encoder and decoder stack, each composed of multi-head self-attention and feed-forward networks with residual connections and layer normalization.

**Key innovations:**
- Multi-head self-attention for parallel sequence processing
- Positional encoding to capture sequence order
- No recurrence, enabling full parallelization during training