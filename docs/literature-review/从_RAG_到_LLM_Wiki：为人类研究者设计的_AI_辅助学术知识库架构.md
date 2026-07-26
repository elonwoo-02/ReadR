# 从 RAG 到 LLM Wiki：为人类研究者设计的 AI 辅助学术知识库架构

## 摘要

随着人工智能领域论文数量的指数级增长，传统基于检索增强生成（RAG）的文献查询模式已难以满足研究者对知识深度整合与交叉关联的需求。本文系统梳理了以"LLM
Wiki"范式为代表的 AI
辅助学术知识库架构，构建了"知识获取—知识组织—知识深化—知识输出"四维分析框架，对比了
RAG 按需检索与 LLM Wiki 持久化编译两种范式的本质差异。文章以 Karpathy
的三层通用架构为起点，分析了 ReadR 四层学术专用架构的演进逻辑，以及
nashsu/llm_wiki
桌面应用的工程化实现，并从人机协作角色分工、增量维护策略和 Wiki
链接拓扑三个维度展开对比分析。研究表明，LLM Wiki
范式通过将知识合成从查询时前移到摄入时，实现了知识的持久化积累与显式交叉引用，但其在
AI 生成内容可信度保障、大规模扩展和学术规范性集成方面仍面临挑战。

**关键词:** LLM
Wiki；检索增强生成；知识库架构；人机协作；增量知识积累；学术知识管理

## 引言

在人工智能研究领域，论文数量的指数级增长已成为研究者面临的核心挑战之一。仅以
arXiv 预印本平台为例，2023 年每周新增论文超过 3,000
篇，研究者需要在海量文献中筛选、理解、关联和综合信息<sup>\[1\]</sup>。传统的文献管理工具（如
Zotero、Mendeley）虽然解决了文献存储和格式化管理问题，但在知识整合与交叉关联方面能力有限<sup>\[2\]</sup>。近年来，AI
辅助文献综述工具迅速发展，但大多数系统仍停留在单次查询-响应的检索模式上，未能实现知识的持久化积累<sup>\[3\]</sup>。

2026 年，Karpathy
提出了一个根本性的范式转变：不再在每次查询时从原始文档中检索和重新推导知识，而是由大型语言模型（LLM）在摄入阶段将知识预先编译为持久化、结构化、互联的
Wiki 页面<sup>\[4\]</sup>。这一"LLM
Wiki"理念迅速催生了多个开源实现：nashsu/llm_wiki
将其工程化为跨平台桌面应用<sup>\[5\]</sup>，而 elonwoo-02/ReadR
则将其适配到学术研究场景，构建了面向人类研究者的四层知识库架构<sup>\[6\]</sup>。

本文构建了一个"知识获取—知识组织—知识深化—知识输出"四维分析框架，以 RAG
按需检索为对比基线，系统梳理 LLM Wiki
范式下三个代表性系统在架构层级、人机分工与增量维护策略上的设计选择与适用边界。文章首先从架构层面分析
RAG 与 LLM Wiki 的本质差异，随后深入对比 Karpathy 三层架构与 ReadR
四层架构的演进逻辑，继而探讨人机协作中 AI
代理与人类研究者的角色分工，最后分析增量维护策略与 Wiki
链接拓扑的设计，并在结论部分展望未来的研究方向。

## RAG 与 LLM Wiki 的架构分野

传统 RAG
系统采用"查询时检索-合成"的工作模式：用户提出问题后，系统从向量数据库中检索相关文档片段，由
LLM
实时合成答案<sup>\[7\]</sup>。这种模式虽然可扩展性强，但存在一个根本局限——每次查询都是独立的计算过程，知识无法在查询之间积累，跨文档的交叉引用依赖于嵌入相似度而非显式链接<sup>\[8\]</sup>。

LLM Wiki 范式逆转了这一流程：知识在摄入阶段被 LLM
代理编译为结构化、互联的 Markdown 页面，形成持久化的 Wiki
知识图谱<sup>\[4\]</sup>。查询时不再需要检索和重新推理，而是直接读取已经编译好的知识页面。这一转变的核心在于将知识合成从"查询时"前移到"摄入时"，使得知识库成为不断增值的复合型资产。

