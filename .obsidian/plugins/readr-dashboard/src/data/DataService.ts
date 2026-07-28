import { App, TFile, MetadataCache, Vault } from "obsidian";
import type {
  PaperEntry,
  PaperStatus,
  AssetEntry,
  DashboardStats,
  KnowledgeGap,
  ActivityItem,
  FilterOptions,
} from "../utils/types";
import {
  ALL_STATUSES,
  ENTRIES_PATH,
  ASSET_PATHS,
  SYNTHESIS_THRESHOLD,
  MAX_ACTIVITY_ITEMS,
  RECENT_ACTIVITY_DAYS,
} from "../utils/constants";

/**
 * Data service that wraps the Dataview API to query paper metadata.
 * Falls back to Obsidian MetadataCache when Dataview is unavailable.
 */
export class DataService {
  private dv: any | null = null;

  constructor(private app: App) {
    try {
      const dvPlugin = (this.app as any).plugins?.getPlugin("dataview");
      if (dvPlugin?.api) {
        this.dv = dvPlugin;
      }
    } catch {
      // Dataview not available
    }
  }

  /** Whether Dataview is available */
  get hasDataview(): boolean {
    return this.dv !== null;
  }

  /** Get all paper entries from library/entries */
  getAllPapers(): PaperEntry[] {
    if (this.dv) {
      return this.getPapersFromDataview();
    }
    return this.getPapersFromMetadata();
  }

  /** Get papers filtered by status */
  getPapersByStatus(status: PaperStatus): PaperEntry[] {
    return this.getAllPapers().filter((p) => p.status === status);
  }

  /** Get papers filtered by direction */
  getPapersByDirection(direction: string): PaperEntry[] {
    return this.getAllPapers().filter((p) => p.direction === direction);
  }

  /** Get papers matching filter options */
  getFilteredPapers(filters: FilterOptions): PaperEntry[] {
    return this.getAllPapers().filter((p) => {
      if (filters.status !== "all" && p.status !== filters.status) return false;
      if (filters.direction !== "all" && p.direction !== filters.direction) return false;
      if (filters.search) {
        const q = filters.search.toLowerCase();
        const matchTitle = p.title.toLowerCase().includes(q);
        const matchAuthor = p.authors.some((a) => a.toLowerCase().includes(q));
        if (!matchTitle && !matchAuthor) return false;
      }
      return true;
    });
  }

  /** Get aggregate statistics */
  getStats(): DashboardStats {
    const papers = this.getAllPapers();

    const byStatus: Record<string, number> = {
      "to-read": 0,
      browsed: 0,
      "close-read": 0,
      reviewed: 0,
    };
    const byDirection: Record<string, number> = {};

    for (const p of papers) {
      byStatus[p.status] = (byStatus[p.status] ?? 0) + 1;
      if (p.direction) {
        byDirection[p.direction] = (byDirection[p.direction] ?? 0) + 1;
      }
    }

    return {
      totalPapers: papers.length,
      byStatus: byStatus as Record<PaperStatus, number>,
      byDirection,
      assets: this.getAssetCounts(),
    };
  }

  /** Get knowledge gaps */
  getKnowledgeGaps(): KnowledgeGap[] {
    const papers = this.getAllPapers();
    const gaps: KnowledgeGap[] = [];

    // Missing source field
    const missingSource = papers
      .filter((p) => !p.source)
      .map((p) => ({ path: p.path, name: p.name, title: p.title }));
    if (missingSource.length > 0) {
      gaps.push({ type: "missing-source", label: "Missing Source Field", papers: missingSource, count: missingSource.length });
    }

    // Browsed without concept links
    const noConcepts = papers
      .filter((p) => p.status === "browsed" && (!p.concepts || p.concepts.length === 0))
      .map((p) => ({ path: p.path, name: p.name, title: p.title }));
    if (noConcepts.length > 0) {
      gaps.push({ type: "no-concepts", label: "Browsed Without Concepts", papers: noConcepts, count: noConcepts.length });
    }

    // Close-read without annotation
    const noAnnotation = papers
      .filter((p) => p.status === "close-read" && !p.annotation_path)
      .map((p) => ({ path: p.path, name: p.name, title: p.title }));
    if (noAnnotation.length > 0) {
      gaps.push({ type: "no-annotation", label: "Close-Read Without Annotation", papers: noAnnotation, count: noAnnotation.length });
    }

    // Directions with 3+ papers but no synthesis
    const byDirection = this.getDirectionPaperCounts();
    const needsSynthesisEntries: { path: string; name: string; title: string }[] = [];
    for (const [dir, count] of Object.entries(byDirection)) {
      if (count >= SYNTHESIS_THRESHOLD && !this.hasSynthesisForDirection(dir)) {
        needsSynthesisEntries.push({ path: "", name: dir, title: dir });
      }
    }
    if (needsSynthesisEntries.length > 0) {
      gaps.push({
        type: "needs-synthesis",
        label: "Directions Ready for Synthesis",
        papers: needsSynthesisEntries,
        count: needsSynthesisEntries.length,
      });
    }

    return gaps;
  }

  /** Get recent activity items */
  getRecentActivity(): ActivityItem[] {
    const papers = this.getAllPapers();
    const now = Date.now();
    const cutoff = now - RECENT_ACTIVITY_DAYS * 24 * 60 * 60 * 1000;

    const activities: ActivityItem[] = papers
      .filter((p) => p.mtime > cutoff || p.ctime > cutoff)
      .map((p) => {
        const isNew = p.ctime > cutoff && Math.abs(p.ctime - p.mtime) < 60000;
        return {
          type: isNew ? "created" as const : "modified" as const,
          path: p.path,
          name: p.name,
          timestamp: Math.max(p.ctime, p.mtime),
          label: isNew ? `Added: ${p.title}` : `Updated: ${p.title}`,
        };
      })
      .sort((a, b) => b.timestamp - a.timestamp)
      .slice(0, MAX_ACTIVITY_ITEMS);

    return activities;
  }

