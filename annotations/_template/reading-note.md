---
type: Reading Note
paper-entry: "[[Entry Title]]"     # wiki-link to the paper entry
generated: human                  # human | ai | agent
verified: unverified              # unverified | machine-confirmed | human-reviewed
created: YYYY-MM-DD
updated: YYYY-MM-DD
---

# Reading Note: Paper Title

> **Title:** Paper Title
> **Venue:** Conference / Journal (Year)
> **Link:** URL

> **AI / Human division of labor**
> - **AI (skeleton):** Sections 1–4 — metadata, research background, core method, experimental results, discussion & analysis. Formulas included; figures and tables are placeholders only.
> - **Human (content):** All actual figures, tables, and formulas, plus Section 5 "Personal Evaluation & Reflection".
> - Figure → `![Figure X: caption](attachments/fig-XX.png)` + interpretation
> - Table → rewrite as a Markdown table or cite the original table number + analysis
> - Formula → explain symbols, derivation logic, and purpose

## Summary

Summarize the paper's core content, main method, and key findings in your own words (1 paragraph).

## Research Background & Motivation

- Why did the authors do this research? (existing problems, challenges, research gaps)
- What core problem is this research trying to solve?

## Core Method

### Method Overview

Briefly introduce the overall method or framework proposed.

- **Architecture Diagram:** Insert the paper's model/framework figure and explain each module's function and data flow.
  > ![Model Architecture](attachments/fig-01.png)

### Method Details

- **Key Components:** Describe each module or step in the method in detail.
- **Technical Details:** Explain the specific techniques, models, and algorithms used.
- **Innovations:** How does this method differ from or improve on existing approaches?
- **Formula Explanation:** List important formulas, explain each symbol, the derivation logic, and the purpose.
  > \[
  > \mathcal{L} = -\sum_{i} \log P(y_i \mid x_i)
  > \]

## Experiments & Results

1. **Experimental Setup**
   - **Datasets:** Which datasets were used? What are their characteristics?
   - **Baselines:** Which existing methods were compared against?
   - **Metrics:** Which metrics were used to measure performance?
2. **Main Results**
   - What key findings did the authors obtain experimentally?
   - How do these results support the authors' claims?
   - **Key Figure/Table Interpretation:** Insert and explain core result figures.
3. **Ablation / Parameter Analysis**
   - Did the authors analyze different components or parameters?
   - What do these analyses reveal?

## Discussion & Analysis

- **Main Contributions:** Summarize the key contributions to the field.
- **Innovation Summary:** Reiterate the methodological innovations.
- **Strengths:** What are the notable advantages?
- **Limitations:** What limitations did the authors acknowledge, and any you perceive?
- **Future Work:** What future directions did the authors propose?

## Personal Evaluation & Reflection (Human Required)

> **AI note:** This section must be filled by humans. AI provides only guiding questions below.

1. **Personal Understanding:** What is your deepest takeaway from this paper?
2. **Inspiration:** What impact on your own research?
3. **Questions:** What remains unanswered?
4. **Improvements:** If you were the author, what would you do differently?