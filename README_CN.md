# ReadR

<p align="center">
  <strong>为人类研究者设计的 AI 辅助学术知识库</strong><br>
  四层架构 — sources → library → annotations → reviews
</p>

<p align="center">
  <a href="#架构">架构</a> •
  <a href="#工作流">工作流</a> •
  <a href="#wiki-链接拓扑">链接拓扑</a> •
  <a href="#与-llm-wiki-对比">对比</a> •
  <a href="#快速开始">快速开始</a> •
  <a href="#致谢">致谢</a>
</p>

<p align="center">
  <a href="README.md">English</a> | 中文
</p>

---

## 架构

```
┌──────────────────────────────────────────────────────────┐
│                     SCHEMA LAYER                         │
│          CLAUDE.md — 操作规则、命名约定、工作流              │
├─────────────┬─────────────┬───────────────┬──────────────┤
│             │             │               │              │
│  sources/   │  library/   │ annotations/  │   reviews/   │
│  原始素材    │  论文目录    │  精读笔记       │   综述论文    │
│  (只读)      │ + 知识提炼   │               │   (产出)     │
│             │             │               │              │
│  不可变      │  你整理      │  你撰写        │  你写作      │
│             │             │               │              │
└─────────────┴─────────────┴───────────────┴──────────────┘
       ↑             ↑              ↑
       └─────────────┴──────────────┘
              wiki-link 互联
```

### 设计原则

- **sources 不可变** — PDF 和剪藏一旦放入，永不修改
- **一份源，一条目** — 每篇论文在 library/entries/ 中只有一个条目
- **精读后才写 annotation** — annotations/ 是精读产物，不是浏览笔记
- **知识沉淀伴随浏览** — concepts/ authors/ datasets/ 等是浏览时同步完成的提炼
- **synthesis 桥接 review** — syntheses/ 是从"读论文"到"写综述"的中间态

### 目录结构

```
├── sources/                        原始素材（只读）
│   ├── papers/                     学术论文 PDF
│   ├── web/                        网页文章、博客
│   ├── books/                      书籍/专著章节
│   ├── talks/                      讲座、课程
│   └── misc/                       其他
│
├── library/                        论文目录 + 知识提炼
│   ├── _index.md                   总索引（自动生成）
│   ├── _template/                  条目模板
│   ├── entries/                    论文条目（按研究方向）
│   │   └── your_direction/         替换为你的方向
│   │       ├── sub_direction_1/
│   │       └── sub_direction_n/
│   ├── concepts/                   核心概念
│   ├── authors/                    研究者
│   ├── datasets/                   数据集
│   ├── benchmarks/                 评测基准
│   ├── comparisons/                方法对比
│   ├── syntheses/                  综合概述
│   └── projects/                   在研项目
│
├── annotations/                    精读笔记
│   ├── _template/
│   │   └── reading-note.md         精读笔记模板
│   └── entries/                    同 library/entries/ 结构
│       └── your_direction/
│           ├── sub_direction_1/
│           └── sub_direction_n/
│
├── reviews/                        综述论文
│   └── templates/
│       └── writing_constraints_template.md
│
├── docs/                           项目文档
│   ├── column/                     "四层架构"专栏系列
│   └── subscription/               订阅信息
│
├── scripts/                        自动化工具
│   └── ReadR.ps1                   校验与索引生成
│
├── CLAUDE.md                       AI 辅助契约
└── .gitignore
```

### 四层详解

#### sources/ — 原始素材层

**规则：** 只读。AI 不可修改。存放所有原始材料。

```
sources/
├── papers/      学术论文、预印本 PDF
├── web/         技术博客、新闻报道
├── books/       书籍章节、专著摘录
├── talks/       会议演讲、课程录像/笔记
└── misc/        其他（技术报告、代码说明等）
```

#### library/entries/ — 论文条目

每篇论文一个 markdown 文件，YAML frontmatter 承载结构化元数据。

```yaml
---
title: "Full Paper Title"
authors:
  - Last, First
venue: "Conference/Journal (Year)"
tags:
  - direction/your-direction
  - method/your-method
  - task/your-task
  - status/to-read          # to-read | browsed | close-read
  - venue/abbreviation
pdf: ../../sources/papers/paper.pdf
doi: 10.xxxx/xxxxx
rating: ⭐⭐⭐⭐
annotation:                 # 精读后填写路径
concepts: []                # 关联的概念
authors_related: []         # 关联的研究者
datasets: []                # 使用的数据集
benchmarks: []              # 使用的基准
---
```

