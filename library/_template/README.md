# ReadR Templates

This directory holds the master templates for every knowledge note in the ReadR
vault. Each template defines a **YAML frontmatter** (structured facets that can
be filtered and aggregated) and a **body** (narrative content). They are copied
into the corresponding `library/` subdirectory to create a new note.

```text
library/_template/
├── library-entry.md   # a paper entry (in library/entries/<direction>/)
├── concept.md         # a core concept
├── dataset.md         # a dataset or benchmark
├── author.md          # a researcher profile
├── comparison.md      # a method comparison
├── synthesis.md       # a sub-direction literature synthesis
└── project.md         # an active research project
```

## Design principle: facets vs. narrative

Every template follows the same rule for what goes in YAML vs. what goes in the
body:

- **YAML frontmatter holds *facets*** — short, filterable values: types, enums,
  time stamps, short lists, external links, and wiki-link labels. Anything you
  want to search or filter the vault by lives here.
- **The body holds *narrative*** — prose, tables, and contextual links. Anything
  that needs sentences to be understood, or that explains "how" and "why", lives
  here.

When a field is a short list of labels used for cross-referencing (e.g.
`keywords`, `methods`, `paradigms`, `datasets` as labels), it stays in YAML.
When a list needs a one-sentence role or contribution per item, it moves to the
body (e.g. `Selected Works` in author notes, `Paradigms` in synthesis notes).

### Linking conventions

- `source` and `annotation` use Obsidian wiki-links `[[...]]` (validator
  enforces these). `source` keeps the file extension; `annotation` omits it.
- `concepts` and `datasets` in a paper entry are wiki-link labels to the
  corresponding notes in `library/concepts/` and `library/datasets/`.
- Cross-references inside a body use `[[...]]` wiki-links.

### Trust signals

Every note carries two YAML fields describing who produced the content and
whether it has been reviewed:

- `generated: human | ai | agent` — who created the content.
- `verified: unverified | machine-confirmed | human-reviewed` — review status.

AI-drafted content is labelled `generated: ai` / `verified: unverified` and
upgraded by the human after review.

---

## `library-entry.md` — Paper entry

**Purpose:** one entry per paper, the central node that everything else links
back to. Lives under `library/entries/<direction>/`. One source, one entry.

### Frontmatter

| Field | Meaning |
|---|---|
| `type` | Always `"Academic Paper"`. |
| `title` | Paper title. |
| `authors` | List of `Last, First`. Each should resolve to an author note. |
| `venue` | Venue and year, e.g. `"NeurIPS 2025"`. |
| `method` | Method abbreviation, e.g. `"GFM-RAG"`. |
| `task` | Specific task, e.g. `"GraphRAG"`. |
| `keywords` | Topic tags for searching. |
| `status` | `to-read` → `browsed` → `close-read`. |
| `direction` | Hierarchical direction path, e.g. `"nlp/knowledge-graph/kg-augmented-llm"`. |
| `source` | Wiki-link to the PDF in `sources/`, e.g. `"[[paper.pdf]]"`. |
| `doi` | DOI. |
| `url` | External paper URL (arXiv, ACL Anthology, project page). |
| `annotation` | Wiki-link to the close-reading note in `annotations/`. Required when `status: close-read`. |
| `concepts` | Wiki-link labels to concept notes, e.g. `"[[GraphRAG]]"`. |
| `datasets` | Wiki-link labels to dataset/benchmark notes. |
| `metrics` | Evaluation metrics used on each dataset, e.g. `["Recall@5", "F1"]`. |
| `github` | Code repository URL. |
| `generated` / `verified` | Trust signals. |
| `created` / `updated` | Lifecycle dates. |

### Body

Minimal. Just the title with venue year and a one-sentence "elevator pitch":

```markdown
# Paper Title (Venue Year)

> **In one sentence:** The paper proposes [method] to address [problem],
> achieving [key result] on [task].
```

