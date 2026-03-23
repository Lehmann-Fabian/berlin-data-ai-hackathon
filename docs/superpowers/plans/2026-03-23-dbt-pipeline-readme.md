# dbt Pipeline README (CineClaw/OpenClaw) Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Write a clear, self-contained `platforms/dbt/README.md` that explains the CineClaw/OpenClaw dbt pipeline stages and final recommendation datasets in simple terms.

**Architecture:** Pure documentation change: restructure `platforms/dbt/README.md` to add an overview of stages + ranking logic (daily + rolling weighted window) + bot filtering + “what to query” examples for OpenClaw and Lightdash.

**Tech Stack:** Markdown docs; references to dbt models and marts already implemented in `platforms/dbt/models/`.

---

## File Map (touch points)

**Modify**
- `platforms/dbt/README.md` — add user-friendly, self-contained explanation.

**Reference (do not duplicate; link to where appropriate)**
- `platforms/lightdash/setup.md` — Lightdash deploy workflow + Explore suggestions
- `.claude/specs/cineclaw-dbt-pipeline/spec.md` — pipeline contract and acceptance criteria
- `data/` docs for deeper dataset schema context (events/objects/packages)

---

### Task 1: Draft the new README structure

**Files:**
- Modify: `platforms/dbt/README.md`

- [ ] **Step 1: Add a “What you get” section**
  - Explain outputs: clean facts/dims, popularity marts, semantic models.
  - Mention that these are Lightdash-ready and chatbot-queryable.

- [ ] **Step 2: Add “Key concepts” (plain language)**
  - Define clickouts (watched proxy).
  - Define market/locale (`app_locale`).
  - Explain bot filtering at a high level (staging retains, intermediate+ filters).

- [ ] **Step 3: Add a “Pipeline stages” section**
  - One paragraph + bullets for:
    - Sources → Staging (`base_*`)
    - Intermediate (`int_*`)
    - Marts (`dim_*`, `fct_*`, `mart_*`)
    - Semantic layer (`models/semantics/*.yml`)

---

### Task 2: Explain ranking (daily vs rolling) clearly

**Files:**
- Modify: `platforms/dbt/README.md`

- [ ] **Step 1: Add “Daily popularity” explanation**
  - Dataset: `marts.mart_movie_popularity_daily_top50`
  - Define grain (date × locale × movie).
  - Define `daily_rank` (rank within date+locale).

- [ ] **Step 2: Add “Rolling popularity (recommended for OpenClaw)” explanation**
  - Dataset: `marts.mart_movie_popularity_rolling_29d_top20`
  - Define grain (anchor_date × locale × genre_bucket × movie).
  - Explain ±14 window and that it’s about “around a date”.

- [ ] **Step 3: Explain triangular weighting**
  - Explain that anchor_date counts most, linear decay to window edges.
  - Clarify ranking uses `weighted_clickouts_29d` (and keep `clickouts_29d` as unweighted reference).

---

### Task 3: Explain genre buckets and chatbot usage

**Files:**
- Modify: `platforms/dbt/README.md`

- [ ] **Step 1: Explain `genre_bucket` values**
  - `__all__` = overall popularity (no genre constraint)
  - single-genre buckets
  - curated buckets (e.g., RomCom)

- [ ] **Step 2: Add “OpenClaw query recipes” (copy/paste SQL)**
  - Overall Xmas example (anchor_date=Dec 25, `__all__`)
  - RomCom example (anchor_date, locale, `genre_bucket='RomCom'`)
  - Keyword filter example using `movie_title` / descriptions
  - Each example should fit on a few lines and avoid heavy joins.

---

### Task 4: Lightdash usage and links (keep short)

**Files:**
- Modify: `platforms/dbt/README.md`

- [ ] **Step 1: Add “Lightdash” section**
  - Summarize: run dbt build then `lightdash deploy`.
  - Link to `platforms/lightdash/setup.md`.
  - Mention recommended Explore(s):
    - `mart_movie_popularity_rolling_29d_top20` (chatbot + recommendations)
    - `mart_movie_popularity_daily_top50` (daily trending/time series)

- [ ] **Step 2: Link to the spec**
  - Add a short “Contract/spec” section pointing to `.claude/specs/cineclaw-dbt-pipeline/spec.md`.

---

### Task 5: Verification (docs-only)

**Files:**
- Modify: `platforms/dbt/README.md`

- [ ] **Step 1: Check for correctness against implemented models**
  - Confirm model names match exactly:
    - `marts.mart_movie_popularity_daily_top50`
    - `marts.mart_movie_popularity_rolling_29d_top20`
  - Confirm columns referenced in examples exist (anchor_date, genre_bucket, weighted_clickouts_29d, window_rank, movie_title).

- [ ] **Step 2: Run a link/sanity scan**
  - Run: `rg -n \"\\(.*\\.md\\)\" platforms/dbt/README.md`
  - Expected: Links point to existing docs paths.

---

## Notes / Defaults
- Keep language simple and non-technical where possible; define terms once.
- Prefer examples that use the denormalized marts (no joins).
- Avoid overstating: “clickout = watched proxy” (not confirmed true viewership).