**命名规范：** `Short Title (Venue Year).md`，例如 `Attention Is All You Need (NeurIPS 2017).md`。

#### annotations/ — 精读笔记

只有 `status: close-read` 的论文才创建精读笔记。每篇论文一个文件夹。（可 AI 辅助生成，图/表/公式穿插于正文解释。）

```
annotations/entries/your-direction/
└── Paper Name (Venue Year)/
    ├── index.md              ← 完整精读笔记
    ├── attachments/          ← 图片（fig-01.png 风格命名）
    └── code/                 ← 代码笔记（可选）
```

#### reviews/ — 综述论文

最终产出。可包含多格式文件。

```
reviews/your-survey/
├── outline.md
├── references.bib
├── survey.md
├── survey.pdf
└── survey.tex
```

#### docs/ — 项目文档

辅助项目文档，支撑 vault 方法论。

```
docs/
├── column/                    "四层架构"专栏系列
│   ├── 00-开篇词-为什么你的文献库读完就是坟场.md
│   ├── 01-四层架构-给论文管理设计一套读写权限.md
│   ├── 02-元数据设计-YAML与wiki-link拓扑.md
│   ├── 03-人机分工-AI能做什么不能做什么.md
│   ├── 04-知识沉淀的最小动作-从浏览到精读.md
│   └── 05-工具化-封装成可复用的AgentSkill.md
├── literature-review/         学术文献综述与背景
└── subscription/              订阅信息
```

#### scripts/ — 自动化工具

PowerShell 脚本 `ReadR.ps1`，用于 vault 维护：
- **校验**（`-Validate`）— 检查 YAML frontmatter、必填字段和 wiki-link 完整性
- **更新索引**（`-UpdateIndex`）— 自动生成 `library/_index.md`，包含论文统计和阅读状态

---

## 工作流

```
sources/     library/      annotations/    reviews/
  │             │              │              │
  ▼             ▼              ▼              ▼
┌──────┐   ┌──────────┐   ┌─────────┐   ┌──────────┐
│INgest│──▶│  Browse  │──▶│CloseRead│──▶│  Review   │
│ 入库  │   │ 浏览/粗读 │   │  精读   │   │ 文献综述  │
└──────┘   └─────┬────┘   └─────────┘   └──────────┘
                 │
                 ▼
             concepts/         ← 浏览时同步沉淀
             authors/
             datasets/
             benchmarks/
             comparisons/
             syntheses/        ← 子方向积累 3+ 篇后写
             projects/
```

### 1. INGEST — 入库

下载 PDF → 放入 `sources/papers/` → 在 `library/entries/` 下创建论文条目，填写 YAML，设置 `status: to-read`。

### 2. BROWSE — 浏览/粗读（含沉淀）

阅读摘要和引言 → 补充概要 → 打标签 → 设置 `status: browsed`。

浏览的同时沉淀知识：
- 新概念 → `library/concepts/` 新建或追加
- 新研究者 → `library/authors/` 新建或追加
- 数据集/基准 → `library/datasets/` 或 `library/benchmarks/`
- 同类方法 → `library/comparisons/` 写对比表格
- 子方向积 3+ 篇 → `library/syntheses/` 写综合概述
- 项目关联 → `library/projects/` 更新进度

> **AI 可辅助：** 提取概念、研究者、数据集、基准；生成方法对比表格；撰写综合概述初稿。

### 3. CLOSE-READ — 精读

逐行精读 → 在 `annotations/entries/` 对应子方向创建精读文件夹 → 更新 library 条目 `annotation:` 路径和 `status: close-read`。

> **AI 可辅助：** 按模板生成精读笔记，论文中的图、表、公式在正文对应位置穿插解释。（参见 `annotations/_template/reading-note.md`）

### 4. REVIEW — 文献综述

汇总子方向所有论文 → 查阅 concepts/ syntheses/ comparisons/ → 在 `reviews/` 下撰写正式综述。

---

## Wiki 链接拓扑

