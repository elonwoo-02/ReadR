import { ItemView, WorkspaceLeaf, setIcon, TFile } from "obsidian";
import type ReadRDashboardPlugin from "../main";
import { DataService } from "./data/DataService";
import type { DashboardStats, PaperEntry, FilterOptions, KnowledgeGap, ActivityItem, PaperStatus } from "./utils/types";
import { VIEW_TYPE_DASHBOARD, ALL_STATUSES, STATUS_MAP } from "./utils/constants";

export class DashboardView extends ItemView {
  private plugin: ReadRDashboardPlugin;
  dataService: DataService;
  private stats: DashboardStats | null = null;
  private papers: PaperEntry[] = [];
  private filteredPapers: PaperEntry[] = [];
  private filters: FilterOptions = { status: "all", direction: "all", search: "" };
  private gaps: KnowledgeGap[] = [];
  private activities: ActivityItem[] = [];
  private directions: string[] = [];
  private activeTab: "stats" | "papers" | "activity" = "stats";
  private refreshInterval: number | null = null;
  /** Vault event listeners for file changes */
  private vaultEventRefs: { event: string; ref: any }[] = [];
  /** Debounce timer for batched re-renders */
  private debounceTimer: number | null = null;

  constructor(leaf: WorkspaceLeaf, plugin: ReadRDashboardPlugin) {
    super(leaf);
    this.plugin = plugin;
    this.dataService = new DataService(plugin.app);
  }

  getViewType(): string {
    return VIEW_TYPE_DASHBOARD;
  }

  getDisplayText(): string {
    return "ReadR Dashboard";
  }

  getIcon(): string {
    return "bar-chart";
  }

  async onOpen(): Promise<void> {
    this.refreshData();
    this.render();
    this.startAutoRefresh();
    this.registerVaultEvents();
  }

  async onClose(): Promise<void> {
    this.stopAutoRefresh();
    this.unregisterVaultEvents();
  }

  /** Refresh all data from the data service */
  refreshData(): void {
    this.stats = this.dataService.getStats();
    this.papers = this.dataService.getAllPapers();
    this.filteredPapers = this.dataService.getFilteredPapers(this.filters);
    this.gaps = this.dataService.getKnowledgeGaps();
    this.activities = this.dataService.getRecentActivity();
    this.directions = this.dataService.getAllDirections();
  }

  /** Re-render the full view */
  render(): void {
    const container = this.containerEl.children[1] as HTMLElement;
    container.empty();
    container.addClass("readr-dashboard-container");

    // Header
    this.renderHeader(container);

    // Tab bar
    this.renderTabBar(container);

    // Content area
    const content = container.createDiv({ cls: "readr-dashboard-content" });
    this.renderContent(content);

    // Footer
    this.renderFooter(container);
  }

  // ---- Header ----

  private renderHeader(container: HTMLElement): void {
    const header = container.createDiv({ cls: "readr-dashboard-header" });
    const titleRow = header.createDiv({ cls: "readr-dashboard-title-row" });

    const title = titleRow.createEl("h2", { text: "ReadR Dashboard" });
    title.addClass("readr-dashboard-title");

    const refreshBtn = titleRow.createEl("button", { cls: "readr-dashboard-refresh-btn" });
    setIcon(refreshBtn, "refresh-cw");
    refreshBtn.setAttribute("aria-label", "Refresh");
    refreshBtn.addEventListener("click", () => {
      this.refreshData();
      this.render();
    });
  }

  // ---- Tab Bar ----

  private renderTabBar(container: HTMLElement): void {
    const tabBar = container.createDiv({ cls: "readr-dashboard-tab-bar" });

    const tabs: { key: typeof this.activeTab; icon: string; label: string }[] = [
      { key: "stats", icon: "bar-chart", label: "Stats" },
      { key: "papers", icon: "list", label: "Papers" },
      { key: "activity", icon: "activity", label: "Activity" },
    ];

    for (const tab of tabs) {
      const btn = tabBar.createEl("button", { cls: "readr-dashboard-tab" });
      if (tab.key === this.activeTab) btn.addClass("readr-dashboard-tab-active");
      setIcon(btn, tab.icon);
      btn.createSpan({ text: ` ${tab.label}` });
      btn.addEventListener("click", () => {
        this.activeTab = tab.key;
        this.render();
      });
    }
  }

