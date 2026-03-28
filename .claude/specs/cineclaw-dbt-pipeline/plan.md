# Implementation Plan: cineclaw-dbt-pipeline

## Inputs

- Spec: `spec.md`

## Phases

### Phase 0: Setup

- Align dbt project configuration (`platforms/dbt/dbt_project.yml`) so model configs apply per layer (staging/intermediate/marts).
- Ensure dbt artifacts are ignored (dbt `target/`, `dbt_packages/`, local `.user.yml`).
- Generate Spec Kit artifacts (this folder) and keep AC↔tasks mapping consistent.

### Phase 1: Foundation

- Staging layer contract:
  - Typed staging models for T1–T4 + OBJECTS + PACKAGES.
  - Extract commonly-used `cc_*` fields to first-class columns while preserving the raw variants.

### Phase 2: Core Implementation

- Intermediate layer:
  - `int_fct_clickouts` derived from staging, filtered to clickouts and human traffic.
  - `int_dim_titles`, `int_dim_providers` dimensions.
  - `int_bridge_title_genres` for genre filtering.

### Phase 3: Integration

- Marts:
  - Stable fact/dim wrappers (`fct_clickouts`, `dim_titles`, `dim_providers`).
  - `mart_popular_movies_dataset_period` as dbt-refreshed table with dataset coverage fields.
- Semantic layer:
  - `semantic_models` definition over `fct_clickouts` for Lightdash/ad-hoc consumption.

### Phase 4: Polish

- Add/verify dbt tests (PK, relationships, accepted-values).
- Verification commands (run locally where dbt is installed):
  - `cd platforms/dbt`
  - `dbt build --select staging.* intermediate.* marts.* --profiles-dir .`
  - Optional scaling: `dbt build --select int_fct_clickouts marts.mart_popular_movies_dataset_period --vars '{"events_model":"base_events_t4"}' --profiles-dir .`

## Requirements Summary (from spec)

- - [ ] R1: Typed staging models with extracted fields.
- - [ ] R2: Intermediate clickout fact + dims + genre bridge with bot filtering.
- - [ ] R3: Marts + dataset-period popularity table.
- - [ ] R4: Semantic model for clickouts.
- - [ ] R5: Tests for keys/relationships/accepted-values.

## Risks & Tradeoffs

- Semantic layer YAML syntax may differ by dbt version; validate via `dbt parse` / `dbt build` in the target environment.
- Popularity mart cost scales with event table size; default to T1 for iteration and explicitly override to T4 when needed.

## Verification Checkpoints

- [ ] `dbt parse` succeeds for the project
- [ ] `dbt build --select staging.* intermediate.* marts.*` succeeds
- [ ] AC↔tasks mapping is consistent (Spec Kit analyze passes)
