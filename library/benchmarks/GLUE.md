---
title: "GLUE"
tags:
  - type/benchmark
  - task/language-understanding
related_entries:
  - [[BERT (NAACL 2019)]]
task: "General language understanding"
metrics:
  - Matthews correlation (CoLA)
  - Accuracy (MNLI, QQP, QNLI, SST-2, RTE)
  - F1 score (MRPC, QQP)
datasets:
  - "CoLA, MNLI, MRPC, QNLI, QQP, RTE, SST-2, STS-B, WNLI"
leaderboard: "https://gluebenchmark.com/"
protocol: "9 diverse NLU tasks, single-task fine-tuning"
created: 2026-07-26
updated: 2026-07-26
---

GLUE (General Language Understanding Evaluation) is a collection of 9 diverse NLU tasks designed to evaluate model generalization across different linguistic phenomena. BERT achieved state-of-the-art on GLUE at the time of publication.