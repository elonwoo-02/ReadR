# 加餐｜从方法论到能跑起来的项目：ReadR 三次迭代都做了什么
![10.png](docs/column/images/10.png)
## 你将获得

- ReadR 目前三个版本（v0.0.1 → v0.0.3）已交付内容的全景图
- 每个版本各自解决了上一版本留下的哪个具体缺口
- 项目当前的边界：哪些已经就绪，哪些还在路上

最近一次组会，我把这套方法论向同门做了一次分享，顺手也推荐给了几个刚入学、还在摸索的研 0 朋友。前五讲一直在讲方法论本身——四层怎么分、字段怎么设计、AI 的边界在哪。这一讲换个角度，讲讲这套方法论落到 ReadR 这个具体项目上，三个版本分别交付了什么，才慢慢从一套"讲得通的道理"变成一个"能直接拿来用的东西"。

## v0.0.1：先把骨架和道理立住

[第一个版本](https://github.com/elonwoo-02/ReadR/releases/tag/0.0.1)做的事情，其实就是这个专栏前六讲一直在讲的内容本身：初始化四层目录结构，写好 `CLAUDE.md` 作为编码项目规则和 AI 辅助契约,README 里把架构图、工作流、和 llm-wiki 的对比一次性说清楚。同时发布了六篇中文专栏，把整套方法论从问题、架构、元数据、人机分工、知识沉淀到工具化完整讲了一遍：

| 篇目 | 主题 |
|---|---|
| 00 | 为什么你的文献库读完就是坟场 |
| 01 | 四层架构：给论文管理设计一套读写权限 |
| 02 | 元数据设计：YAML 与 wiki-link 拓扑 |
| 03 | 人机分工：AI 能做什么不能做什么 |
| 04 | 知识沉淀的最小动作：从浏览到精读 |
| 05 | 工具化：封装成可复用的 Agent Skill |

这个版本交付的是"道理"，还没有交付"例子"。一套架构讲得再清楚，没人真正拿一篇论文走一遍，说服力总是差一截。

## v0.0.2：拿真实论文把流程跑一遍

[第二个版本](https://github.com/elonwoo-02/ReadR/releases/tag/v0.0.2)补的正是这个缺口。新增了两篇真实论文条目——**Vision Transformer (ViT)** 和 **Attention Is All You Need**，其中 *Attention Is All You Need* 完整走完了浏览阶段：概要、概念、作者、数据集一样不少。围绕这两篇论文,同步生成了一批示例知识资产——概念节点（`Attention Mechanism`、`Transformer`、`Vision Transformer`）、作者节点（`Vaswani et al.`、`Dosovitskiy et al.`）、数据集（`WMT 2014`、`ImageNet`）、基准（`BLEU`、`ImageNet Top-1 Accuracy`）。

这不是随便挑的两篇论文——一篇是奠基性方法本身，一篇是这个方法在另一个模态上的延伸,天然构成一组值得放进 `comparisons/` 的对照样本，正好演示第二讲讲过的 wiki-link 拓扑是怎么串起来的。

这个版本还做了一件对易用性影响很大的事：把 **ReadR Dashboard**（自己写的交互式统计/筛选/活动追踪插件）连同 **Dataview**、**RealClaudian**、**OTerm** 一起打包成 Obsidian 插件包，预编译好,装上就能用,不需要自己去配置。方法论再对，如果每个想尝试的人都要自己折腾插件依赖，推广成本就会劝退大多数人。这个版本把上手成本压到了最低。

顺带手的维护性工作：加了 PowerShell 校验和索引生成脚本（`scripts/ReadR.ps1`），给生成文档和原始素材加了 `.gitignore` 规则——项目开始有了"能被别人接手"的样子,而不只是自己能看懂。

## v0.0.3：把入口打开

前两个版本解决的都是"进来之后怎么用"，[第三个版本](https://github.com/elonwoo-02/ReadR/releases/tag/v0.0.3)开始解决"内容从哪里进来"——也就是第五讲提过的 INGEST 阶段。

新增了 **RSS Dashboard** 社区插件，同样预编译打包，装进 `.obsidian/plugins/rss-dashboard/` 就能直接用。同时在 README 里补上了一份完整的中英文订阅源推荐，覆盖 IEEE Transactions 系列期刊：

| 期刊    | RSS                                              |     |
| ----- | ------------------------------------------------ | --- |
| TPAMI | `https://ieeexplore.ieee.org/rss/TOC34.XML`      |     |
| TIP   | `https://ieeexplore.ieee.org/rss/TOC83.XML`      |     |
| TKDE  | `https://ieeexplore.ieee.org/rss/TOC69.XML`      |     |
| TNNLS | `https://ieeexplore.ieee.org/rss/TOC5962385.XML` |     |
| TMM   | `https://ieeexplore.ieee.org/rss/TOC6046.XML`    |     |
| TCSVT | `https://ieeexplore.ieee.org/rss/TOC76.XML`      |     |

再加上 ArXiv 的 cs.CV、cs.IR、cs.LG、cs.AI、cs.MM 几个分类，以及 Papers With Code、Google AI Blog 这类精选源。

## 现在的边界在哪

三个版本走下来,已经就绪的部分：方法论完整（六讲）、真实案例齐全（两篇论文走完浏览阶段）、上手门槛低（插件预编译打包）、内容入口打通（RSS 订阅源）。

还在路上的部分：第五讲提到的三个方向——Agent 工作流编排、独立应用、与 Zotero 等工具的桥接——一个都还没真正动手。RSS 订阅源解决的是"发现新论文"，"发现了之后自动生成条目初稿"这一步,现在还是手工。

具体到几个明确的缺口：

- 没有 Zotero 迁移工具，历史存量论文还需要手动导入
- Dashboard 插件目前是源码版，要用的话还需要自己构建
- 还没有覆盖 CLOSE-READ 和 REVIEW 阶段的完整示例——v0.0.2 走完的只是浏览阶段，精读笔记和综述产出长什么样，目前只有模板，没有真实样本

这几个缺口不回避：入口打开了不等于自动化做完了。

这也是为什么这一讲值得作为加餐单独写出来：项目是开源的，这几个缺口谁先补上都行。有想法欢迎提 issue，顺手的话发个 PR，觉得这套方法论有用的话，给仓库点个 star。

---

**思考题**：如果你打算把这套方法论用在自己的文献库上，参照上面"已经就绪/还在路上"的划分，你会先从哪一块开始动手——是先把两篇示例论文换成自己方向的论文跑一遍，还是先去接一条 RSS 订阅源？