<figure>
<img src="https://cdn1.deepmd.net/static/img/e08ec94cgenerated-call_fed1d5423ff04e92bacdb409.png" style="width:85.0%" />
<figcaption>图 1. RAG 与 LLM Wiki 的架构流程对比</figcaption>
</figure>

如图
1所示，两种范式在合成时机、知识状态和交叉引用方式上存在根本差异。RAG
的"无状态"特性使其在应对大规模文档集合时具有扩展性优势，但每次查询都需重新计算，且无法利用历史查询中积累的上下文。Graph
RAG
等改进方案通过引入图结构来增强检索精度，但仍未解决知识持久化的问题<sup>\[7\]</sup>。相比之下，LLM
Wiki 的"编译式"方法将知识固化到 Wiki
页面中，新信息可以精准融入现有结构，形成增量积累而非全量重写。

LLM Wiki 范式也存在自身的规模边界。当文档数量达到数千级别时，AI 代理维护
Wiki
一致性的成本显著上升，因为每次新文档的摄入都需要检查对现有页面的影响范围<sup>\[9\]</sup>。此外，LLM
在编译过程中可能引入事实性错误，这些错误一旦固化到 Wiki 页面中，将比 RAG
单次查询中的错误更难发现和纠正。因此，两种范式并非互斥，而是在规模扩展性与合成深度上构成互补关系。

### RAG 范式的工作机制与局限

RAG
的标准流程包括四个阶段：文档分块，将原始文档分割为固定大小的文本片段；向量嵌入，使用嵌入模型将每个片段映射到高维向量空间；相似度检索，根据用户查询的嵌入向量检索最相似的片段；上下文增强生成，将检索到的片段作为上下文注入
LLM
的提示中，生成最终答案<sup>\[10\]</sup>。这一流程的优势在于高度模块化，每个阶段可以独立优化，且向量数据库支持高效的近似最近邻搜索。

RAG
的"无状态、无积累"架构本质使其难以支持研究者所需的深度交叉引用和渐进式知识构建。嵌入相似度能够捕捉语义相关性，但无法捕捉逻辑关系：两篇论文可能讨论同一概念但使用完全不同的术语，或者讨论不同概念但使用相似的术语，嵌入相似度在这些情况下容易产生误判<sup>\[11\]</sup>。矛盾信息可能在不同查询中随机出现，因为
RAG 没有机制来追踪和调和已检索到的信息之间的冲突。

### LLM Wiki 的编译式知识管理

LLM Wiki
的核心思想是将知识合成从查询时前移到摄入时。当新文档被摄入时，LLM
代理不是简单地存储文档片段，而是理解、总结、并与已有知识进行交叉引用，将结果写入
Wiki
页面<sup>\[4\]</sup>。这一过程类似于研究者阅读论文后做笔记的过程，但由
AI 代理自动化执行。

编译式方法的优势在于知识成为持久化的、可浏览的、可增量更新的资产。交叉引用在编译时已完成，Wiki
页面之间的链接是 LLM
代理在理解内容后显式创建的，而非依赖嵌入相似度的隐式关联。矛盾信息在编译时被标记和记录，而非在每次查询时随机暴露。更为重要的是，当新论文被摄入时，AI
代理只需更新受影响的页面，而非重新处理整个文档集合，这使得知识库能够持续增长而无需全量重写。

## 三层与四层：知识库架构的层级设计

从 Karpathy 的 LLM Wiki 三层通用架构到 ReadR
的四层学术专用架构，代表了从通用知识管理到学术研究专用的架构演进，体现了从
AI 代理主导到人类研究者主导的知识管理范式转移。

### Karpathy 三层架构：raw → wiki → schema

Karpathy 的原始方案将系统分为三个层级：raw/
层作为不可变的原始资料库，保存所有摄入的源文档；wiki/ 层作为 AI
代理维护的 Markdown 知识图谱，是系统的核心知识层；schema/
层（CLAUDE.md）作为规定 AI 代理行为的规则契约，定义了 Wiki
页面的格式、链接规范和更新策略<sup>\[4\]</sup>。系统的核心操作包括三种：摄取（Ingest），将新文档编译为
Wiki 页面；查询（Query），直接浏览 Wiki
页面而非重新检索；检查（Lint），定期扫描 Wiki
以检测矛盾、过期信息和孤儿页面。

