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
source: ../../../../sources/papers/Dosovitskiy et al. - 2021 - An Image is Worth 16x16 Words Transformers for Image Recognition at Scale.pdf
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
benchmarks:
  - ImageNet
  - CIFAR-100
  - VTAB
created: 2026-07-26
updated: 2026-07-27
---
# An Image is Worth 16x16 Words — Vision Transformer (ViT)

Applies a **standard Transformer** directly to sequences of image patches, demonstrating that pure attention-based models can achieve state-of-the-art image classification when pre-trained at sufficient scale. The Vision Transformer (ViT) splits an image into fixed-size patches, linearly embeds them, and processes the resulting sequence with a standard Transformer encoder.

**Key insight:** CNNs are not strictly necessary for image recognition — a pure Transformer can match or exceed CNN performance when pre-trained on large enough datasets (14M–300M images).

**Keywords:** Vision Transformer, ViT, Image Classification, Self-Attention, Patch Embedding