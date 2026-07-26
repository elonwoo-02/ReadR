# ReadR Dashboard

An interactive Obsidian dashboard plugin for the [ReadR](https://github.com/your-repo/ReadR) research workflow. Provides real-time statistics, charts, paper filtering, quick actions, and activity tracking — all within Obsidian.

## Features

### 📊 Stats & Charts
- **Summary cards**: Total papers, concepts, authors, datasets at a glance
- **Status distribution**: Bar chart showing papers by reading stage (To Read → Browsed → Close Read → Reviewed)
- **Research directions**: Horizontal progress bars with paper counts per direction
- **Knowledge gaps**: Auto-detected issues (missing PDF, missing concepts, missing annotations, synthesis opportunities)

### 🔍 Interactive Filtering
- **Status filter**: Toggle between All / To Read / Browsed / Close Read / Reviewed
- **Direction filter**: Dropdown to filter by research direction tag
- **Search**: Fuzzy search by paper title or author name
- **Click to open**: Any paper entry opens directly in the editor

### ⚡ Quick Actions
- **Ribbon icon**: One-click dashboard toggle
- **Command palette**: `Open ReadR Dashboard`, `New Paper Entry`, `Refresh ReadR Dashboard`
- **Auto-refresh**: Dashboard data refreshes automatically (configurable interval)

### 📝 Activity & Reminders
- **Recent activity**: Papers created or modified in the last 7 days
- **Todo reminders**: Knowledge gaps displayed as actionable items
- **Click to filter**: Click a gap item to jump to the relevant papers

## Installation

### Prerequisites
- [Obsidian](https://obsidian.md/) v0.15.0+
- [Dataview](https://github.com/blacksmithgu/obsidian-dataview) plugin (recommended — falls back to MetadataCache without it)

### From Source (Current Project)
1. Navigate to `ReadR/.obsidian/plugins/readr-dashboard/`
2. Run `npm install && npm run build`
3. Enable **ReadR Dashboard** in Obsidian Settings → Community Plugins

### Manual (from releases)
1. Download the latest `main.js` and `styles.css` from the releases page
2. Create `ReadR/.obsidian/plugins/readr-dashboard/` in your vault
3. Copy the files there, plus `manifest.json`
4. Enable the plugin in Obsidian settings

## Usage

1. Click the **bar chart icon** (📊) in the left ribbon, or run `Open ReadR Dashboard` from the command palette
2. The dashboard opens in the right sidebar with three tabs:
   - **Stats** — Overview, charts, and knowledge gaps
   - **Papers** — Filtered paper list with search
   - **Activity** — Recent changes and todo reminders
3. Click any paper to open it, or click a gap item to jump to relevant papers

### Settings
- **Auto-refresh interval**: How often data refreshes (default: 300s, minimum: 30s)
- **Default tab**: Which tab to show on open
- **Synthesis threshold**: Minimum papers per direction before suggesting a synthesis

## Data Source

The plugin reads from the standard ReadR vault structure:

| Data | Path |
|------|------|
| Paper entries | `library/entries/` |
| Concepts | `library/concepts/` |
| Authors | `library/authors/` |
| Datasets | `library/datasets/` |
| Benchmarks | `library/benchmarks/` |
| Syntheses | `library/syntheses/` |

It uses the **Dataview API** when available, and falls back to **Obsidian MetadataCache** when Dataview is not installed.

## Development

```bash
cd .obsidian/plugins/readr-dashboard/
npm install        # Install dependencies
npm run dev        # Watch mode for development
npm run build      # Production build
```

### Project Structure

```
.obsidian/plugins/readr-dashboard/
├── manifest.json              # Plugin metadata
├── package.json               # Dependencies
├── tsconfig.json              # TypeScript config
├── esbuild.config.mjs         # Build config
├── main.ts                    # Plugin entry point
├── styles.css                 # Styles (auto-adapts to theme)
└── src/
    ├── DashboardView.ts       # Main view (ItemView)
    ├── DashboardSettingTab.ts # Settings tab
    ├── data/
    │   └── DataService.ts     # Dataview API wrapper
    └── utils/
        ├── types.ts           # TypeScript types
        └── constants.ts       # Constants & config
```

## Compatibility

- **Obsidian**: v0.15.0+
- **Dataview**: Optional (v0.5.0+ recommended)
- **Platform**: Desktop & Mobile (isDesktopOnly: false)

## License

MIT — see [LICENSE](../../LICENSE) for details.