import { Plugin, WorkspaceLeaf, TFile, Notice } from "obsidian";
import { DashboardView } from "./src/DashboardView";
import { DashboardSettingTab } from "./src/DashboardSettingTab";
import { VIEW_TYPE_DASHBOARD, DEFAULT_REFRESH_INTERVAL } from "./src/utils/constants";

/** Plugin settings interface */
interface ReadRDashboardSettings {
  refreshInterval: number;
  defaultTab: "stats" | "papers" | "activity";
  synthesisThreshold: number;
}

const DEFAULT_SETTINGS: ReadRDashboardSettings = {
  refreshInterval: DEFAULT_REFRESH_INTERVAL,
  defaultTab: "stats",
  synthesisThreshold: 3,
};

export default class ReadRDashboardPlugin extends Plugin {
  settings: ReadRDashboardSettings = DEFAULT_SETTINGS;
  private dashboardView: DashboardView | null = null;

  async onload(): Promise<void> {
    await this.loadSettings();

    // Register dashboard view
    this.registerView(VIEW_TYPE_DASHBOARD, (leaf: WorkspaceLeaf) => {
      this.dashboardView = new DashboardView(leaf, this);
      return this.dashboardView;
    });

    // Ribbon icon
    this.addRibbonIcon("bar-chart", "Open ReadR Dashboard", () => {
      this.activateView();
    });

    // Commands
    this.addCommand({
      id: "open-readr-dashboard",
      name: "Open ReadR Dashboard",
      callback: () => this.activateView(),
    });

    this.addCommand({
      id: "new-paper-entry",
      name: "New Paper Entry",
      callback: () => this.createNewPaper(),
    });

    this.addCommand({
      id: "refresh-readr-dashboard",
      name: "Refresh ReadR Dashboard",
      callback: () => {
        if (this.dashboardView) {
          this.dashboardView.refreshData();
          this.dashboardView.render();
          new Notice("ReadR Dashboard refreshed");
        }
      },
    });

    // Settings tab
    this.addSettingTab(new DashboardSettingTab(this.app, this));

    // If the view was already open (from workspace restore), re-focus
    this.app.workspace.onLayoutReady(() => {
      this.activateView();
    });
  }

  async onunload(): Promise<void> {
    this.app.workspace.detachLeavesOfType(VIEW_TYPE_DASHBOARD);
  }

  /** Activate the dashboard view */
  async activateView(): Promise<void> {
    const { workspace } = this.app;

    let leaf = workspace.getLeavesOfType(VIEW_TYPE_DASHBOARD).first();

    if (!leaf) {
      const rightLeaf = workspace.getRightLeaf(false);
      if (!rightLeaf) return;
      leaf = rightLeaf;
      await leaf.setViewState({ type: VIEW_TYPE_DASHBOARD, active: true });
    }

    workspace.revealLeaf(leaf);
  }

  /** Create a new paper entry from template */
  async createNewPaper(): Promise<void> {
    // Read the template
    const templateFile = this.app.vault.getAbstractFileByPath("library/_template/library-entry.md");
    if (!(templateFile instanceof TFile)) {
      new Notice("Template not found at library/_template/library-entry.md");
      return;
    }

    const templateContent = await this.app.vault.read(templateFile);

    // Generate a default file name
    const now = new Date();
    const dateStr = `${now.getFullYear()}-${String(now.getMonth() + 1).padStart(2, "0")}-${String(now.getDate()).padStart(2, "0")}`;
    const fileName = `New Paper (${dateStr}).md`;

    // Create the file in the entries directory
    const filePath = `library/entries/your_direction/${fileName}`;
    try {
      await this.app.vault.create(filePath, templateContent);
      const leaf = this.app.workspace.getLeaf(true);
      const file = this.app.vault.getAbstractFileByPath(filePath);
      if (file instanceof TFile) {
        await leaf.openFile(file);
        new Notice("New paper entry created");
      }
    } catch (err) {
      new Notice(`Failed to create paper entry: ${err}`);
    }
  }

  async loadSettings(): Promise<void> {
    const data = await this.loadData();
    this.settings = Object.assign({}, DEFAULT_SETTINGS, data);
  }

  async saveSettings(): Promise<void> {
    await this.saveData(this.settings);
    // Refresh dashboard if settings changed
    if (this.dashboardView) {
      this.dashboardView.render();
    }
  }
}

// Re-export for use in views
export type { ReadRDashboardSettings };