这一架构的核心优势在于知识管理的高度自动化。AI
代理承担了大部分知识整理工作，研究者只需提供原始资料并浏览最终的 Wiki
页面。然而，该架构缺乏对研究者深度阅读和学术输出的专门支持：Wiki
页面的内容由 AI 代理主导撰写，研究者对知识深度和质量的控制有限。

### ReadR 四层架构：学术研究者的知识流水线

ReadR 在 Karpathy 三层架构的基础上引入了两个独立层级，形成了 sources/ →
library/ → annotations/ → reviews/ 的四层架构<sup>\[6\]</sup>。sources/
层与 Karpathy 的 raw/ 层类似，保存不可变的原始资料。关键创新在于
library/ 层由人类研究者策展而非 AI
代理维护：研究者手动创建论文条目，填写元数据（作者、会议/期刊、DOI、评分），并建立知识节点之间的链接。annotations/
层仅对经过深度阅读（close-read）的论文开放，研究者在此记录精读笔记和关键见解。reviews/
层则是综述输出层，将 annotations/ 中的深度理解整合为结构化的学术综述。

<figure>
<img src="https://cdn1.deepmd.net/static/img/46e1f7b2generated-call_9be4cd4d3f9444f19d8f5efe.png" style="width:85.0%" />
<figcaption>图 2. Karpathy 三层架构与 ReadR
四层架构的层级对比</figcaption>
</figure>

如图
2所示，从三层到四层的核心演进在于三个方面。第一，引入了独立的人类精读层（annotations/），使得深度理解与
AI
辅助的初步整理明确分离。第二，引入了综述输出层（reviews/），将知识管理的终点从"拥有一个
Wiki"延伸到"产出学术成果"。第三，library/ 层的策展权从 AI
代理转移到人类研究者，体现了对学术判断力的尊重。ReadR
还引入了阅读状态模型（to-read → browsed → close-read），为 AI
辅助提供了明确的介入边界：AI
在浏览阶段辅助提取概念和研究趋势，在精读阶段辅助生成结构化笔记，但关键决策始终由人类完成。

llm_wiki（nashsu）桌面应用通过工程化实现将 Karpathy
的三层架构产品化，提供了跨平台 GUI
界面和自动化的文档摄入-编译工作流<sup>\[5\]</sup>。其工程实践表明，三层架构在较小规模（数十到数百篇文档）下能够高效运行，但当文档规模增长到数千篇时，AI
代理维护一致性的成本和 LLM 上下文窗口的限制成为瓶颈。

表 1. 三个代表性系统的架构特征对比

| 特征维度   |      Karpathy 三层      | llm_wiki 桌面应用  |          ReadR 四层          |     |
|:-----------|:-----------------------:|:------------------:|:----------------------------:|:---:|
| 架构层级   | 3 层（raw/wiki/schema） | 3 层（工程化实现） | 4 层（+annotations/reviews） |     |
| 知识作者   |       AI 代理主导       |    AI 代理主导     |        人类研究者主导        |     |
| 元数据支持 |     基础文件元数据      |   基础文件元数据   | 学术元数据（DOI/作者/评分）  |     |
| 阅读模型   |           无            |         无         |  to-read/browsed/close-read  |     |
| 输出目标   |      可浏览的 Wiki      |   可浏览的 Wiki    |          结构化综述          |     |
| 用户界面   |        文件系统         |     跨平台 GUI     |        Obsidian 插件         |     |


表 1汇总了三个系统在架构设计上的关键差异。Karpathy 的三层架构和 llm_wiki
桌面应用将 AI 代理定位为知识的主要作者，追求的是知识管理的自动化；ReadR
则将 AI
定位为研究助手，追求的是知识管理的深度和学术质量。两种设计哲学各有适用场景：前者更适合大规模文档的快速覆盖，后者更适合需要深度理解和批判性思考的学术研究。

## 人机协作：研究者与 AI 代理的角色分工

