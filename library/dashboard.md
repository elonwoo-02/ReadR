# Research Dashboard

This page is a live dashboard when the community **Dataview** plugin is installed and enabled. Without it, use [[dataview-queries]] as a copyable search reference and run `pwsh -File scripts/ReadR.ps1 -Validate` for filesystem checks.

> Dataview reads note metadata only. It does not validate PDF paths or repair links; use the PowerShell tool for those checks.

## Reading Queue

### To Read

```dataview
TABLE file.link AS Paper, venue AS Venue, rating AS Rating, annotation AS Annotation
FROM "library/entries"
WHERE contains(tags, "status/to-read")
SORT file.name ASC
```

### Browsed

```dataview
TABLE file.link AS Paper, venue AS Venue, rating AS Rating, concepts AS Concepts
FROM "library/entries"
WHERE contains(tags, "status/browsed")
SORT file.name ASC
```

### Close Read

```dataview
TABLE file.link AS Paper, venue AS Venue, rating AS Rating, annotation AS Annotation
FROM "library/entries"
WHERE contains(tags, "status/close-read")
SORT file.name ASC
```

## Research Assets

### Concepts

```dataview
TABLE file.link AS Concept, length(related_entries) AS "Linked papers", updated AS Updated
FROM "library/concepts"
WHERE file.name != "README"
SORT updated DESC
```

### Authors, Datasets, and Benchmarks

```dataview
TABLE file.link AS Asset, tags AS Type, length(related_entries) AS "Linked papers", updated AS Updated
FROM "library/authors" OR "library/datasets" OR "library/benchmarks"
WHERE file.name != "README"
SORT updated DESC
```

## Knowledge Gaps

### Entries Missing a PDF Field

```dataview
TABLE file.link AS Paper, venue AS Venue, tags AS Tags
FROM "library/entries"
WHERE !pdf
SORT file.name ASC
```

### Browsed Entries Without Concept Links

```dataview
TABLE file.link AS Paper, venue AS Venue
FROM "library/entries"
WHERE contains(tags, "status/browsed") AND (!concepts OR length(concepts) = 0)
SORT file.name ASC
```

### Close-Read Entries Without an Annotation

```dataview
TABLE file.link AS Paper, venue AS Venue
FROM "library/entries"
WHERE contains(tags, "status/close-read") AND !annotation
SORT file.name ASC
```

## Writing & Projects

### Syntheses

```dataview
TABLE file.link AS Synthesis, direction AS Direction, coverage_status AS Status, length(covered_entries) AS "Covered papers", updated AS Updated
FROM "library/syntheses"
WHERE file.name != "README"
SORT direction ASC
```

### Active Projects

```dataview
TABLE file.link AS Project, research_question AS "Research question", length(related_entries) AS "Linked papers", next_actions AS "Next actions"
FROM "library/projects"
WHERE status = "active"
SORT updated DESC
```

### Directions Ready for a Synthesis

```dataviewjs
const papers = dv.pages('"library/entries"');
const syntheses = dv.pages('"library/syntheses"').where(p => p.file.name !== "README");
const byDirection = new Map();

for (const paper of papers) {
  for (const tag of (paper.tags ?? []).filter(t => t.startsWith("direction/"))) {
    const entries = byDirection.get(tag) ?? [];
    entries.push(paper.file.link);
    byDirection.set(tag, entries);
  }
}

const rows = [...byDirection.entries()]
  .filter(([direction, entries]) => entries.length >= 3 && !syntheses.some(s => s.direction === direction))
  .sort(([left], [right]) => left.localeCompare(right));
dv.table(["Direction", "Papers"], rows);
```

The final view only suggests candidates. Create a synthesis after confirming the papers belong to the same meaningful sub-direction.
