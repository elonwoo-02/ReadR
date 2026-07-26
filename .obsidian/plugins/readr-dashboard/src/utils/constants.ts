import type { PaperStatus, StatusInfo, ThemeColor } from "./types";

/** Plugin view type identifier */
export const VIEW_TYPE_DASHBOARD = "readr-dashboard";

/** Status tag prefix */
export const STATUS_PREFIX = "status/";

/** Direction tag prefix */
export const DIRECTION_PREFIX = "direction/";

/** Status definitions */
export const STATUS_MAP: Record<PaperStatus, StatusInfo> = {
  "to-read": { tag: "status/to-read", label: "To Read", color: "var(--color-blue)", order: 0 },
  browsed: { tag: "status/browsed", label: "Browsed", color: "var(--color-green)", order: 1 },
  "close-read": { tag: "status/close-read", label: "Close Read", color: "var(--color-purple)", order: 2 },
  reviewed: { tag: "status/reviewed", label: "Reviewed", color: "var(--color-orange)", order: 3 },
};

/** All status keys in workflow order */
export const ALL_STATUSES: PaperStatus[] = ["to-read", "browsed", "close-read", "reviewed"];

/** Status tag to key mapping */
export const TAG_TO_STATUS: Record<string, PaperStatus> = {
  "status/to-read": "to-read",
  "status/browsed": "browsed",
  "status/close-read": "close-read",
  "status/reviewed": "reviewed",
};

/** Default theme color */
export const DEFAULT_THEME: ThemeColor = "blue";

/** Refresh interval in ms (5 minutes) */
export const DEFAULT_REFRESH_INTERVAL = 300_000;

/** Number of recent activity items to show */
export const MAX_ACTIVITY_ITEMS = 10;

/** Days considered "recent" for activity tracking */
export const RECENT_ACTIVITY_DAYS = 7;

/** Minimum papers in a direction to suggest a synthesis */
export const SYNTHESIS_THRESHOLD = 3;

/** Dataview plugin ID */
export const DATAVIEW_PLUGIN_ID = "dataview";

/** Library entries folder */
export const ENTRIES_PATH = '"library/entries"';

/** Asset folders for Dataview queries */
export const ASSET_PATHS = {
  concepts: '"library/concepts"',
  authors: '"library/authors"',
  datasets: '"library/datasets"',
  benchmarks: '"library/benchmarks"',
};

/** Rating star to number mapping */
export function parseRating(rating?: string): number {
  if (!rating) return 0;
  const stars = rating.match(/★/g);
  return stars ? stars.length : 0;
}