LLM Wiki 生态系统中，人类研究者与 AI
代理的角色分工是一个核心设计决策，直接影响知识库的质量、可信度和长期可维护性。当前存在两种互补模式：AI
代理主导的知识编译（Karpathy 模式）与人类主导、AI 辅助的知识策展（ReadR
模式）。

### AI 代理作为知识作者：Karpathy 模式

在 Karpathy 模式中，AI
代理承担了知识摄取、总结、交叉引用、页面更新和一致性维护的主要职责<sup>\[4\]</sup>。人类研究者的角色被简化为三个任务：策源（提供原始资料）、探索（浏览
Wiki 页面并提出问题）、以及审核（定期检查 AI
生成的内容）。这一模式的优势在于维护成本趋近于零：AI
代理可以全天候自动处理新文档，无需人类持续投入时间。

AI 代理主导的知识编译也面临显著风险。AI
生成的内容可能包含事实性错误，这些错误一旦固化到 Wiki
页面中，将比单次查询中的错误更具隐蔽性和持久性<sup>\[9\]</sup>。此外，AI
代理在总结和简化过程中可能丢失关键的细节和微妙之处，导致 Wiki
页面的知识深度停留在摘要层面。Karpathy 在 Gist
中强调"人类应保持参与"，但具体参与程度和检查频率没有形式化规范，这使得质量保障依赖于研究者的个人习惯和经验<sup>\[4\]</sup>。

<figure>
<img src="https://cdn1.deepmd.net/static/img/97e912b4generated-call_b5fe6b18b6644d5b848c5cfc.png" style="width:85.0%" />
<figcaption>图 3. AI 代理主导与人类主导的两种人机协作模式</figcaption>
</figure>

图 3直观展示了两种协作模式在信息流和决策权上的差异。Karpathy 模式中，AI
代理位于信息处理的核心，人类处于外围监控位置；而 ReadR
模式中，人类研究者位于知识生产的核心，AI
在外围提供辅助。这一差异不仅影响知识质量，也影响研究者对知识库的"所有权感"：当研究者亲自策展和撰写时，他们更可能持续使用和维护知识库<sup>\[12\]</sup>。

### 人类策展、AI 辅助：ReadR 的协作模式

ReadR 通过阅读状态模型和知识沉积机制，为 AI
辅助设定了明确的介入边界<sup>\[6\]</sup>。在浏览阶段（browsed），AI
辅助提取论文中涉及的核心概念、研究者、数据集和基准测试，帮助研究者快速建立论文的知识图谱。在精读阶段（close-read），AI
辅助生成结构化笔记，但笔记的最终内容由研究者撰写和确认。在综述阶段（reviews），AI
可以提供模板和结构建议，但综述的论点、分析和结论完全由研究者主导。

这一模式的核心优势在于，AI
在信息提取和结构生成上发挥作用，但知识判断、深度理解和学术输出始终由人类掌控<sup>\[13\]</sup>。阅读状态模型为
AI 辅助提供了明确的介入粒度：浏览阶段可以大规模使用 AI
辅助，精读阶段则要求人类深度参与。这种"分阶段授权"的设计既利用了 AI
的效率优势，又保留了人类研究者的学术判断力。

表 2. 两种人机协作模式的对比分析

| 对比维度     | Karpathy 模式（AI 主导） | ReadR 模式（人类主导） |     |
|:-------------|:------------------------:|:----------------------:|:---:|
| 知识创作归属 |         AI 代理          |       人类研究者       |     |
| AI 介入时机  |   全流程（摄入→维护）    | 辅助阶段（浏览/笔记）  |     |
| 质量控制方式 |       事后人工审核       |     过程中人类决策     |     |
| 维护成本     |     极低（AI 自动）      |    中等（人类策展）    |     |
| 知识深度     |         摘要层面         |        精读层面        |     |
| 适用场景     |      大规模文档覆盖      |      深度学术研究      |     |
| 信任边界     |      AI 输出需验证       |   人类判断为最终依据   |     |


表
2总结了两种模式在多维度上的差异。这两种模式并非互斥，而是可以在同一系统中灵活切换。例如，对于研究者已经熟悉的领域，可以采用
AI
主导模式快速覆盖新文献；对于需要深入理解的新领域，则切换到人类主导模式进行精读和策展<sup>\[14\]</sup>。这种灵活性是
LLM Wiki 生态系统未来发展的重要方向。