  // ---- Content ----

  private renderContent(container: HTMLElement): void {
    switch (this.activeTab) {
      case "stats":
        this.renderStatsTab(container);
        break;
      case "papers":
        this.renderPapersTab(container);
        break;
      case "activity":
        this.renderActivityTab(container);
        break;
    }
  }

  // ---- Stats Tab ----

  private renderStatsTab(container: HTMLElement): void {
    if (!this.stats) {
      container.createEl("p", { text: "No data available. Add papers to library/entries/ to get started." });
      return;
    }

    // Summary cards
    const summary = container.createDiv({ cls: "readr-dashboard-summary" });

    this.createStatCard(summary, "Total Papers", String(this.stats.totalPapers), "book-open");
    this.createStatCard(summary, "Concepts", String(this.stats.assets.concepts), "lightbulb");
    this.createStatCard(summary, "Authors", String(this.stats.assets.authors), "users");
    this.createStatCard(summary, "Datasets", String(this.stats.assets.datasets), "database");

    // Status distribution chart
    this.renderStatusChart(container);

    // Direction distribution
    this.renderDirectionSection(container);

    // Knowledge gaps
    this.renderGapsSection(container);
  }

  private createStatCard(container: HTMLElement, label: string, value: string, icon: string): void {
    const card = container.createDiv({ cls: "readr-dashboard-stat-card" });
    const iconEl = card.createDiv({ cls: "readr-dashboard-stat-icon" });
    setIcon(iconEl, icon);
    card.createDiv({ cls: "readr-dashboard-stat-value", text: value });
    card.createDiv({ cls: "readr-dashboard-stat-label", text: label });
  }

  private renderStatusChart(container: HTMLElement): void {
    if (!this.stats) return;

    const section = container.createDiv({ cls: "readr-dashboard-section" });
    section.createEl("h3", { text: "Status Distribution", cls: "readr-dashboard-section-title" });

    const chartContainer = section.createDiv({ cls: "readr-dashboard-chart" });
    const canvas = chartContainer.createEl("canvas", { cls: "readr-dashboard-bar-chart" });
    canvas.width = chartContainer.clientWidth || 400;
    canvas.height = 200;

    // Draw bar chart on canvas
    requestAnimationFrame(() => {
      this.drawBarChart(canvas, this.stats!);
    });
  }

  private drawBarChart(canvas: HTMLCanvasElement, stats: DashboardStats): void {
    const ctx = canvas.getContext("2d");
    if (!ctx) return;

    const dpr = window.devicePixelRatio || 1;
    const rect = canvas.getBoundingClientRect();
    canvas.width = rect.width * dpr;
    canvas.height = rect.height * dpr;
    ctx.scale(dpr, dpr);

    const w = rect.width;
    const h = rect.height;
    const max = Math.max(1, ...Object.values(stats.byStatus));
    const barCount = ALL_STATUSES.length;
    const barWidth = Math.min(60, (w - 40) / barCount - 16);
    const gap = 16;
    const totalBarsWidth = barCount * barWidth + (barCount - 1) * gap;
    const startX = (w - totalBarsWidth) / 2;
    const chartBottom = h - 30;
    const chartTop = 10;
    const chartHeight = chartBottom - chartTop;

    for (let i = 0; i < ALL_STATUSES.length; i++) {
      const status = ALL_STATUSES[i];
      const count = stats.byStatus[status] ?? 0;
      const info = STATUS_MAP[status];
      const barH = max > 0 ? (count / max) * chartHeight : 0;
      const x = startX + i * (barWidth + gap);
      const y = chartBottom - barH;

      // Bar
      ctx.fillStyle = getComputedStyle(canvas).getPropertyValue("--interactive-accent") || "#6c8cff";
      ctx.globalAlpha = 0.6 + 0.4 * (1 - i / barCount);
      this.roundRect(ctx, x, y, barWidth, barH, 4);
      ctx.fill();
      ctx.globalAlpha = 1;

      // Label
      ctx.fillStyle = getComputedStyle(canvas).getPropertyValue("--text-muted") || "#666";
      ctx.font = "11px sans-serif";
      ctx.textAlign = "center";
      ctx.fillText(info.label, x + barWidth / 2, chartBottom + 16);

      // Value
      ctx.fillStyle = getComputedStyle(canvas).getPropertyValue("--text-normal") || "#333";
      ctx.font = "bold 13px sans-serif";
      ctx.fillText(String(count), x + barWidth / 2, y - 4);
    }
  }

