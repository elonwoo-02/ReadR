# Dataview Query Reference

Install the [Dataview community plugin](https://blacksmithgu.github.io/obsidian-dataview/) in Obsidian: **Settings → Community plugins → Browse → Dataview**, then enable it. The queries below use the vault-relative folders in this repository and do not require committing plugin configuration.

## Filter by Direction

```dataview
TABLE file.link AS Paper, venue, rating
FROM "library/entries"
WHERE contains(tags, "direction/your-direction")
SORT file.name ASC
```

## Filter by Author

```dataview
TABLE file.link AS Paper, venue, rating
FROM "library/entries"
WHERE contains(authors, "Family, Given Name")
SORT file.name ASC
```

## Find Dataset or Benchmark Usage

```dataview
TABLE file.link AS Paper, datasets, benchmarks
FROM "library/entries"
WHERE contains(datasets, [[Dataset Name]]) OR contains(benchmarks, [[Benchmark Name]])
SORT file.name ASC
```

## Filter by Any Tag or Reading Status

```dataview
TABLE file.link AS Paper, tags
FROM "library/entries"
WHERE contains(tags, "method/your-method") AND contains(tags, "status/browsed")
SORT file.name ASC
```

## Show Research Notes Linked to an Entry

```dataview
TABLE file.link AS Note, tags, updated
FROM "library"
WHERE contains(related_entries, [[Short Title (Venue Year)]])
SORT updated DESC
```

Replace placeholder values with your vault values. For checks that require real files to exist (PDFs and linked annotations), use `scripts/ReadR.ps1` instead of Dataview.