## 增量维护与 Wiki 链接拓扑

LLM Wiki
的持久价值在于增量维护：新论文的发现不应触发全量重写，而应通过精准的增量更新融入现有知识结构。同时，Wiki
链接拓扑的设计决定了研究者导航和发现知识关联的效率。

### 增量更新策略与知识沉积

精准的增量更新需要 AI
代理在更新前先识别受影响的页面范围，并由人类研究者确认更新范围后再执行<sup>\[4\]</sup>。这一"先审后改"的流程是当前三个系统共同认可的最佳实践。Karpathy
的原始方案中，Lint 操作定期扫描 Wiki
以检测矛盾、过期信息和孤儿页面，但矛盾的检测和解决仍依赖人类判断<sup>\[4\]</sup>。ReadR
则通过知识沉积机制——在浏览阶段边浏览边提取概念、研究者、数据集——将增量更新融入日常研究流程，而非作为独立的维护操作<sup>\[6\]</sup>。

增量更新中的"爆炸半径"控制是一个关键工程挑战。一篇新论文可能涉及多个概念、多名研究者、多个数据集，理论上需要更新数十个
Wiki 页面。在实际工程中，llm_wiki 桌面应用通过限制 AI
代理单次更新的页面数量来控制爆炸半径<sup>\[5\]</sup>，而 ReadR
则通过人类策展的 library/
层来预先筛选更新的范围<sup>\[6\]</sup>。这两种策略各有优劣：工程限制确保系统稳定性，但可能遗漏重要关联；人类策展确保更新质量，但增加了维护成本。

### 链接拓扑与知识图谱可视化

Wiki 链接拓扑从 Karpathy 最初的索引加日志双文件导航，演进到 ReadR
的多实体类型多向链接网络<sup>\[6\]</sup>。在 ReadR
中，一篇论文条目不仅链接到其所属的概念节点，还链接到相关研究者、数据集、基准测试和综述页面，形成论文→概念→研究者→数据集→基准→综述的多向链接拓扑。这种设计使得研究者可以从任意节点出发，沿多条路径探索知识网络，发现隐含的跨领域关联。

与 RAG 基于嵌入相似度的隐式关联相比，显式 Wiki
链接具有更高的可解释性和可审计性<sup>\[15\]</sup>。研究者可以清楚地看到为什么两篇论文被关联：它们共享了同一个概念标签，而非仅仅因为嵌入向量在高维空间中接近。这种透明性在学术研究中尤为重要，因为它允许研究者追溯关联的来源、质疑不合理的链接，并手动调整知识图谱的结构<sup>\[16\]</sup>。

当前系统在自动化矛盾检测和过期信息标记方面仍处于早期阶段。Karpathy 的
Lint
操作提供了基本的矛盾检测框架，但检测规则需要人工编写和维护<sup>\[4\]</sup>。知识图谱的版本管理和演化追踪也尚未成熟：当知识库经过数月甚至数年的积累后，如何追溯某个结论的演变过程是一个尚未解决的问题<sup>\[17\]</sup>。

## 结论与展望

本文通过"知识获取—知识组织—知识深化—知识输出"四维分析框架，系统梳理了
LLM Wiki 范式下 AI 辅助学术知识库的架构设计。研究表明，LLM Wiki
通过将知识合成从查询时前移到摄入时，实现了知识的持久化编译与增量积累，形成了从"搜索引擎"到"知识编译器"的范式转变。从
Karpathy 的三层通用架构到 ReadR
的四层学术专用架构，核心演进在于引入独立的人类精读层和综述输出层，体现了从
AI 代理主导到人类研究者主导的知识管理范式转移。在人机协作方面，AI
代理主导的知识编译（Karpathy 模式）与人类主导、AI 辅助的知识策展（ReadR
模式）构成了互补的设计选择，二者的适用性取决于领域特性、研究者对质量控制的需求以及对
AI 生成内容的信任边界。