  private roundRect(ctx: CanvasRenderingContext2D, x: number, y: number, w: number, h: number, r: number): void {
    ctx.beginPath();
    ctx.moveTo(x + r, y);
    ctx.lineTo(x + w - r, y);
    ctx.quadraticCurveTo(x + w, y, x + w, y + r);
    ctx.lineTo(x + w, y + h);
    ctx.lineTo(x, y + h);
    ctx.lineTo(x, y + r);
    ctx.quadraticCurveTo(x, y, x + r, y);
    ctx.closePath();
  }

  private renderDirectionSection(container: HTMLElement): void {
    if (!this.stats) return;

    const dirs = Object.entries(this.stats.byDirection).sort((a, b) => b[1] - a[1]);
    if (dirs.length === 0) return;

    const section = container.createDiv({ cls: "readr-dashboard-section" });
    section.createEl("h3", { text: "Research Directions", cls: "readr-dashboard-section-title" });

    const list = section.createDiv({ cls: "readr-dashboard-direction-list" });
    const max = Math.max(1, ...dirs.map(([, c]) => c as number));
    for (const [dir, count] of dirs) {
      const row = list.createDiv({ cls: "readr-dashboard-direction-row" });
      const label = row.createSpan({ cls: "readr-dashboard-direction-label", text: dir });
      const barOuter = row.createDiv({ cls: "readr-dashboard-direction-bar-outer" });
      const barInner = barOuter.createDiv({ cls: "readr-dashboard-direction-bar-inner" });
      barInner.style.width = `${(count / max) * 100}%`;
      barInner.style.background = "var(--interactive-accent)";
      row.createSpan({ cls: "readr-dashboard-direction-count", text: String(count) });
    }
  }

  private renderGapsSection(container: HTMLElement): void {
    if (this.gaps.length === 0) return;

    const section = container.createDiv({ cls: "readr-dashboard-section" });
    section.createEl("h3", { text: "Knowledge Gaps", cls: "readr-dashboard-section-title" });

    for (const gap of this.gaps) {
      const item = section.createDiv({ cls: "readr-dashboard-gap-item" });
      const badge = item.createSpan({ cls: "readr-dashboard-gap-badge", text: String(gap.count) });
      item.createSpan({ text: ` ${gap.label}` });
    }
  }

  // ---- Papers Tab ----

  private renderPapersTab(container: HTMLElement): void {
    // Filter controls
    this.renderFilterBar(container);

    // Paper list
    const list = container.createDiv({ cls: "readr-dashboard-paper-list" });

    if (this.filteredPapers.length === 0) {
      list.createEl("p", { text: "No papers match the current filters.", cls: "readr-dashboard-empty" });
      return;
    }

    for (const paper of this.filteredPapers) {
      this.renderPaperItem(list, paper);
    }

    // Count
    const countBar = container.createDiv({ cls: "readr-dashboard-count-bar" });
    countBar.createSpan({ text: `${this.filteredPapers.length} paper${this.filteredPapers.length !== 1 ? "s" : ""}` });
  }

