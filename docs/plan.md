# ReadR Dashboard 增强计划

## Context

**问题**: 当前 ReadR Vault 有一个基于 Dataview 的 dashboard (`library/dashboard.md`)，能展示论文列表、资产、知识缺口等，但缺少：
- 交互式筛选和搜索（只能在页面内查看静态表格）
- 统计图表和进度可视化（纯文本表格）
- 快速操作入口（创建论文、修改状态需要手动操作）
- 实时活动提醒（最近修改、待办提醒）

**目标**: 采用混合方案 — 保留现有的 Dataview dashboard.md 作为基础数据视图，同时开发一个自定义 Obsidian 插件提供交互式增强功能。

**用户需求**: 个人使用，核心功能包括统计概览&图表、快速操作入口、交互式筛选&搜索、最近活动&待办提醒。

---

## Architecture

### 混合方案设计

```
┌─────────────────────────────────────────────────┐
│                  Obsidian Vault                  │
│                                                   │
│  ┌──────────────────┐   ┌──────────────────────┐ │
│  │  Dataview Dashboard│  │  Custom Plugin View   │ │
│  │  (library/dashboard│  │  (readr-dashboard)    │ │
│  │   .md)             │  │                       │ │
│  │                    │  │  Stats & Charts       │ │
│  │  Reading Queue     │  │  Interactive Filter   │ │
│  │  Research Assets   │  │  Quick Actions        │ │
│  │  Knowledge Gaps    │  │  Activity Feed        │ │
│  │  Syntheses         │  │  Todo Reminders       │ │
│  └──────────────────┘   └──────────────────────┘ │
│           ▲                        ▲              │
│           │                        │              │
│           └──────────┬─────────────┘              │
│                      │                            │
│           ┌──────────▼──────────┐                 │
│           │   Dataview API      │                 │
│           │   (data source)     │                 │
│           └─────────────────────┘                 │
│                                                   │
│  ┌──────────────────────────────────────────────┐ │
│  │  YAML Frontmatter (library/entries/*.md)      │ │
│  └──────────────────────────────────────────────┘ │
└─────────────────────────────────────────────────┘
```

**核心原则**: 插件不重复实现 YAML 解析，而是通过 Dataview 的公共 API 获取数据。这保证了与现有 dashboard 的数据一致性。

---

## Project Structure

新插件将放在 `.obsidian/plugins/readr-dashboard/` 目录下：

```
.obsidian/plugins/readr-dashboard/
├── manifest.json              # 插件元数据
├── package.json               # 依赖管理
├── tsconfig.json              # TypeScript 配置
├── esbuild.config.mjs         # 构建配置
├── version-bump.mjs           # 版本更新脚本
├── main.ts                    # 插件入口 + 视图注册
├── styles.css                 # 样式
├── versions.json              # 版本兼容性
└── src/
    ├── DashboardView.ts       # 主视图 (ItemView)
    ├── DashboardSettingTab.ts # 设置选项卡
    ├── data/
    │   └── DataService.ts     # Dataview API 封装
    ├── components/
    │   ├── StatsPanel.ts      # 统计概览（含图表）
    │   ├── FilterPanel.ts     # 交互式筛选
    │   ├── PaperList.ts       # 筛选结果列表
    │   ├── QuickActions.ts    # 快速操作按钮
    │   ├── ActivityFeed.ts    # 最近活动
    │   └── TodoReminder.ts    # 待办提醒
    └── utils/
        ├── types.ts           # 类型定义
        └── constants.ts       # 常量
```

---

## Implementation Plan (6 步)

### Step 1: 插件脚手架搭建

**文件**: `manifest.json`, `package.json`, `tsconfig.json`, `esbuild.config.mjs`, `main.ts` (骨架)

**内容**:
- `manifest.json`: id=`readr-dashboard`, name=`ReadR Dashboard`, minAppVersion=`0.15.0`
- `package.json`: 依赖 `obsidian`, `@types/node`, `tslib`; 构建用 `esbuild`
- `main.ts`: 注册 `DashboardView` (ItemView)，添加 ribbon 图标，注册命令
- `DashboardView.ts`: 继承 `ItemView`，基础骨架，`getViewType()` 返回 `readr-dashboard`

