# ReadR

<p align="center">
  <strong>An AI-assisted academic knowledge base for human researchers.</strong><br>
  Four-layer architecture — sources → library → annotations → reviews
</p>

<p align="center">
  <a href="#architecture">Architecture</a> •
  <a href="#workflow">Workflow</a> •
  <a href="#wiki-link-topology">Wiki Links</a> •
  <a href="#comparison-with-llm-wiki">Comparison</a> •
  <a href="#quick-start">Quick Start</a> •
  <a href="#acknowledgments">Credits</a>
</p>

<p align="center">
  English | <a href="README_CN.md">中文</a>
</p>

---

> ReadR is an **Obsidian vault template** for academic paper management, inspired by [Karpathy's LLM Wiki](https://gist.github.com/karpathy/442a6bf555914893e9891c11519de94f) pattern and [llm-wiki](https://github.com/nashsu/llm_wiki) — but built for **human researchers**, not AI agents. The vault organizes the full paper lifecycle into a clean four-layer structure, with AI as an optional assistant rather than the primary author.

---

## Architecture

```
┌──────────────────────────────────────────────────────────┐
│                     SCHEMA LAYER                          │
│       CLAUDE.md — Rules, conventions, workflow            │
├─────────────┬─────────────┬───────────────┬──────────────┤
│             │             │               │              │
│  sources/   │  library/   │ annotations/  │   reviews/   │
│  raw        │  catalog    │  close-read   │   survey     │
│  material   │  + concepts │  notes        │   papers     │
│  (readonly) │             │               │   (output)   │
│             │             │               │              │
│  immutable  │  you curate │  you write    │   you author │
│             │             │               │              │
└─────────────┴─────────────┴───────────────┴──────────────┘
       ↑             ↑              ↑
       └─────────────┴──────────────┘
            wiki-link interop
```

### Design Principles

- **sources are immutable** — PDFs and clippings are never modified once placed
- **one source, one entry** — each paper has exactly one entry in `library/entries/`
- **annotations only after close-reading** — `annotations/` is for deep reading, not browsing
- **knowledge deposition during browsing** — extract concepts, authors, datasets, etc. as you browse
- **synthesis bridges to review** — `syntheses/` bridges from "reading papers" to "writing a survey"

### Directory Structure

```
├── sources/                        Raw materials (readonly)
│   ├── papers/                     Academic paper PDFs
│   ├── web/                        Web articles, blog posts
│   ├── books/                      Books / monograph chapters
│   ├── talks/                      Lectures, courses
│   └── misc/                       Other
│
├── library/                        Paper catalog + knowledge distillation
│   ├── _index.md                   Master index
│   ├── _template/                  Entry template
│   ├── entries/                    Paper entries (by research direction)
│   │   └── example/                Replace with your own directions
│   │       ├── foundations/
│   │       ├── method-a/
│   │       ├── method-b/
│   │       ├── applications/
│   │       └── sub-direction/
│   ├── concepts/                   Core concepts
│   ├── authors/                    Researchers
│   ├── datasets/                   Datasets
│   ├── benchmarks/                 Benchmarks
│   ├── comparisons/                Method comparisons
│   ├── syntheses/                  Synthesis overviews
│   └── projects/                   Active projects
│
├── annotations/                    Close-read notes
│   ├── _template/
│   └── entries/                    Same structure as library/entries/
│       └── example/
│
└── reviews/                        Survey papers
```

### Four Layers in Detail

#### sources/ — Raw Material

**Rule:** Readonly. AI must not modify.

```
sources/
├── papers/      Academic papers, preprints (PDF)
├── web/         Technical blogs, news
├── books/       Book chapters, monograph excerpts
├── talks/       Conference talks, lecture notes
└── misc/        Other (tech reports, code docs, etc.)
```

#### library/entries/ — Paper Entries

One markdown file per paper with YAML frontmatter.

```yaml
---
title: "Full Paper Title"
authors:
  - Last, First
venue: "Conference/Journal (Year)"
tags:
  - direction/your-direction
  - method/your-method
  - task/your-task
  - status/to-read          # to-read | browsed | close-read
  - venue/abbreviation
pdf: ../../sources/papers/paper.pdf
doi: 10.xxxx/xxxxx
rating: ⭐⭐⭐⭐
annotation:                 # fill after close-reading
concepts: []                # linked concepts
authors_related: []         # linked researchers
datasets: []                # linked datasets
benchmarks: []              # linked benchmarks
---
```

**Naming:** `Short Title (Venue Year).md`, e.g. `Attention Is All You Need (NeurIPS 2017).md`.

#### annotations/ — Close-Read Notes

Only for papers with `status: close-read`. One folder per paper. *(AI-assisted generation available; figures, tables, and formulas interleaved inline.)*

```
annotations/entries/your-direction/
└── Paper Name (Venue Year)/
    ├── index.md              ← Full close-read note
    ├── wechat.md             ← WeChat version (optional)
    ├── code/                 ← Code notes (optional)
    └── attachments/          ← Images (fig-01.png style)
```

#### reviews/ — Survey Papers

Final output. Multiple formats supported.

```
reviews/your-survey/
├── survey.md
├── survey.pdf
├── survey.tex
├── outline.md
└── references.bib
```

---

## Workflow

```
sources/     library/      annotations/    reviews/
  │             │              │              │
  ▼             ▼              ▼              ▼
┌──────┐   ┌──────────┐   ┌─────────┐   ┌──────────┐
│INgest│──▶│  Browse  │──▶│CloseRead│──▶│  Review   │
│      │   │          │   │         │   │          │
└──────┘   └─────┬────┘   └─────────┘   └──────────┘
                 │
                 ▼
             concepts/         ← deposited during browsing
             authors/
             datasets/
             benchmarks/
             comparisons/
             syntheses/        ← write after 3+ papers
             projects/
```

### 1. INGEST

Download PDF → place in `sources/papers/` → create entry in `library/entries/` with YAML frontmatter and `status: to-read`.

### 2. BROWSE (with deposition)

Read abstract & intro → write summary → tag → set `status: browsed`.

While browsing, deposit knowledge:
- New concept → `library/concepts/`
- New researcher → `library/authors/`
- Dataset / benchmark → `library/datasets/` or `library/benchmarks/`
- Related methods → `library/comparisons/` (comparison table)
- 3+ papers in a sub-direction → `library/syntheses/` (synthesis)
- Project relevance → `library/projects/`

> **AI can assist with:** extracting concepts, researchers, datasets, benchmarks; generating comparison tables; drafting synthesis overviews.

### 3. CLOSE-READ

Line-by-line reading → create annotation folder in `annotations/entries/` → update the library entry's `annotation:` path and set `status: close-read`.

> **AI can assist with:** generating close-read notes from the template, with figures, tables, and formulas explained inline. (See `annotations/_template/reading-note.md`)

### 4. REVIEW

Synthesize all papers in a sub-direction → consult `concepts/`, `syntheses/`, `comparisons/` → write a formal survey in `reviews/`.

---

## Wiki Link Topology

```
library/entries/paper.md ──→ annotations/entries/paper/index.md
         │                          │
         ├──→ library/concepts/     │
         ├──→ library/authors/      │
         ├──→ library/datasets/     │
         ├──→ library/benchmarks/   │
         └──→ library/comparisons/  │
                                    │
                └───────────────────┘
                ▼
         reviews/review.md ──→ library/syntheses/
```

- **Paper entry → concepts/authors/data/benchmarks/comparisons**: each paper links to multiple knowledge nodes
- **Concepts ↔ Authors**: bidirectional links between concepts and their proposers
- **Close-read notes → paper entry**: annotations deepen the entry, linked via the `annotation:` field
- **Survey → Synthesis**: reviews reference syntheses, syntheses reference entries

---

## Comparison with llm-wiki

| Dimension         | llm-wiki (Karpathy)          | ReadR                                     |
| ----------------- | ---------------------------- | ----------------------------------------- |
| **Target user**   | AI Agent (human reviews)     | Human researcher (AI assists)             |
| **Knowledge unit**| Articles, videos, notes, docs| Academic papers                           |
| **Layer architecture**| raw/ → wiki/ → schema   | sources/ → library/ + annotations/ → reviews/ |
| **Immutable layer**| raw/                      | sources/ (PDFs/clippings)                 |
| **Knowledge layer**| wiki/ (AI-maintained)    | library/ (human-curated)                  |
| **Close-read layer**| None                     | annotations/ (independent notes)          |
| **Output layer**  | None (wiki is the output)    | reviews/ (publishable surveys)            |
| **Primary author**| AI Agent                    | Human                                     |
| **Status model**  | active / stale / archived    | to-read / browsed / close-read            |
| **Metadata**      | Generic frontmatter          | Academic (authors/venue/DOI/rating)       |
| **Synthesis**     | AI auto-updates overviews    | Human writes syntheses/ → reviews/        |
| **End goal**      | Knowledge accumulation       | Knowledge accumulation → survey output    |

### Core Differences

llm-wiki treats the LLM as a "knowledge compiler" — you feed raw materials, the AI maintains the wiki. ReadR puts **humans** at the center; AI is an assistant, not the author.

1. **Close-read layer** — llm-wiki has no equivalent. Machine summaries can't replace line-by-line human reading of derivations, experiments, and ablations.
2. **Survey layer** — llm-wiki's wiki is the endpoint. In research, the endpoint is a publishable survey.
3. **Entity splitting** — llm-wiki uses a single `entities/`. Research needs distinct entity types for researchers, datasets, and benchmarks.

### What We Borrowed

- **Layer separation** — `sources/` (immutable) vs `library/` (your understanding)
- **Incremental compilation** — browse once, accumulate forever
- **Wiki-link topology** — bidirectional links across concepts/authors/comparisons
- **CLAUDE.md contract** — encode rules so AI behaves consistently
- **Convention over configuration** — YAML schema, tag system, naming conventions

---

## Quick Start

### Prerequisites

- [Obsidian](https://obsidian.md/) or any Markdown editor
- (Optional) [Claude Code](https://claude.ai/code) for AI assistance

```bash
# 1. Clone the repo
git clone https://github.com/elonwoo-02/ReadR.git
cd ReadR

# 2. Open in Obsidian
# Open Obsidian → "Open folder as vault" → select ReadR/

# 3. (First time) Replace example with your own direction
rm -rf library/entries/example
mkdir -p library/entries/your-direction/your-sub-direction
mkdir -p annotations/entries/your-direction
# Then update the direction name in library/_index.md
```

### Getting Started

```bash
# 1. Download a paper PDF → sources/papers/
# 2. Create an entry: cp library/_template/library-entry.md library/entries/your-direction/paper.md
# 3. Fill in YAML frontmatter + write a summary
# 4. As you browse, extract concepts/authors/datasets to the corresponding directories
# 5. After close-reading, create annotations in annotations/entries/your-direction/
```

### AI Assistance (Optional)

| Stage | AI can help with |
|-------|-----------------|
| **BROWSE** — knowledge deposition | Extract concepts, researchers, datasets, benchmarks; generate comparison tables; draft synthesis overviews |
| **CLOSE-READ** — annotation notes | Generate notes from the template, with figures/tables/formulas explained inline (see `annotations/_template/reading-note.md`) |

The `CLAUDE.md` file contains the full project structure and rules — AI tools will follow them automatically.

---

## Acknowledgments

- [**Karpathy's LLM Wiki**](https://gist.github.com/karpathy/442a6bf555914893e9891c11519de94f) — source of inspiration for layer separation and incremental compilation
- [**llm-wiki**](https://github.com/nashsu/llm_wiki) — practical reference for AI-assisted knowledge base management

---

## License

MIT © 2026 Elon Woo — see [LICENSE](LICENSE)