Detailed analysis of a paper belongs in its close-reading note
(`annotations/<direction>/<paper-name>/reading-note.md`), not here.

---

## `concept.md` — Core concept

**Purpose:** captures a single concept (algorithm, model, paradigm) so the
vault can define and cross-reference it. Lives in `library/concepts/`.

### Frontmatter

| Field | Meaning |
|---|---|
| `type` | Always `"Concept"`. |
| `title` | Concept name. |
| `aliases` | Known variants / acronyms, e.g. `["GFM"]`. Used for de-duplication. |
| `generated` / `verified` | Trust signals. |
| `created` / `updated` | Lifecycle dates. |

### Body

- **`Definition / Summary`** — your own words, the research problem it
  addresses, and a key formula if applicable.
- **`Usage & Variants`** — how the concept is used and its common variants.
- **`Related Concepts & Entries`** — contextual wiki-links (the narrative
  counterpart to the aliases list).

---

## `dataset.md` — Dataset or benchmark

**Purpose:** records a dataset or benchmark as a reusable asset. Datasets and
benchmarks are merged into one note type; the `subtype` field distinguishes
them. Lives in `library/datasets/`.

### Frontmatter

| Field                    | Meaning                                                               |
| ------------------------ | --------------------------------------------------------------------- |
| `type`                   | Always `"Dataset"`.                                                   |
| `title`                  | Resource name.                                                        |
| `subtype`                | `dataset` (data collection) \| `benchmark` (eval standard) \| `both`. |
| `year`                   | Publication year.                                                     |
| `task`                   | Intended task(s), e.g. `["Multi-Hop QA"]`.                            |
| `modality`               | `text`, `image`, `audio`, `multimodal`, etc.                          |
| `size`                   | e.g. `"4.5M sentence pairs"`.                                         |
| `license`                | e.g. `"CC-BY-4.0"`.                                                   |
| `homepage`               | Project / dataset website.                                            |
| `paper`                  | External link to the source paper (arXiv / ACL Anthology / DOI).      |
| `github`                 | Code or data repository.                                              |
| `leaderboard`            | Benchmark leaderboard URL.                                            |
| `generated` / `verified` | Trust signals.                                                        |
| `created` / `updated`    | Lifecycle dates.                                                      |

### Body

- **`Definition / Summary`** — what the resource is and why it is useful.
- **`Related Research`** — papers that use this resource.
- **`Protocol`** — for benchmarks: evaluation protocol, split sizes, metric
  definitions.

> **Note:** `paper` is an *external* link, not a vault wiki-link — the source
> paper is rarely an entry in this vault.

---

## `author.md` — Researcher profile

**Purpose:** a note per researcher, in `Last, First` order. Lives in
`library/authors/`. One canonical name per researcher.

### Frontmatter

| Field | Meaning |
|---|---|
| `type` | Always `"Person"`. |
| `title` | `"Last, First"` citation order, e.g. `"Vaswani, Ashish"`. |
| `affiliation` | e.g. `"Google Brain"`. |
| `position` | e.g. `"Professor"`, `"PhD Student"`. |
| `lab` | Lab / group name. |
| `research_interests` | Short list of research areas. |
| `homepage` | Personal or lab website. |
| `orcid` | e.g. `"0000-0001-2345-6789"`. |
| `generated` / `verified` | Trust signals. |
| `created` / `updated` | Lifecycle dates. |

### Body

- **`Overview`** — one-sentence profile: who they are, current position, what
  they are known for.
- **`Research Focus`** — research areas with a brief description each.
- **`Selected Works`** — wiki-links to entries, each with a one-sentence
  contribution.
- **`Research Trajectory`** — how their interests evolved (optional).
- **`Connections`** — key collaborators and lab/group.
- **`Relevance`** — why this researcher matters for your current direction.

---

## `comparison.md` — Method comparison

**Purpose:** compares methods across explicitly stated decision criteria, so a
decision can be revisited and defended. Lives in `library/comparisons/`.

### Frontmatter

