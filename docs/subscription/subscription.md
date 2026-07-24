# ReadR：把 Obsidian 变成一间属于人类研究者的文献工作室

用过 Obsidian 管论文的人，大多止步于建个文件夹。

我以前也一样。下载 PDF → 丢进文件夹 → 读完就忘。三个月后再看到同一篇，不记得自己读过，更不记得当时觉得哪里好、哪里有问题。试过 Notion，太重。试过 Zotero，标注功能强但笔记和知识体系是两张皮。试过直接写 markdown，写了一堆散文件，没有关联，没有生长。

直到看到 [**Karpathy 的 LLM Wiki**]([llm-wiki](https://gist.github.com/karpathy/442a6bf555914893e9891c11519de94f))——那篇著名的 gist。

## 一个很酷的想法，但方向不对

Karpathy 提出了一个三层架构：`raw/`（原始素材，只读）→ `wiki/`（AI 维护的知识库）→ `schema/`（规则配置）。AI 读你的资料，增量编译成 wiki，知识越用越多。这是一个非常漂亮的设计，创新在于把 LLM 从「每次重新检索」变成了「增量编译」，知识随时间复利增长。

但这里有一个天然的错位——**综述、方法论证、消融实验，最终是要人自己读懂、自己写出来的**。AI 可以帮你摘概念、建索引、生成对比表，但没法替你完成「精读」这一步。知识库的终点，也不该止步于一份自动更新的 wiki，而应该是一篇可以拿去发表的综述。

ReadR 就是在这个错位上做的一个 Obsidian vault 模板：AI 是助手，人是作者。

## 四层架构：把该分开的分开

ReadR 的核心是一个四层结构，每一层有清晰的读写规则：

```
sources/    →  原始素材（只读）        — 你下载，你不改
library/    →  论文目录 + 知识提炼     — 你整理，AI 辅助
annotations/ → 精读笔记（逐行啃）      — 你撰写，AI 打初稿
reviews/    →  综述论文（最终产出）    — 你写作，AI 不碰
```

四层之间用双向 wiki link 串起来：一篇论文条目链向它的精读笔记，也链向它涉及的概念、作者、数据集；综述反过来引用这些沉淀下的节点。读得越多，这张网越密，而不是越乱。

### 第一层：sources/ — 只读区

PDF 放进去，永不修改。这是铁律。AI 不能改，你也不能改。

这是从 Karpathy 那借来的设计——层分离。不可变层保证了原始数据永远可信，任何时候回头看都不会因为「我当时好像改过这个文件」而困惑。

子目录按类型分：`papers/`、`web/`、`books/`、`talks/`、`misc/`。仅此而已，不需要复杂的分类。

### 第二层：library/ — 你的论文目录 + 知识提炼

每篇论文一条 markdown 文件，YAML frontmatter 承载结构化元数据：

```yaml
---
title: "Attention Is All You Need"
authors:
  - Vaswani, Ashish
venue: "NeurIPS 2017"
tags:
  - direction/nlp
  - method/transformer
  - status/browsed
  - venue/neurips
pdf: ../../sources/papers/vaswani2017.pdf
doi: 10.xxxx/xxxxx
rating: ⭐⭐⭐⭐
annotation: annotations/entries/nlp/attention-is-all-you-neurips-2017/
concepts: [self-attention, multi-head-attention, positional-encoding]
authors_related: [noam-shazeer, niki-parmar]
datasets: [wmt-2014]
benchmarks: [bleu]
---
```

这里的关键不是模板，而是**浏览时同步沉淀**的理念：

读一篇论文时，看到一个新的核心概念 → 去 `library/concepts/` 新建或追加。发现一个有价值的研究者 → 去 `library/authors/` 记录。论文用了哪个数据集、在哪个 benchmark 上评测 → 分别记到 `datasets/` 和 `benchmarks/`。几篇论文用了同类方法 → 去 `comparisons/` 写对比表格。一个子方向积了三篇以上 → 去 `syntheses/` 写综合概述。

每一篇论文只浏览一次，但理解的深度在不断累积。

### 第三层：annotations/ — 精读笔记

这是 ReadR 和 llm-wiki 最大的区别。llm-wiki 没有独立的精读层——它的 wiki 就是终点了。但论文不是用来「存」的，是用来「啃」的。

只有 `status: close-read` 的论文才在这里建文件夹。每篇一个目录：

```
annotations/entries/your-direction/
└── Attention Is All You Need (NeurIPS 2017)/
    ├── index.md              ← 完整的精读笔记
    ├── wechat.md             ← 公众号版本（可选）
    ├── code/                 ← 代码笔记（可选）
    └── attachments/          ← 截图、示意图
```

精读笔记的大纲覆盖六个部分：基本信息 → 摘要与核心问题 → 核心方法 → 实验与结果 → 讨论与分析 → 个人评价与思考。

其中最重要、也最容易偷懒的是最后一部分——个人评价与思考。读论文的终点不是「读懂了」，而是「你有话想说」。这篇论文给你什么启发？有什么疑问？如果你是作者，会在哪里改进？

精读笔记的价值恰恰在于人自己把论文「嚼碎」这个过程，机器摘要替代不了。AI 可以按模板生成初稿，但公式推导、实验分析、消融研究需要人逐行读、逐行写。

### 第四层：reviews/ — 综述论文

这是最终产出。写综述的时候，你在 `concepts/`、`syntheses/`、`comparisons/` 里积累的所有东西全都派上了用场。每一篇论文的条目、每一份综合概述、每一张对比表格——都是在为这一刻准备。

ReadR 支持多格式输出：`.md`、`.pdf`、`.tex`、`.bib`。你可以写到一定程度后导出 LaTeX 继续完善，也可以直接在 Obsidian 里写完。

## 工作流：从一篇 PDF 到一篇综述

四步走下来，每一步对应四层结构里的一层：

```
sources/ → INGEST → library/ → BROWSE → library/ + 各知识目录
                                        ↓
                                  CLOSE-READ → annotations/
                                        ↓
                                     REVIEW → reviews/
```

**① INGEST（入库）**
下载 PDF → `sources/papers/` → 在 `library/entries/` 创建条目，YAML frontmatter 填好，状态标为 `to-read`。这一步只是「收进来」，还没有产生任何理解。

**② BROWSE（浏览 + 沉淀）**
读摘要和引言，写一段自己的总结，打标签，状态改成 `browsed`。关键在「沉淀」两个字——浏览过程中顺手把遇到的新概念放进 `library/concepts/`，新的研究者放进 `library/authors/`，数据集和 benchmark 各归各位；同一方向读到第三篇以上，就在 `library/syntheses/` 里写一份小综述，把这几篇的关系理清楚。这一步 AI 可以帮忙提取概念、生成对比表、起草综述初稿，但「这个概念值不值得单独建档」还是人来判断。

**③ CLOSE-READ（精读）**
只有真正逐行读过、值得深挖的论文才进入这一步——在 `annotations/entries/` 下建一个独立文件夹，把公式推导、实验设置、消融结果按模板写清楚，图表直接嵌在正文里。更新条目的 `annotation` 路径和 `status`。

**④ REVIEW（综述）**
当某个方向积累到足够多的精读笔记和阶段性综述，就参考 `concepts/`、`syntheses/`、`comparisons/` 里沉淀下来的节点，动手写一篇正式的 survey，放进 `reviews/`，同时保留 md、pdf、tex 多种格式。

四步走下来，AI 参与的是「提取」和「起草」，人始终负责「判断」和「下笔」——这也是 ReadR 和纯 AI 维护 wiki 最大的不同。

## AI 怎么帮忙

ReadR 把 AI 定位为助手，不是主人。AI 只在两个环节协助：

**BROWSE 阶段**：帮你从论文中提取概念、研究者、数据集、基准，生成方法对比表格，甚至草拟综合概述。你审一遍确认就好。

**CLOSE-READ 阶段**：按模板生成精读笔记初稿。和别的工具不同，ReadR 要求 AI 把论文中的图、表、公式穿插在正文对应位置解释——不是在文末汇总，而是在「核心方法」那节讲公式，在「实验与结果」那节插表格，在「方法总览」那节放框架图。

这个要求写进了 CLAUDE.md 和模板里。如果搭配 Claude Code 或其他 AI 工具，它会自动遵守这些规则。

## 和 llm-wiki 的本质区别

| 维度 | llm-wiki | ReadR |
|------|----------|-------|
| 目标用户 | AI Agent（人审核） | 人类研究者（AI 辅助） |
| 知识单元 | 文章、视频、笔记、文档 | 学术论文 |
| 精读层 | 无 | annotations/（独立精读笔记） |
| 产出层 | 无（wiki 即终点） | reviews/（可发表综述） |
| 主要作者 | AI Agent | 人类 |
| 合成机制 | AI 自动更新 overviews | 人手写 syntheses/ → reviews/ |

三个核心差异：

1. **精读层** — llm-wiki 没有对应物。机器可以总结，但公式推导、实验分析、消融研究需要人逐行读、逐行写。
2. **综述层** — llm-wiki 的 wiki 本身就是终点。科研的终点是可发表的 survey，需要人整合几十篇论文形成观点。
3. **实体拆分** — llm-wiki 用统一的 entities/ 装人物/组织/产品。科研场景下 researchers / datasets / benchmarks 是三类独立实体，各有不同的查询维度。

## 怎么开始

```bash
git clone https://github.com/elonwoo-02/ReadR.git
```

用 Obsidian 打开 → "Open folder as vault" → 选择 ReadR/。目录结构已经搭好，example 子目录告诉你怎么放论文条目。替换成自己的研究方向，然后开始读第一篇论文。

想用 AI 辅助的话，配 Claude Code 或其他工具也行。CLAUDE.md 里写好了全部规则，AI 会自动遵循。

项目地址在文章末的阅读原文位置，如果这篇文章对你有用，欢迎去 GitHub 点个 Star ⭐。

---

**一些还没做的事，欢迎来一起搞**

ReadR 目前是一个框架和模板，核心工作流已经跑通。下一步可能的方向：

- **Agent 工作流编排**：用 Skill/MCP 把四步管线封装成可复用的自动化任务
- **独立应用**：做成带 UI 的 Web 或桌面端，降低使用门槛
- 自动化脚本：PDF 入库时自动提取元信息、生成条目初稿
- 精读模板的更多语种/风格变体
- 与 Zotero 等文献管理工具的桥接
- 更丰富的 syntheses/ 模板

如果你也在用 Obsidian 管论文，欢迎提 issue 或 PR。