```
library/entries/paper.md ──→ annotations/entries/paper/index.md
         │                          │
         ├──→ library/concepts/     │
         ├──→ library/authors/      │
         ├──→ library/datasets/     │
         ├──→ library/benchmarks/   │
         └──→ library/comparisons/  │
                                    │
                └───────────────────┘
                ▼
         reviews/review.md ──→ library/syntheses/
```

- **论文条目 → 概念/作者/数据/基准/对比**：一篇论文关联多个知识节点
- **概念 ↔ 作者**：谁提出了这个概念？双向链接
- **精读笔记 → 论文条目**：精读是条目的深化，通过 `annotation:` 字段关联
- **综述 → 综合**：综述引用 syntheses/，syntheses/ 引用 entries/

---

## 与 llm-wiki 对比

| 维度       | llm-wiki (Karpathy)       | ReadR                                      |
| -------- | ------------------------- | ------------------------------------------ |
| **目标用户** | AI Agent（人审核）             | 人类研究者（AI 辅助）                             |
| **知识单元** | 文章、视频、笔记、文档               | 学术论文                                     |
| **层架构**  | raw/ → wiki/ → schema     | sources/ → library/ + annotations/ → reviews/ |
| **不可变层** | raw/（全文/视频/笔记）            | sources/（PDF/剪藏）                         |
| **知识层**  | wiki/（AI 维护的概念/实体/综合）     | library/（人整理的条目/概念/实体）                   |
| **精读层**  | 无（wiki/sources 包含摘要）      | annotations/（独立精读笔记）                     |
| **产出层**  | 无（wiki 本身就是产出）            | reviews/（可发表的综述）                         |
| **主要作者** | AI Agent                  | 人类                                       |
| **状态管理** | active / stale / archived | to-read / browsed / close-read                |
| **元数据**  | 通用 frontmatter            | 学术专用（作者/venue/DOI/rating）                     |
| **合成机制** | AI 自动更新 overviews         | 人手写 syntheses/ → reviews/                     |
| **最终目标** | 知识积累（wiki 即终点）            | 知识积累 → 综述产出                                   |

### 核心设计差异

llm-wiki 把 LLM 定位为"知识编译器"——你投喂原料，AI 自动维护 wiki。它的创新在于将 LLM 从"每次重新检索"变成了"增量编译"，知识随时间复利增长。

ReadR 把**人**放在中心。AI 是助手，不是主人。差异体现在：

1. **精读层** — llm-wiki 没有对应物。机器可以总结，但论文的公式推导、实验分析、消融研究需要人逐行读、逐行写
2. **综述层** — llm-wiki 的 wiki 本身就是终点。科研的终点是可发表的 survey，需要人整合几十篇论文形成观点
3. **实体拆分** — llm-wiki 用 entities/ 统一装人物/组织/产品。科研场景下 researchers / datasets / benchmarks 是三类独立实体，各自有不同的查询维度

### 借鉴的设计

- **层分离** — sources/（不可变）与 library/（你的理解）严格分开
- **增量编译** — 每篇论文仅浏览一次，概念/实体/对比持续累积
- **wiki-link 拓扑** — concepts/ ↔ authors/ ↔ comparisons/ 双向链接
- **CLAUDE.md 契约** — 编码所有规则让 AI 行为一致
- **约定大于配置** — YAML schema、标签体系、命名规范

---

## 快速开始

### 前置要求