  /** Get all unique directions */
  getAllDirections(): string[] {
    const dirs = new Set<string>();
    for (const p of this.getAllPapers()) {
      if (p.direction) {
        dirs.add(p.direction);
      }
    }
    return [...dirs].sort();
  }

  // ---- Private helpers ----

  /** Query papers via Dataview API */
  private getPapersFromDataview(): PaperEntry[] {
    try {
      const api = this.dv?.api;
      if (!api) return [];
      const pages = api.pages(ENTRIES_PATH) ?? [];
      return pages.map((p: any) => this.toPaperEntry(p)).filter((e: PaperEntry | null): e is PaperEntry => e !== null);
    } catch {
      return [];
    }
  }

  /** Fallback: parse papers from MetadataCache */
  private getPapersFromMetadata(): PaperEntry[] {
    const files = this.app.vault.getMarkdownFiles().filter((f) => f.path.startsWith("library/entries/"));
    return files.map((f) => this.parseFileFrontmatter(f)).filter((e): e is PaperEntry => e !== null);
  }

  /** Convert a Dataview page object to PaperEntry */
  private toPaperEntry(page: any): PaperEntry | null {
    try {
      const status: PaperStatus = this.parseStatus(page.status) ?? "to-read";

      return {
        path: page.file?.path ?? "",
        name: page.file?.name ?? "",
        title: page.title ?? page.file?.name ?? "",
        authors: page.authors ?? [],
        venue: page.venue ?? "",
        method: page.method ?? "",
        task: page.task ?? "",
        status,
        direction: page.direction ?? "",
        source: page.source ?? undefined,
        doi: page.doi ?? undefined,
        annotation_path: page.annotation_path ?? undefined,
        concepts: page.concepts ?? [],
        datasets: page.datasets ?? [],
        benchmarks: page.benchmarks ?? [],
        mtime: page.file?.mtime ?? 0,
        ctime: page.file?.ctime ?? 0,
      };
    } catch {
      return null;
    }
  }

  /** Parse a file's frontmatter directly (fallback) */
  private parseFileFrontmatter(file: TFile): PaperEntry | null {
    try {
      const cache = this.app.metadataCache.getFileCache(file);
      const fm = cache?.frontmatter;
      if (!fm) return null;

      const status: PaperStatus = this.parseStatus(fm.status) ?? "to-read";

      return {
        path: file.path,
        name: file.basename,
        title: fm.title ?? file.basename,
        authors: fm.authors ?? [],
        venue: fm.venue ?? "",
        method: fm.method ?? "",
        task: fm.task ?? "",
        status,
        direction: fm.direction ?? "",
        source: fm.source ?? undefined,
        doi: fm.doi ?? undefined,
        annotation_path: fm.annotation_path ?? undefined,
        concepts: fm.concepts ?? [],
        datasets: fm.datasets ?? [],
        benchmarks: fm.benchmarks ?? [],
        mtime: file.stat.mtime,
        ctime: file.stat.ctime,
      };
    } catch {
      return null;
    }
  }

  /** Parse status from a string field value */
  private parseStatus(value: any): PaperStatus | null {
    if (!value || typeof value !== "string") return null;
    const s = value.trim().toLowerCase() as PaperStatus;
    if (ALL_STATUSES.includes(s)) return s;
    return null;
  }

  /** Get paper counts per direction */
  private getDirectionPaperCounts(): Record<string, number> {
    const counts: Record<string, number> = {};
    for (const p of this.getAllPapers()) {
      if (p.direction) {
        counts[p.direction] = (counts[p.direction] ?? 0) + 1;
      }
    }
    return counts;
  }

  /** Check if a synthesis exists for a direction */
  private hasSynthesisForDirection(direction: string): boolean {
    try {
      if (this.dv) {
        const syntheses = this.dv.api?.pages('"library/syntheses"') ?? [];
        return syntheses.some((s: any) => s.direction === direction);
      }
      const files = this.app.vault
        .getMarkdownFiles()
        .filter((f) => f.path.startsWith("library/syntheses/"));
      for (const f of files) {
        const cache = this.app.metadataCache.getFileCache(f);
        if (cache?.frontmatter?.direction === direction) return true;
      }
    } catch {
      // ignore
    }
    return false;
  }

  /** Get asset counts from Dataview or metadata */
  private getAssetCounts(): { concepts: number; authors: number; datasets: number; benchmarks: number } {
    if (this.dv) {
      try {
        const api = this.dv.api;
        return {
          concepts: (api.pages(ASSET_PATHS.concepts) ?? []).length,
          authors: (api.pages(ASSET_PATHS.authors) ?? []).length,
          datasets: (api.pages(ASSET_PATHS.datasets) ?? []).length,
          benchmarks: (api.pages(ASSET_PATHS.benchmarks) ?? []).length,
        };
      } catch {
        // fall through
      }
    }

    // Fallback: count files
    const files = this.app.vault.getMarkdownFiles();
    return {
      concepts: files.filter((f) => f.path.startsWith("library/concepts/") && f.name !== "README.md").length,
      authors: files.filter((f) => f.path.startsWith("library/authors/") && f.name !== "README.md").length,
      datasets: files.filter((f) => f.path.startsWith("library/datasets/") && f.name !== "README.md").length,
      benchmarks: files.filter((f) => f.path.startsWith("library/benchmarks/") && f.name !== "README.md").length,
    };
  }
}