当前 LLM Wiki 生态仍面临若干挑战。AI 生成内容的可信度保障是首要问题：LLM
在编译过程中可能引入事实性错误，这些错误一旦固化到 Wiki
页面中将比单次查询中的错误更难发现和纠正。大规模 Wiki
的上下文窗口限制是另一个瓶颈：当 Wiki 页面数量达到数千级别时，AI
代理在维护一致性和更新页面时面临显著的上下文管理挑战。此外，自动化矛盾检测仍高度依赖人工编写的规则，学术写作规范性（引用格式、文献管理）的集成也尚未成熟。

未来的研究方向包括四个方面。第一，与学术文献管理工具（Zotero、BibTeX）的深度集成，使
LLM Wiki 能够直接引用和管理学术文献的元数据。第二，基于 LLM
的自动矛盾检测与证据强度评估，减少对人工编写规则的依赖。第三，面向多研究者协作的
Wiki 共享与版本控制机制，支持团队协作的学术知识管理。第四，探索将 LLM
Wiki 的编译式理念与 RAG
的按需检索能力深度融合的混合架构，以兼具两种范式的优势。随着 LLM
能力的持续提升和知识管理工具的不断成熟，AI
辅助学术知识库有望成为研究者不可或缺的"第二大脑"，从根本上改变学术知识的生产、组织和传播方式。

## 参考文献