| Field | Meaning |
|---|---|
| `type` | Always `"Comparison"`. |
| `title` | e.g. `"GCR vs SCR vs GFM-RAG vs G-reasoner"`. |
| `methods` | Methods being compared (facet). |
| `decision_criteria` | Criteria, e.g. `["Performance", "Efficiency", "Hallucination"]`. |
| `related_concepts` | Concepts involved. |
| `last_compared` | Date of the last update (comparisons go stale). |
| `generated` / `verified` | Trust signals. |
| `created` / `updated` | Lifecycle dates. |

### Body

- **`Definition / Summary`** — the decision or technical question the
  comparison answers, and which dimensions it covers.
- **`Decision Criteria`** — each criterion and why it matters.
- **`Comparison by Criterion`** — one subsection (and table) per criterion.
  Methods are rows; the dimension columns and an `Evidence` column are set per
  criterion. This structure mirrors how comparisons are actually written
  (multi-dimensional tables), unlike a single fixed "Strengths/Limitations"
  table.
- **`Key Observations`** — cross-cutting findings that answer the decision
  question.

---

## `synthesis.md` — Literature synthesis

**Purpose:** the bridge between close-reading individual papers and writing a
formal survey. Written after 3+ papers in a sub-direction. Lives in
`library/syntheses/`.

### Frontmatter

| Field | Meaning |
|---|---|
| `type` | Always `"Synthesis"`. |
| `title` | e.g. `"KG-Augmented LLM Synthesis"`. |
| `direction` | Hierarchical direction path. |
| `paradigms` | Paradigm labels, e.g. `["KG Quality Fix", "Learned Graph Reasoning"]`. |
| `coverage_status` | `draft` \| `partial` \| `complete`. |
| `generated` / `verified` | Trust signals. |
| `created` / `updated` | Lifecycle dates. |

### Body

- **`Overview`** — define the direction, core problems, state of the art.
- **`Paradigms / Method Clusters`** — identify distinct technical paradigms and
  group papers under each (wiki-links with a one-sentence contribution).
- **`Field Narrative`** — trace the evolution: milestones, paradigm shifts.
- **`Key Tensions`** — central trade-offs (e.g. faithfulness vs. generality),
  with each side backed by a source note.
- **`Coverage Status`** — which papers are covered and at what depth.
- **`Gaps and Future Directions`** — open problems and missing comparisons.

> The `Paradigms / Method Clusters` + `Field Narrative` + `Key Tensions`
> structure is the seed for a formal survey: it supplies the mental model, the
> chronological arc, and the tensions that give a survey its argument.

---

## `project.md` — Active research project

**Purpose:** a note for *your own* research project — the place where reading
accumulates turns into action. Not a code-reproduction log; that is a task
inside `Next Actions`. Lives in `library/projects/`.

### Frontmatter

| Field | Meaning |
|---|---|
| `type` | Always `"Project"`. |
| `title` | Project name. |
| `status` | `active` \| `paused` \| `completed`. |
| `start_date` | When the project started. |
| `datasets` | Datasets used or planned (facet). |
| `generated` / `verified` | Trust signals. |
| `created` / `updated` | Lifecycle dates. |

### Body

- **`Definition / Summary`** — your research question, hypothesis, expected
  outcomes.
- **`Related Research`** — literature, datasets/benchmarks, and current status
  that inform the project.
- **`Milestones`** — dated milestones.
- **`Next Actions`** — concrete next steps.

---

## Template lifecycle

1. **Copy** the template into the relevant subdirectory.
2. **Fill** the YAML facets (keep only facetable values there).
3. **Write** the body narrative.
4. **Set** `generated` / `verified` trust signals.
5. **Validate** with `pwsh scripts/ReadR.ps1 -Validate` and regenerate the
   index with `-UpdateIndex`.

> Templates live in `_template/` and are the *source of truth* for each note
> type. Existing notes in the library are populated from these templates; when a
> template is revised, existing notes may still carry older fields until they
> are migrated.