  private renderFilterBar(container: HTMLElement): void {
    const filterBar = container.createDiv({ cls: "readr-dashboard-filter-bar" });

    // Status filter
    const statusGroup = filterBar.createDiv({ cls: "readr-dashboard-filter-group" });
    statusGroup.createSpan({ text: "Status: ", cls: "readr-dashboard-filter-label" });

    const allBtn = statusGroup.createEl("button", {
      cls: `readr-dashboard-filter-btn${this.filters.status === "all" ? " active" : ""}`,
      text: "All",
    });
    allBtn.addEventListener("click", () => { this.filters.status = "all"; this.applyFilters(); });

    for (const status of ALL_STATUSES) {
      const btn = statusGroup.createEl("button", {
        cls: `readr-dashboard-filter-btn${this.filters.status === status ? " active" : ""}`,
        text: STATUS_MAP[status].label,
      });
      btn.addEventListener("click", () => { this.filters.status = status; this.applyFilters(); });
    }

    // Direction filter
    if (this.directions.length > 0) {
      const dirGroup = filterBar.createDiv({ cls: "readr-dashboard-filter-group" });
      dirGroup.createSpan({ text: "Direction: ", cls: "readr-dashboard-filter-label" });

      const dirSelect = dirGroup.createEl("select", { cls: "readr-dashboard-filter-select" });
      const allOpt = dirSelect.createEl("option", { value: "all", text: "All" });
      if (this.filters.direction === "all") allOpt.selected = true;

      for (const dir of this.directions) {
        const opt = dirSelect.createEl("option", { value: dir, text: dir });
        if (this.filters.direction === dir) opt.selected = true;
      }
      dirSelect.addEventListener("change", () => {
        this.filters.direction = dirSelect.value;
        this.applyFilters();
      });
    }

    // Search
    const searchGroup = filterBar.createDiv({ cls: "readr-dashboard-filter-group readr-dashboard-search-group" });
    const searchInput = searchGroup.createEl("input", {
      cls: "readr-dashboard-search-input",
      attr: { type: "text", placeholder: "Search title or author...", value: this.filters.search },
    });
    searchInput.addEventListener("input", () => {
      this.filters.search = searchInput.value;
      this.applyFilters();
    });
  }

  private applyFilters(): void {
    this.filteredPapers = this.dataService.getFilteredPapers(this.filters);
    this.render();
  }

  private renderPaperItem(container: HTMLElement, paper: PaperEntry): void {
    const item = container.createDiv({ cls: "readr-dashboard-paper-item" });
    item.addEventListener("click", () => {
      this.openPaper(paper);
    });

    // Status badge
    const info = STATUS_MAP[paper.status];
    const badge = item.createSpan({ cls: "readr-dashboard-status-badge", text: info.label });
    badge.style.background = info.color;

    // Title and authors
    const textContainer = item.createDiv({ cls: "readr-dashboard-paper-text" });
    textContainer.createDiv({ cls: "readr-dashboard-paper-title", text: paper.title });
    if (paper.authors.length > 0) {
      textContainer.createDiv({ cls: "readr-dashboard-paper-authors", text: paper.authors.join(", ") });
    }

    // Venue
    if (paper.venue) {
      textContainer.createDiv({ cls: "readr-dashboard-paper-venue", text: paper.venue });
    }

  }

  private openPaper(paper: PaperEntry): void {
    const file = this.app.vault.getAbstractFileByPath(paper.path);
    if (file) {
      this.app.workspace.getLeaf(true).openFile(file as any);
    }
  }

  // ---- Activity Tab ----

  private renderActivityTab(container: HTMLElement): void {
    // Recent activity
    const activitySection = container.createDiv({ cls: "readr-dashboard-section" });
    activitySection.createEl("h3", { text: "Recent Activity", cls: "readr-dashboard-section-title" });

    if (this.activities.length === 0) {
      activitySection.createEl("p", { text: "No recent activity in the last 7 days.", cls: "readr-dashboard-empty" });
    } else {
      const list = activitySection.createDiv({ cls: "readr-dashboard-activity-list" });
      for (const act of this.activities) {
        const item = list.createDiv({ cls: "readr-dashboard-activity-item" });
        item.addEventListener("click", () => {
          const file = this.app.vault.getAbstractFileByPath(act.path);
          if (file) this.app.workspace.getLeaf(true).openFile(file as any);
        });

        const icon = item.createSpan({ cls: "readr-dashboard-activity-icon" });
        setIcon(icon, act.type === "created" ? "plus-circle" : "edit");

        item.createSpan({ cls: "readr-dashboard-activity-label", text: act.label });
        item.createSpan({ cls: "readr-dashboard-activity-time", text: this.formatTimeAgo(act.timestamp) });
      }
    }

    // Knowledge gaps
    const gapsSection = container.createDiv({ cls: "readr-dashboard-section" });
    gapsSection.createEl("h3", { text: "Todo / Reminders", cls: "readr-dashboard-section-title" });

    if (this.gaps.length === 0) {
      gapsSection.createEl("p", { text: "No pending todos. Everything looks good!", cls: "readr-dashboard-empty" });
    } else {
      for (const gap of this.gaps) {
        const gapItem = gapsSection.createDiv({ cls: "readr-dashboard-gap-item" });
        const badge = gapItem.createSpan({ cls: "readr-dashboard-gap-badge", text: String(gap.count) });
        gapItem.createSpan({ text: ` ${gap.label}` });
        gapItem.addEventListener("click", () => {
          this.filters.status = "all";
          if (gap.type === "no-concepts") this.filters.status = "browsed";
          if (gap.type === "no-annotation") this.filters.status = "close-read";
          this.activeTab = "papers";
          this.render();
        });
      }
    }
  }

