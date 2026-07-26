import { App, PluginSettingTab, Setting } from "obsidian";
import ReadRDashboardPlugin from "../main";

export class DashboardSettingTab extends PluginSettingTab {
  plugin: ReadRDashboardPlugin;

  constructor(app: App, plugin: ReadRDashboardPlugin) {
    super(app, plugin);
    this.plugin = plugin;
  }

  display(): void {
    const { containerEl } = this;
    containerEl.empty();

    containerEl.createEl("h2", { text: "ReadR Dashboard Settings" });

    // Refresh interval
    new Setting(containerEl)
      .setName("Auto-refresh interval")
      .setDesc("How often the dashboard refreshes data (in seconds). Minimum 30s.")
      .addText((text) =>
        text
          .setPlaceholder("300")
          .setValue(String(Math.round(this.plugin.settings.refreshInterval / 1000)))
          .onChange(async (value) => {
            const secs = Math.max(30, parseInt(value) || 300);
            this.plugin.settings.refreshInterval = secs * 1000;
            await this.plugin.saveSettings();
          })
      );

    // Default tab
    new Setting(containerEl)
      .setName("Default tab")
      .setDesc("Which tab to show when the dashboard opens.")
      .addDropdown((dropdown) => {
        dropdown
          .addOption("stats", "Stats & Charts")
          .addOption("papers", "Papers & Filters")
          .addOption("activity", "Activity & Todos")
          .setValue(this.plugin.settings.defaultTab)
          .onChange(async (value: "stats" | "papers" | "activity") => {
            this.plugin.settings.defaultTab = value;
            await this.plugin.saveSettings();
          });
      });

    // Synthesis threshold
    new Setting(containerEl)
      .setName("Synthesis threshold")
      .setDesc("Minimum papers in a direction to suggest a synthesis.")
      .addText((text) =>
        text
          .setPlaceholder("3")
          .setValue(String(this.plugin.settings.synthesisThreshold))
          .onChange(async (value) => {
            const n = Math.max(1, parseInt(value) || 3);
            this.plugin.settings.synthesisThreshold = n;
            await this.plugin.saveSettings();
          })
      );

    // Info
    containerEl.createEl("hr");
    containerEl.createEl("p", {
      text: "ReadR Dashboard v1.0.0 — Data source: Dataview API (with MetadataCache fallback).",
      cls: "readr-dashboard-settings-info",
    });
    containerEl.createEl("p", {
      text: "Papers are read from library/entries/. Assets from library/concepts/, library/authors/, library/datasets/, library/benchmarks/.",
      cls: "readr-dashboard-settings-info",
    });
  }
}