- [Obsidian](https://obsidian.md/) 或任何 Markdown 编辑器
- （可选）[Claude Code](https://claude.ai/code) 用于 AI 辅助

```bash
# 1. 克隆或复制模板
git clone https://github.com/elonwoo-02/ReadR.git
cd ReadR

# 2. 用 Obsidian 打开
# 打开 Obsidian → "Open folder as vault" → 选择 ReadR/

# 3. 设置你的第一个研究方向
mkdir -p library/entries/your-direction/your-sub-topic
mkdir -p annotations/entries/your-direction
```

### 开始使用

```bash
# 1. 下载一篇论文 PDF，放入 sources/papers/
# 2. 在 library/entries/your-direction/ 创建论文条目
#    cp library/_template/library-entry.md library/entries/your-direction/paper.md
# 3. 编辑 YAML frontmatter + 写概要
# 4. 浏览时同步提炼概念/作者/数据集到对应目录
# 5. 精读后在 annotations/entries/your-direction/ 创建精读笔记
```

### 维护

```bash
# 校验 vault 完整性
pwsh scripts/ReadR.ps1 -Validate

# 自动生成 library 索引
pwsh scripts/ReadR.ps1 -UpdateIndex
```

### AI 辅助（可选）

配合 Claude Code（或其它 AI 工具）使用，可在以下环节加速：

| 环节 | AI 可协助的内容 |
|------|---------------|
| **BROWSE** — 知识沉淀 | 提取概念、研究者、数据集、基准；生成方法对比表格；撰写综合概述初稿 |
| **CLOSE-READ** — 精读笔记 | 按模板生成精读笔记，图/表/公式在正文对应位置穿插解释（参见 `annotations/_template/reading-note.md`） |

CLAUDE.md 中已配置完整的项目结构和规则，AI 会自动遵循。

### Obsidian 插件

四个插件均已打包在仓库中，位于 `.obsidian/plugins/`。克隆后直接在 Obsidian 中打开 vault，到 **设置 → 第三方插件** 启用即可。

| 插件 | 类型 | 开箱即用？ |
|------|------|-----------|
| 📊 **ReadR Dashboard** | 内置（源码） | 需构建：`npm install && npm run build` |
| 📋 **Dataview** | 社区（已编译） | ✅ 是 — `main.js` 已包含 |
| 🤖 **RealClaudian** | 社区（已编译） | ✅ 是 — `main.js` 已包含 |
| 💻 **OTerm** | 社区（已编译） | ✅ 是 — `main.js` + 原生二进制已包含 |

#### ReadR Dashboard

交互式仪表盘，支持实时统计、论文筛选和活动追踪。

| 功能 | 说明 |
|------|------|
| 📊 **统计图表** | 概览卡片、阅读状态分布柱状图、研究方向进度条、自动检测知识缺口 |
| 🔍 **论文筛选** | 按状态（待读/已浏览/精读）、研究方向筛选，或按标题/作者模糊搜索 |
| ⚡ **快捷操作** | 侧边栏图标一键开关、命令面板（打开仪表盘/新建条目）、可配置自动刷新 |
| 📝 **活动追踪** | 最近 7 天变更记录、基于知识缺口的待办提醒 |

```bash
# 构建并启用
cd .obsidian/plugins/readr-dashboard/
npm install && npm run build
# 然后在设置 → 第三方插件中启用
```

#### Dataview

查询和展示 vault 元数据，仪表盘依赖它做数据聚合。([GitHub](https://github.com/blacksmithgu/obsidian-dataview))

#### RealClaudian

Obsidian 内集成 Claude AI，辅助浏览笔记和知识提炼。([GitHub](https://github.com/oterm/realclaudian))

#### OTerm

编辑器内嵌终端，运行脚本、git 命令和构建，无需离开 Obsidian。([GitHub](https://github.com/oterm/oterm))

### 专栏系列

`docs/column/` 目录包含完整的中文专栏系列，深入讲解四层架构方法论：

| 篇目 | 标题 | 主题 |
|------|------|------|
| 00 | [为什么你的文献库读完就是坟场](docs/column/00-开篇词-为什么你的文献库读完就是坟场.md) | 文献管理的痛点分析 |
| 01 | [四层架构：给论文管理设计一套读写权限](docs/column/01-四层架构-给论文管理设计一套读写权限.md) | 四层权限设计 |
| 02 | [元数据设计：YAML与wiki-link拓扑](docs/column/02-元数据设计-YAML与wiki-link拓扑.md) | 元数据与链接拓扑 |
| 03 | [人机分工：AI能做什么不能做什么](docs/column/03-人机分工-AI能做什么不能做什么.md) | 人机分工边界 |
| 04 | [知识沉淀的最小动作：从浏览到精读](docs/column/04-知识沉淀的最小动作-从浏览到精读.md) | 最小知识沉淀动作 |
| 05 | [工具化：封装成可复用的AgentSkill](docs/column/05-工具化-封装成可复用的AgentSkill.md) | 工具化与 Agent Skill 封装 |

---

## 致谢

- [**Karpathy's LLM Wiki**](https://gist.github.com/karpathy/442a6bf555914893e9891c11519de94f) — 层分离与增量编译的设计灵感来源
- [**llm-wiki**](https://github.com/nashsu/llm_wiki.git) — AI 辅助知识库管理的实践参考

---

## 许可协议

MIT © 2026 Elon Woo — 详见 [LICENSE](LICENSE)
