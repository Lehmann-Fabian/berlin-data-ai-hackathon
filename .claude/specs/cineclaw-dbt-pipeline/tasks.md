# Tasks: cineclaw-dbt-pipeline

## Conventions

- Task IDs: `TASK-001`, `TASK-002`, ...
- Each task MUST state:
  - **Dependencies** (task IDs)
  - **Files** (expected paths)
  - **Covers AC** (e.g. `AC-1, AC-2`)
  - **Done when** checklist
  - **Tests** guidance

## Phase 0: Setup

### TASK-001 - Initialize feature scaffolding
**Dependencies**: -
**Files**:
- `platforms/dbt/dbt_project.yml`
- `.gitignore`
- `.claude/specs/cineclaw-dbt-pipeline/spec.md`
- `.claude/specs/cineclaw-dbt-pipeline/plan.md`
- `.claude/specs/cineclaw-dbt-pipeline/tasks.md`
**Covers AC**: AC-1, AC-2, AC-3, AC-4, AC-5
**Done when**:
- [ ] dbt project config defines per-layer defaults for staging/intermediate/marts
- [ ] dbt local artifacts are gitignored
- [ ] Spec Kit artifacts have filled Requirements + Acceptance Criteria
**Tests**:
- `speckit-analyze --name "cineclaw-dbt-pipeline"`

## Phase 1: Foundation

### TASK-002 - Implement staging contract (typed/extracted)
**Dependencies**: TASK-001
**Files**:
- `platforms/dbt/models/staging/`
**Covers AC**: AC-1
**Done when**:
- [ ] Typed staging models exist for T1–T4 + OBJECTS + PACKAGES (`base_*`)
- [ ] Staging keeps raw `cc_*` columns and extracts commonly-used fields into typed columns
**Tests**:
- `cd platforms/dbt && dbt build --select staging.* --profiles-dir .`

## Phase 2: Core Implementation

### TASK-003 - Implement intermediate facts/dims
**Dependencies**: TASK-002
**Files**:
- `platforms/dbt/models/intermediate/int_fct_clickouts.sql`
- `platforms/dbt/models/intermediate/int_dim_titles.sql`
- `platforms/dbt/models/intermediate/int_dim_providers.sql`
- `platforms/dbt/models/intermediate/int_bridge_title_genres.sql`
**Covers AC**: AC-1, AC-2
**Done when**:
- [ ] `int_fct_clickouts` filters to `se_category='clickout'` and excludes bots
- [ ] `int_dim_titles` and `int_dim_providers` exist
- [ ] `int_bridge_title_genres` exists and supports genre joins
**Tests**:
- `cd platforms/dbt && dbt build --select intermediate.* --profiles-dir .`

### TASK-004 - Implement marts + dataset-period popularity table
**Dependencies**: TASK-003
**Files**:
- `platforms/dbt/models/marts/fct_clickouts.sql`
- `platforms/dbt/models/marts/dim_titles.sql`
- `platforms/dbt/models/marts/dim_providers.sql`
- `platforms/dbt/models/marts/mart_popular_movies_dataset_period.sql`
**Covers AC**: AC-2, AC-3
**Done when**:
- [ ] BI-facing wrappers exist for the intermediate fact/dims
- [ ] `mart_popular_movies_dataset_period` aggregates popularity for movies and exposes dataset coverage fields
**Tests**:
- `cd platforms/dbt && dbt build --select marts.* --profiles-dir .`

## Phase 3: Integration

### TASK-005 - Add semantic layer model
**Dependencies**: TASK-004
**Files**:
- `platforms/dbt/models/semantics/clickouts_semantic.yml`
**Covers AC**: AC-4
**Done when**:
- [ ] Semantic model over `fct_clickouts` exists with measures clickouts/unique_users/unique_sessions
**Tests**:
- `cd platforms/dbt && dbt parse --profiles-dir .`

## Phase 4: Polish

### TASK-006 - Polish: docs, hardening, performance, final verification
**Dependencies**: TASK-005
**Files**:
- `platforms/dbt/models/intermediate/schema.yml`
- `platforms/dbt/models/marts/schema.yml`
**Covers AC**: AC-5
**Done when**:
- [ ] PK, relationship, and accepted-values tests exist and pass
- [ ] Spec Kit analyze passes (AC↔tasks mapping)
**Tests**:
- `speckit-analyze --name "cineclaw-dbt-pipeline"`
- `cd platforms/dbt && dbt build --select staging.* intermediate.* marts.* --profiles-dir .`
