# ReadR — AI 辅助指南

面向学术研究的 Obsidian 知识库模板，覆盖完整工作流：**sources → library → annotations → reviews**。

## 结构

### 四层架构

- `sources/` — 原始素材（只读）。子目录：papers/ web/ books/ talks/ misc/
- `library/` — 论文目录 + 知识提炼
  - `entries/` — 论文条目（按研究方向，替换 example/）
  - `concepts/` — 核心概念
  - `authors/` — 研究者
  - `datasets/` — 数据集
  - `benchmarks/` — 评测基准
  - `comparisons/` — 方法对比
  - `syntheses/` — 综合概述（子方向积 3+ 篇后写）
  - `projects/` — 在研项目
- `annotations/` — 精读笔记，同 library/entries/ 子方向结构
- `reviews/` — 综述论文

### 工作流

**INGEST** → PDF 放入 sources/papers/，在 library/entries/ 创建条目（status: to-read）

**BROWSE** → 阅读后写概要、打标签（status: browsed）。同步沉淀：提炼概念到 concepts/，记录研究者到 authors/，记录数据集到 datasets/，对比方法到 comparisons/，积 3+ 篇后写 syntheses/

*AI 可辅助：提取概念、研究者、数据集、基准；生成方法对比表格；撰写综合概述初稿。*

**CLOSE-READ** → 在 annotations/entries/ 下创建精读文件夹，更新 library 条目 annotation: 路径（status: close-read）

*AI 可辅助：按模板生成精读笔记，要求将论文中的图、表、公式在正文中穿插解释。*

**REVIEW** → 在 reviews/ 下撰写正式综述

## 规则

- `sources/` 只读，不可修改
- 所有文件/目录使用英文命名
- 论文条目用 `Short Title (Venue Year).md`
- YAML frontmatter 包含：title, authors, venue, tags, pdf, doi, rating
- tags 使用 category/key 风格（direction/ method/ task/ status/ venue/）
- 条目中通过 annotation/ concepts/ authors_related/ datasets/ benchmarks/ 字段关联到其他笔记

## AI 辅助细则

### BROWSE 阶段 — 知识沉淀辅助

AI 可在用户确认后执行以下操作：

- 从论文中提取核心概念 → 写入 `library/concepts/`，链接相关条目
- 提取研究者信息 → 写入 `library/authors/`，记录机构、研究方向
- 提取使用/贡献的数据集 → 写入 `library/datasets/`
- 提取评测基准 → 写入 `library/benchmarks/`
- 与同类方法对比 → 写入 `library/comparisons/`，生成对比表格
- 子方向积 3+ 篇后 → 撰写 `library/syntheses/` 综合概述

### CLOSE-READ 阶段 — 精读笔记生成

AI 按 `annotations/_template/reading-note.md` 模板生成精读笔记，遵循以下规则：

1. **逐节穿插图/表/公式** — 不允许只在文末汇总；在正文对应位置解释：
   - **图**：描述图表展示的内容、关键发现、与论点的关系。格式：`![Figure X](attachments/fig-XX.png) — 该图展示了…`
   - **表**：解读表格数据、对比结果、趋势。格式：`表 X：…` → 分析说明
   - **公式**：说明符号含义、推导逻辑、物理意义。格式：`公式 X：…` → 解释
2. **严格使用模板大纲** — 但图/表/公式需填充在对应小节内，而非笼统提及
3. **原文引用** — 关键段落引用原文（翻译或中英对照），标注页码
4. **个人评价不可省略** — 第六部分（个人评价与思考）必须撰写，体现批判性思考