**关键 API**:
```typescript
// main.ts
class ReadRDashboardPlugin extends Plugin {
  async onload() {
    this.registerView(
      VIEW_TYPE_DASHBOARD,
      (leaf) => new DashboardView(leaf, this)
    );
    this.addRibbonIcon('bar-chart', 'ReadR Dashboard', () => {
      this.activateView();
    });
    this.addCommand({
      id: 'open-dashboard',
      name: 'Open ReadR Dashboard',
      callback: () => this.activateView(),
    });
  }
}
```

### Step 2: Dataview 数据服务层

**文件**: `src/data/DataService.ts`, `src/utils/types.ts`, `src/utils/constants.ts`

**内容**:
- `types.ts`: 定义 `PaperEntry`, `AssetEntry`, `DashboardStats`, `FilterOptions` 等接口
- `constants.ts`: 状态映射 (`TO_READ`, `BROWSED`, `CLOSE_READ`, `REVIEWED`)，标签前缀，颜色主题
- `DataService.ts`: 封装 Dataview API 调用
  - `getAllPapers()`: 获取所有论文条目
  - `getPapersByStatus(status)`: 按状态筛选
  - `getPapersByDirection(direction)`: 按研究方向筛选
  - `getStats()`: 获取聚合统计数据
  - `getKnowledgeGaps()`: 获取知识缺口列表
  - `getRecentActivity(days)`: 获取最近活动
  - `getAssets()`: 获取研究资产概览

**Dataview API 调用方式**:
```typescript
// DataService.ts
import { Component, App } from 'obsidian';

export class DataService {
  private dv: any; // Dataview plugin instance
  
  constructor(private app: App) {
    // 获取 Dataview 插件实例
    this.dv = (this.app as any).plugins?.getPlugin('dataview');
  }

  getAllPapers(): PaperEntry[] {
    // 使用 Dataview API 查询
    const pages = this.dv?.api?.pages('"library/entries"') ?? [];
    return pages.map(p => this.toPaperEntry(p));
  }
  
  getStats(): DashboardStats {
    const papers = this.getAllPapers();
    const byStatus = // 分组统计
    const byDirection = // 按 direction/ 标签分组
    return { total, byStatus, byDirection, ... };
  }
}
```

### Step 3: 统计概览 & 图表组件

**文件**: `src/components/StatsPanel.ts`, `src/DashboardView.ts` (集成 StatsPanel)

**内容**:
- 论文总数大数字显示
- 状态分布条形图（Canvas 2D 绘制，无外部依赖）
  - To Read / Browsed / Close Read / Reviewed
  - 每个状态显示数量 + 百分比 + 进度条
- 研究方向分布（标签云或饼图）
- 研究资产概览（Concepts / Authors / Datasets / Benchmarks 数量）
- 自动刷新（每 5 分钟或文件变更时）

**图表实现**: 用 Canvas 2D API 绘制简单柱状图和饼图，不引入 Chart.js 等外部库（保持插件轻量）。

### Step 4: 交互式筛选 & 快速操作

**文件**: `src/components/FilterPanel.ts`, `src/components/PaperList.ts`, `src/components/QuickActions.ts`

**内容**:
- **FilterPanel**: 
  - 状态筛选按钮组（全部 / To Read / Browsed / Close Read / Reviewed）
  - 研究方向下拉筛选（自动从标签中提取）
  - 搜索框（按标题/作者模糊搜索）
  - 评分筛选（星级过滤）
- **PaperList**: 
  - 筛选后结果列表，显示标题、作者、状态、评分
  - 点击跳转到对应笔记
  - 右键菜单（快速修改状态、打开 annotation）
- **QuickActions**:
  - "New Paper" → 弹出模态框，填写基本信息，创建新条目
  - "Quick Status" → 选择论文 + 选择状态，自动更新 YAML
  - "Open Dashboard.md" → 跳转到现有 Dataview dashboard
  - "Run Validation" → 触发 PowerShell 验证脚本
  - "Open Kanban" → 打开研究流水线看板

### Step 5: 最近活动 & 待办提醒

**文件**: `src/components/ActivityFeed.ts`, `src/components/TodoReminder.ts`

**内容**:
- **ActivityFeed**:
  - 监听 Obsidian 的 `metadata-change` 和 `file-modified` 事件
  - 显示最近 10 条活动（"2h ago: 添加了 XXX 论文", "1d ago: 更新了 YYY 概念"）
  - 活动条目可点击跳转
- **TodoReminder**:
  - 显示知识缺口（复用现有 dashboard 的逻辑）
  - 缺少 PDF 字段的论文
  - Browsed 但没有概念链接的论文
  - Close-read 但没有 annotation 路径的论文
  - 3+ 篇论文但未写 synthesis 的方向
  - 每个待办项显示数量 + 链接到列表

