---
title: "RLHF"
aliases:
  - Reinforcement Learning from Human Feedback
tags:
  - type/concept
  - method/rlhf
related_entries:
  - [[InstructGPT (NeurIPS 2022)]]
related_concepts:
  - [[Instruction Tuning]]
key_papers:
  - "InstructGPT (NeurIPS 2022)"
definition: "A technique that aligns language models with human preferences by training a reward model on human comparisons and then optimizing the policy with reinforcement learning (PPO)."
created: 2026-07-26
updated: 2026-07-26
---

RLHF involves three stages: (1) supervised fine-tuning on human demonstrations, (2) training a reward model on human preference comparisons, and (3) optimizing the language model policy against the reward model using PPO.

**Key components:**
- Human preference data collection
- Reward model training
- PPO-based policy optimization
- KL penalty to prevent reward hacking