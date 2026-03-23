# dbt (CineClaw / OpenClaw telemetry pipeline)

[dbt](https://www.getdbt.com/) transforms raw JustWatch telemetry in Snowflake into clean, tested datasets you can:
- explore in **Lightdash**
- query from an **OpenClaw chatbot** to recommend movies (e.g. “top Xmas movies in DE”)

This README explains the pipeline stages and the two main “popularity” outputs in simple terms.

## Quick start

1. Create a dbt profile — see `platforms/dbt/profiles.md`
2. From this directory, verify your connection:

```bash
dbt debug
```

3. Build the pipeline models:

```bash
dbt build --select staging.* intermediate.* marts.*
```

4. Deploy to Lightdash:
   - follow `platforms/lightdash/setup.md`

## What data are we working with?

The shared dataset lives in Snowflake under `DB_JW_SHARED.CHALLENGE`:
- `T1–T4` — event tables (user interactions)
- `OBJECTS` — movie/show metadata (titles, descriptions, poster URL, etc.)
- `PACKAGES` — streaming provider lookup (Netflix, Prime Video, …)

dbt reads from these shared tables and writes the transformed models into your team database (`DB_TEAM_<N>`).

## Key concepts (plain language)

### What is a “clickout”?

A **clickout** is a user action where someone clicks through to a provider offer (e.g., “watch on Netflix”, “rent on Apple TV”).

In this pipeline we use **clickouts as a “watched proxy”**: it’s not guaranteed viewership, but it is a strong signal of intent.

### What is the “market / locale”?

We use `app_locale` as the **user-selected market** (for example `DE`, `TR`, etc.). This can differ from the user’s physical location (`geo_country`).

### How do we handle bots?

We keep bot rows in **staging** (so we don’t lose raw context), but filter bots out in **intermediate** and everything downstream:
- staging: contains `is_bot`
- intermediate + marts: use `where not is_bot`

That means the final “popularity” tables represent **human clickouts** only.

## Pipeline stages (what each layer does)

### 1) Sources

We register the shared tables and their column meanings in:
- `platforms/dbt/models/staging/sources.yml`

### 2) Staging (`models/staging/base_*`)

Staging models “clean up the raw tables”:
- type-cast columns (dates, ids, numbers)
- extract common fields from JSON context columns
- keep enough raw context so we can debug later

Examples:
- `staging.base_events_t1` (and T2–T4)
- `staging.base_objects`
- `staging.base_packages`

### 3) Intermediate (`models/intermediate/int_*`)

Intermediate models create reusable building blocks:
- `int_fct_clickouts` — the core clickout fact (human-only)
- `int_dim_titles` / `int_dim_providers` — reusable dimensions
- bridges like `int_bridge_title_genres` (title → genre)

### 4) Marts (`models/marts/*`)

Marts are the **BI/chatbot-facing contracts**:
- `dim_*` and `fct_*` are stable names for BI tools
- `mart_*` are curated “final products” (popularity tables)

### 5) Semantic layer (`models/semantics/*.yml`)

Semantic YAML makes metrics/dimensions easier to consume for BI tools that support dbt’s semantic layer.

## Final datasets (what to query)

### A) Daily popularity (trending-by-day)

Model: `marts.mart_movie_popularity_daily_top50`

Use this when you care about **what was popular on a specific day**.

How it ranks:
- `daily_rank` is computed **within** each `(event_date, app_locale)`
- the rank is driven by daily clickout count (`clickouts`)

### B) Rolling popularity (recommended for OpenClaw)

Model: `marts.mart_movie_popularity_rolling_29d_top20`

Use this when you want “popular around a date” recommendations (e.g. around Xmas).

How it ranks:
- choose an `anchor_date` (the “center date”)
- look at a rolling window: **two weeks before + two weeks after** (±14 days)
- rank movies **within** `(anchor_date, app_locale, genre_bucket)`

#### Rolling window vs weighting (why Dec 25 can matter more)

This mart includes two scores:
- `clickouts_29d`: unweighted sum of clickouts within the ±14-day window
- `weighted_clickouts_29d`: **triangular weighted** sum where the anchor day counts most and days further away count less

Ranking uses `weighted_clickouts_29d` first (then `clickouts_29d` as a tie-breaker).

#### What is `genre_bucket`?

`genre_bucket` lets you rank “overall” or “within a genre / bucket”:
- `__all__`: no genre constraint (overall popularity)
- single-genre buckets like `Comedy`
- curated multi-genre buckets like `RomCom` (Romance + Comedy)

## OpenClaw chatbot: query recipes (copy/paste)

Below are examples against the rolling mart (recommended for recommendations).

### 1) Top movies around Xmas (overall)

```sql
select
  movie_title,
  weighted_clickouts_29d,
  poster_jw,
  url_imdb,
  url_tmdb
from marts.mart_movie_popularity_rolling_29d_top20
where app_locale = :app_locale
  and anchor_date = :anchor_date
  and genre_bucket = '__all__'
order by window_rank
limit 10;
```

### 2) Top RomCom movies around Xmas

```sql
select movie_title, weighted_clickouts_29d
from marts.mart_movie_popularity_rolling_29d_top20
where app_locale = :app_locale
  and anchor_date = :anchor_date
  and genre_bucket = 'RomCom'
order by window_rank
limit 10;
```

### 3) Keyword filter (simple approach)

```sql
select movie_title, weighted_clickouts_29d
from marts.mart_movie_popularity_rolling_29d_top20
where app_locale = :app_locale
  and anchor_date = :anchor_date
  and genre_bucket = '__all__'
  and (
    movie_title ilike '%' || :keyword || '%'
    or short_description ilike '%' || :keyword || '%'
    or object_text_short_description ilike '%' || :keyword || '%'
  )
order by weighted_clickouts_29d desc
limit 10;
```

## Lightdash (how to publish the final product)

Lightdash reads models from your team database and exposes them under **Explore** after you run:

```bash
lightdash deploy
```

Recommended Explores:
- `mart_movie_popularity_rolling_29d_top20` (chatbot + “around a date” recommendations)
- `mart_movie_popularity_daily_top50` (daily trending and time-series)

See `platforms/lightdash/setup.md` for setup and deployment steps.

## Formal spec (pipeline contract)

The pipeline spec and acceptance criteria live in:
- `.claude/specs/cineclaw-dbt-pipeline/spec.md`

## AI-assisted dbt development (optional)

This repo includes dbt agent skills (from `dbt-labs/dbt-agent-skills`) that help AI coding assistants work with dbt:

| Skill | What it does |
| ----- | ------------ |
| `using-dbt-for-analytics-engineering` | Builds/modifies dbt models, writes SQL with `ref()`/`source()`, validates with `dbt show` |
| `running-dbt-commands` | Formats and runs dbt CLI commands correctly |
| `adding-dbt-unit-test` | Creates unit test YAML definitions to validate model logic |
| `answering-natural-language-questions-with-dbt` | Translates business questions into SQL queries against your models |