### Step 6: 设置、样式 & 集成

**文件**: `src/DashboardSettingTab.ts`, `styles.css`, `main.ts` (补充)

**内容**:
- **SettingTab**: 可配置项
  - 自动刷新间隔
  - 默认视图（统计/筛选/活动）
  - 待办提醒阈值（如 3 篇论文触发 synthesis 提醒）
  - 主题色配置
- **styles.css**: 
  - 响应式布局
  - 与 Obsidian 主题一致（亮色/暗色模式自动适配）
  - 平滑动画
- **集成**: 
  - 插件加载时自动注册视图
  - 工作区布局中可以保存 dashboard 位置
  - 与现有 dashboard.md 通过 ribbon 图标和命令互通

---

## 关键技术决策

| 决策 | 选择 | 理由 |
|------|------|------|
| 图表库 | Canvas 2D（无外部依赖） | 插件轻量，功能简单，不需要 Chart.js |
| 数据源 | Dataview API | 与现有 dashboard 一致，避免重复解析 |
| 视图类型 | ItemView | 支持侧边栏和主面板，可保存工作区 |
| 构建工具 | esbuild | Obsidian 插件标准工具 |
| 语言 | TypeScript | 类型安全，Obsidian SDK 支持 |
| UI 样式 | Obsidian 原生 CSS 变量 | 自动适配亮色/暗色主题 |

---

## 文件修改清单

### 新增文件（插件目录）
1. `.obsidian/plugins/readr-dashboard/manifest.json` — 插件元数据
2. `.obsidian/plugins/readr-dashboard/package.json` — 依赖配置
3. `.obsidian/plugins/readr-dashboard/tsconfig.json` — TS 编译配置
4. `.obsidian/plugins/readr-dashboard/esbuild.config.mjs` — 构建配置
5. `.obsidian/plugins/readr-dashboard/version-bump.mjs` — 版本更新
6. `.obsidian/plugins/readr-dashboard/main.ts` — 插件入口
7. `.obsidian/plugins/readr-dashboard/styles.css` — 样式
8. `.obsidian/plugins/readr-dashboard/src/DashboardView.ts` — 主视图
9. `.obsidian/plugins/readr-dashboard/src/DashboardSettingTab.ts` — 设置
10. `.obsidian/plugins/readr-dashboard/src/data/DataService.ts` — 数据服务
11. `.obsidian/plugins/readr-dashboard/src/utils/types.ts` — 类型定义
12. `.obsidian/plugins/readr-dashboard/src/utils/constants.ts` — 常量
13. `.obsidian/plugins/readr-dashboard/src/components/StatsPanel.ts` — 统计组件
14. `.obsidian/plugins/readr-dashboard/src/components/FilterPanel.ts` — 筛选组件
15. `.obsidian/plugins/readr-dashboard/src/components/PaperList.ts` — 列表组件
16. `.obsidian/plugins/readr-dashboard/src/components/QuickActions.ts` — 快速操作
17. `.obsidian/plugins/readr-dashboard/src/components/ActivityFeed.ts` — 活动组件
18. `.obsidian/plugins/readr-dashboard/src/components/TodoReminder.ts` — 待办组件

### 修改文件
19. `.obsidian/community-plugins.json` — 添加 `readr-dashboard` 到已安装插件列表

---

## Verification

1. **构建检查**: 运行 `npm run build`，确保 esbuild 编译成功，产出 `main.js` 和 `styles.css`
2. **插件加载**: 重启 Obsidian，检查 `readr-dashboard` 在社区插件列表中显示为已安装
3. **视图显示**: 点击 ribbon 图标或运行命令，dashboard 视图正确显示
4. **数据准确**: 统计数字与 `library/dashboard.md` 的 Dataview 查询结果一致
5. **筛选功能**: 按状态/方向/评分筛选后，列表正确更新
6. **快速操作**: 创建新论文、修改状态后，YAML 正确更新，Dataview dashboard 同步反映
7. **活动跟踪**: 修改文件后，活动列表出现对应条目
8. **待办提醒**: 知识缺口列表与现有 dashboard 的 gap 查询一致
9. **主题兼容**: 切换亮色/暗色模式，UI 正确适配
10. **自动化测试**: 运行 `pwsh -File scripts/ReadR.ps1 -Validate` 确认验证仍然通过