  // ---- Footer ----

  private renderFooter(container: HTMLElement): void {
    const footer = container.createDiv({ cls: "readr-dashboard-footer" });
    const dataSource = this.dataService.hasDataview ? "Dataview" : "MetadataCache (fallback)";
    footer.createSpan({ text: `Data source: ${dataSource}`, cls: "readr-dashboard-footer-text" });
  }

  // ---- Helpers ----

  private formatTimeAgo(timestamp: number): string {
    const diff = Date.now() - timestamp;
    const mins = Math.floor(diff / 60000);
    if (mins < 1) return "just now";
    if (mins < 60) return `${mins}m ago`;
    const hours = Math.floor(mins / 60);
    if (hours < 24) return `${hours}h ago`;
    const days = Math.floor(hours / 24);
    return `${days}d ago`;
  }

  private startAutoRefresh(): void {
    this.stopAutoRefresh();
    this.refreshInterval = window.setInterval(() => {
      const oldStats = this.stats;
      this.refreshData();
      // Only re-render if data changed
      if (JSON.stringify(oldStats) !== JSON.stringify(this.stats)) {
        this.render();
      }
    }, this.plugin.settings.refreshInterval);
  }

  private stopAutoRefresh(): void {
    if (this.refreshInterval !== null) {
      clearInterval(this.refreshInterval);
      this.refreshInterval = null;
    }
  }

  /** Register vault event listeners for real-time updates */
  private registerVaultEvents(): void {
    const vault = this.app.vault;

    // Helper: check if a file is in library/entries/
    const isEntryFile = (file: TFile): boolean =>
      file.path.startsWith("library/entries/") && file.extension === "md";

    // Debounced refresh to batch multiple changes
    const scheduleRefresh = (): void => {
      if (this.debounceTimer !== null) {
        clearTimeout(this.debounceTimer);
      }
      this.debounceTimer = window.setTimeout(() => {
        this.debounceTimer = null;
        this.refreshData();
        this.render();
      }, 300); // 300ms debounce
    };

    // File created
    const createRef = vault.on("create", (file: TFile) => {
      if (isEntryFile(file)) scheduleRefresh();
    });
    this.vaultEventRefs.push({ event: "create", ref: createRef });

    // File modified
    const modifyRef = vault.on("modify", (file: TFile) => {
      if (isEntryFile(file)) scheduleRefresh();
    });
    this.vaultEventRefs.push({ event: "modify", ref: modifyRef });

    // File deleted
    const deleteRef = vault.on("delete", (file: TFile) => {
      if (isEntryFile(file)) scheduleRefresh();
    });
    this.vaultEventRefs.push({ event: "delete", ref: deleteRef });

    // Metadata cache change (catches frontmatter edits, tag changes, etc.)
    const metadataRef = this.app.metadataCache.on("changed", (file: TFile) => {
      if (isEntryFile(file)) scheduleRefresh();
    });
    this.vaultEventRefs.push({ event: "metadata-changed", ref: metadataRef });
  }

  /** Unregister vault event listeners */
  private unregisterVaultEvents(): void {
    const vault = this.app.vault;
    for (const { event, ref } of this.vaultEventRefs) {
      vault.off(event, ref);
    }
    this.vaultEventRefs = [];
    if (this.debounceTimer !== null) {
      clearTimeout(this.debounceTimer);
      this.debounceTimer = null;
    }
  }
}