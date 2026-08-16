---
title: "An Image is Worth 16x16 Words: Transformers for Image Recognition at Scale"
authors:
  - Dosovitskiy, Alexey
  - Beyer, Lucas
  - Kolesnikov, Alexander
  - Weissenborn, Dirk
  - Zhai, Xiaohua
  - Unterthiner, Thomas
  - Dehghani, Mostafa
  - Minderer, Matthias
  - Heigold, Georg
  - Gelly, Sylvain
  - Uszkoreit, Jakob
  - Houlsby, Neil
venue: "ICLR 2021"
method: "Vision Transformer"
task: "Image Classification"
status: to-read
direction: cv
source: "[[Dosovitskiy et al. - 2021 - An Image is Worth 16x16 Words Transformers for Image Recognition at Scale.pdf]]"
doi: ""
annotation_path: ""
concepts:
  - Vision Transformer
  - Patch Embedding
datasets:
  - ImageNet
  - ImageNet-21k
  - JFT-300M
  - CIFAR-100
  - VTAB
created: 2026-07-26
updated: 2026-07-27
github: ""
generated: human
verified: unverified
---

# An Image is Worth 16x16 Words — 视觉 Transformer（ViT）

将**标准 Transformer** 直接应用于图像块的序列，证明纯注意力模型在足够大规模预训练下可达到最先进图像分类性能。Vision Transformer（ViT）将图像分割为固定大小的块，线性嵌入，然后用标准 Transformer 编码器处理所得序列。

**核心洞见：** CNN 并非图像识别的必需——纯 Transformer 在足够大预训练数据集（1400 万–3 亿张图像）上可匹配或超越 CNN 性能。

**关键词：** Vision Transformer, ViT, 图像分类, Self-Attention, Patch Embedding
