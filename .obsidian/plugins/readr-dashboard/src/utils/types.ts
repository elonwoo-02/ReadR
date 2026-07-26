/** Paper reading status */
export type PaperStatus = "to-read" | "browsed" | "close-read" | "reviewed";

/** A single paper entry from library/entries */
export interface PaperEntry {
  /** File path relative to vault root */
  path: string;
  /** File name without extension */
  name: string;
  /** Title from frontmatter */
  title: string;
  /** Authors list */
  authors: string[];
  /** Venue string */
  venue: string;
  /** Tags array */
  tags: string[];
  /** PDF path relative to vault */
  pdf?: string;
  /** DOI string */
  doi?: string;
  /** Rating stars */
  rating?: string;
  /** Annotation path */
  annotation?: string;
  /** Linked concept wiki-links */
  concepts?: string[];
  /** Linked author wiki-links */
  authors_related?: string[];
  /** Linked dataset wiki-links */
  datasets?: string[];
  /** Linked benchmark wiki-links */
  benchmarks?: string[];
  /** Extracted reading status */
  status: PaperStatus;
  /** Extracted direction tags */
  directions: string[];
  /** File modification time */
  mtime: number;
  /** File creation time */
  ctime: number;
}

/** A research asset (concept, author, dataset, benchmark) */
export interface AssetEntry {
  path: string;
  name: string;
  type: "concept" | "author" | "dataset" | "benchmark";
  related_entries: string[];
  tags: string[];
  updated: number;
}

/** Aggregate statistics */
export interface DashboardStats {
  totalPapers: number;
  byStatus: Record<PaperStatus, number>;
  byDirection: Record<string, number>;
  assets: {
    concepts: number;
    authors: number;
    datasets: number;
    benchmarks: number;
  };
}

/** Knowledge gap item */
export interface KnowledgeGap {
  type: "missing-pdf" | "no-concepts" | "no-annotation" | "needs-synthesis";
  label: string;
  papers: { path: string; name: string; title: string }[];
  count: number;
}

/** Filter options for the paper list */
export interface FilterOptions {
  status: PaperStatus | "all";
  direction: string | "all";
  search: string;
  minRating: number;
}

/** Recent activity item */
export interface ActivityItem {
  type: "created" | "modified";
  path: string;
  name: string;
  timestamp: number;
  label: string;
}

/** Mapping from status tag to display info */
export interface StatusInfo {
  tag: string;
  label: string;
  color: string;
  order: number;
}

/** Available color themes for the dashboard */
export type ThemeColor = "blue" | "green" | "purple" | "orange" | "red";