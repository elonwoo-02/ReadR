---
title: "Transformer-based Language Models: From BERT to LLaMA"
tags:
  - type/synthesis
  - direction/llm
related_entries:
  - [[BERT (NAACL 2019)]]
  - [[InstructGPT (NeurIPS 2022)]]
  - [[LLaMA (arXiv 2023)]]
direction: "direction/llm"
covered_entries:
  - "[[BERT (NAACL 2019)]]"
  - "[[InstructGPT (NeurIPS 2022)]]"
  - "[[LLaMA (arXiv 2023)]]"
coverage_status: "draft"
open_questions:
  - "How does scaling efficiency trade off with alignment quality?"
  - "Can open-source models match closed-source at the same scale?"
created: 2026-07-26
updated: 2026-07-26
---

## Overview

The evolution of Transformer-based language models has progressed through three major phases:

1. **Encoder-only pre-training** (BERT, 2019) — bidirectional understanding
2. **Alignment via RLHF** (InstructGPT, 2022) — instruction following
3. **Open-source scaling** (LLaMA, 2023) — efficient training on public data

### Key Trend

The field has shifted from "bigger is better" to "efficient scaling with alignment," where data quality and training efficiency matter as much as model size.

### Open Questions

- Can RLHF generalize beyond English instructions?
- How do we evaluate alignment beyond surface-level metrics?