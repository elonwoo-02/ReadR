# ReadR — AI-Assisted Research Workflow

An Obsidian vault template for academic research, covering the full pipeline: **sources → library → annotations → reviews**.

## Structure

### Four-Layer Architecture

- `sources/` — Raw materials (read-only). Subdirectories: papers/ web/ books/ talks/ misc/
- `library/` — Paper catalog + knowledge distillation
  - `entries/` — Paper entries (organized by research direction, replace example/)
  - `concepts/` — Core concepts
  - `authors/` — Researchers
  - `datasets/` — Datasets
  - `benchmarks/` — Evaluation benchmarks
  - `comparisons/` — Method comparisons
  - `syntheses/` — Literature syntheses (write after 3+ papers in a sub-direction)
  - `projects/` — Active projects
- `annotations/` — Close-reading notes, mirrors library/entries/ sub-direction structure
- `reviews/` — Survey papers, with `templates/` for structured writing (constraints, outlines, etc.)
- `docs/` — Project-level documentation (articles, introductions, changelog)

### Workflow

**INGEST** → Place PDF in sources/papers/, create entry in library/entries/ (status: to-read)

**BROWSE** → Read summary & introduction, write overview, tag (status: browsed). Concurrently distill: extract concepts to concepts/, record researchers to authors/, datasets to datasets/, compare methods in comparisons/, write syntheses/ after 3+ papers accumulate.

*AI may assist: extract concepts, researchers, datasets, benchmarks; generate method comparison tables; draft synthesis overviews.*

**CLOSE-READ** → Create a close-reading folder under annotations/entries/, update library entry's annotation: path (status: close-read)

*AI may assist: generate close-reading notes per template, embedding figures, tables, and formulas inline within the corresponding sections.*

**REVIEW** → Write formal survey papers in reviews/. Use `reviews/templates/` for structured writing constraints and formatting guidelines.

## Rules

- `sources/` is read-only — never modified
- All files/directories use English names
- Paper entries follow `Short Title (Venue Year).md`
- YAML frontmatter includes: title, authors, venue, tags, pdf, doi, rating
- Tags use category/key style (direction/ method/ task/ status/ venue/)
- Entries link to other notes via: annotation, concepts, authors_related, datasets, benchmarks fields

## AI Assistance Guidelines

### BROWSE Phase — Knowledge Distillation

AI may perform the following after user confirmation:

- Extract core concepts from papers → write to `library/concepts/`, link to related entries
- Extract researcher info → write to `library/authors/`, record affiliation and research interests
- Extract datasets used/contributed → write to `library/datasets/`
- Extract evaluation benchmarks → write to `library/benchmarks/`
- Compare with related methods → write to `library/comparisons/` with comparison tables
- After 3+ papers in a sub-direction → draft `library/syntheses/` overview

### CLOSE-READ Phase — Reading Note Generation

AI generates close-reading notes following the `annotations/_template/reading-note.md` template:

1. **Embed figures/tables/formulas section by section** — never aggregate at the end; explain in context:
   - **Figures**: describe what the figure shows, key findings, relation to the argument. Format: `![Figure X](attachments/fig-XX.png) — This figure shows…`
   - **Tables**: interpret data, compare results, identify trends. Format: `Table X: …` → analysis
   - **Formulas**: explain notation, derivation logic, physical meaning. Format: `Equation X: …` → explanation
2. **Strictly follow the template outline** — place figures/tables/formulas within their respective sections, not as general mentions
3. **Cite the original text** — quote key passages (translated or bilingual), note page numbers
4. **Personal evaluation is required** — Section 6 (Personal Evaluation & Reflection) must be written, demonstrating critical thinking