<span class="csl-left-margin">\[1\]
</span><span class="csl-right-inline">KUDIABOR H. How AI-powered science
search engines can speed up your research\[J/OL\]. Nature, 2024.
<https://www.nature.com/articles/d41586-024-02942-0>.
DOI:[10.1038/d41586-024-02942-0](https://doi.org/10.1038/d41586-024-02942-0).</span>

<span class="csl-left-margin">\[2\]
</span><span class="csl-right-inline">MATTHEWS D. Drowning in the
literature? These smart software tools can help\[J/OL\]. Nature, 2021.
<https://www.nature.com/articles/d41586-021-02346-4>.
DOI:[10.1038/d41586-021-02346-4](https://doi.org/10.1038/d41586-021-02346-4).</span>

<span class="csl-left-margin">\[3\]
</span><span class="csl-right-inline">BOLAÑOS F, SALATINO A, OSBORNE F, et al. Artificial intelligence for literature reviews: opportunities and
challenges\[J/OL\]. Artificial Intelligence Review, 2024.
<https://link.springer.com/article/10.1007/s10462-024-10902-3>.
DOI:[10.1007/s10462-024-10902-3](https://doi.org/10.1007/s10462-024-10902-3).</span>

<span class="csl-left-margin">\[4\]
</span><span class="csl-right-inline">KARPATHY A. LLM Wiki: A pattern
for building personal knowledge bases using LLMs\[J/OL\]. GitHub Gist,
2026.
<https://gist.github.com/karpathy/442a6bf555914893e9891c11519de94f>.</span>

<span class="csl-left-margin">\[5\]
</span><span class="csl-right-inline">SU N. llm_wiki: Cross-platform
desktop application for document-to-knowledge-base conversion\[J/OL\].
GitHub, 2026. <https://github.com/nashsu/llm_wiki>.</span>

<span class="csl-left-margin">\[6\]
</span><span class="csl-right-inline">WOO E. ReadR: An AI-assisted
academic knowledge base for human researchers\[J/OL\]. GitHub, 2026.
<https://github.com/elonwoo-02/ReadR>.</span>

<span class="csl-left-margin">\[7\]
</span><span class="csl-right-inline">PENG B, ZHU Y, LIU Y, et al. Graph
Retrieval-Augmented Generation: A Survey\[J/OL\]. ACM Transactions on
Information Systems, 2025. <https://dl.acm.org/doi/10.1145/3777378>.
DOI:[10.1145/3777378](https://doi.org/10.1145/3777378).</span>

<span class="csl-left-margin">\[8\]
</span><span class="csl-right-inline">LONGPRE S, MAHARI R, CHEN A, et al. A
large-scale audit of dataset licensing and attribution in AI\[J/OL\].
Nature Machine Intelligence, 2024.
<https://www.nature.com/articles/s42256-024-00878-8>.
DOI:[10.1038/s42256-024-00878-8](https://doi.org/10.1038/s42256-024-00878-8).</span>

<span class="csl-left-margin">\[9\]
</span><span class="csl-right-inline">AUGENSTEIN I, BALDWIN T, CHA M, et al. Factuality challenges in the era of large language models and
opportunities for fact-checking\[J/OL\]. Nature Machine Intelligence,
2024. <https://www.nature.com/articles/s42256-024-00881-z>.
DOI:[10.1038/s42256-024-00881-z](https://doi.org/10.1038/s42256-024-00881-z).</span>

<span class="csl-left-margin">\[10\]
</span><span class="csl-right-inline">AL-QATF M, HAQUE R, ALSAMHI S H, et al. RAG4DS: Retrieval-Augmented Generation for Data Spaces—A Unified
Lifecycle, Challenges, and Opportunities\[J/OL\]. IEEE Access, 2025.
<https://ieeexplore.ieee.org/document/10902131>.
DOI:[10.1109/access.2025.3545387](https://doi.org/10.1109/access.2025.3545387).</span>

<span class="csl-left-margin">\[11\]
</span><span class="csl-right-inline">VIDYARTHI A, SINGH M K,
MOIRANGTHEM D S. SageRAG: Query Rewriting for Retrieval Enhancement and
Retrieval-Augmented Generation for Grounded Responses in AI Research
Assistance\[J/OL\]. Expert Systems with Applications, 2026.
<https://www.sciencedirect.com/science/article/abs/pii/S0957417426000746>.
DOI:[10.1016/j.eswa.2026.131160](https://doi.org/10.1016/j.eswa.2026.131160).</span>

<span class="csl-left-margin">\[12\]
</span><span class="csl-right-inline">WENSKOVITCH J, NORTH C.
Interactive Artificial Intelligence: Designing for the "Two Black Boxes"
Problem\[J/OL\]. Computer, 2020.
<https://ieeexplore.ieee.org/document/9153297/>.
DOI:[10.1109/mc.2020.2996416](https://doi.org/10.1109/mc.2020.2996416).</span>

<span class="csl-left-margin">\[13\]
</span><span class="csl-right-inline">GRUDA D. Three ways ChatGPT helps
me in my academic writing\[J/OL\]. Nature, 2024.
<https://www.nature.com/articles/d41586-024-01042-3>.
DOI:[10.1038/d41586-024-01042-3](https://doi.org/10.1038/d41586-024-01042-3).</span>

<span class="csl-left-margin">\[14\]
</span><span class="csl-right-inline">PERKEL J M, NOORDEN R V. tl;dr:
this AI sums up research papers in a sentence\[J/OL\]. Nature, 2020.
<https://www.nature.com/articles/d41586-020-03277-2>.
DOI:[10.1038/d41586-020-03277-2](https://doi.org/10.1038/d41586-020-03277-2).</span>

<span class="csl-left-margin">\[15\]
</span><span class="csl-right-inline">TAMAŠAUSKAITĖ G, GROTH P. Defining
a Knowledge Graph Development Process Through a Systematic
Review\[J/OL\]. ACM Transactions on Software Engineering and
Methodology, 2023. <https://dl.acm.org/doi/10.1145/3522586>.
DOI:[10.1145/3522586](https://doi.org/10.1145/3522586).</span>

<span class="csl-left-margin">\[16\]
</span><span class="csl-right-inline">MEYERS B, VANGHELUWE H, LIETAERT
P, et al. Towards a knowledge graph framework for ad hoc analysis in
manufacturing\[J/OL\]. Journal of Intelligent Manufacturing, 2024.
<https://link.springer.com/article/10.1007/s10845-023-02319-6>.
DOI:[10.1007/s10845-023-02319-6](https://doi.org/10.1007/s10845-023-02319-6).</span>

<span class="csl-left-margin">\[17\]
</span><span class="csl-right-inline">BLAGEC K, BARBOSA-SILVA A, OTT S, et al. A curated, ontology-based, large-scale knowledge graph of artificial
intelligence tasks and benchmarks\[J/OL\]. Scientific Data, 2022.
<https://www.nature.com/articles/s41597-022-01435-x>.
DOI:[10.1038/s41597-022-01435-x](https://doi.org/10.1038/s41597-022-01435-x).</span>
