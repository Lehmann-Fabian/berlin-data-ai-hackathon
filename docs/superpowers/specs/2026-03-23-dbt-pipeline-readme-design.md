# dbt Pipeline README (CineClaw/OpenClaw) — Design

**Date:** 2026-03-23  
**Owner:** Analytics engineering / hackathon team  
**Target file:** `platforms/dbt/README.md`

## Goal

Create a self-contained, user-friendly `platforms/dbt/README.md` that explains the CineClaw/OpenClaw dbt telemetry pipeline in plain language for both technical and business users.

The README must clearly explain:
- the pipeline stages and how data flows through them
- what “clickouts” mean in this dataset (our watched proxy)
- how bot traffic is handled (kept in staging, filtered out downstream)
- how ranking works, including:
  - daily rankings
  - rolling-window rankings (±14 days)
  - triangular weighting (anchor day counts more)
- which final datasets are intended for Lightdash and for the OpenClaw chatbot

## Audience & Tone

- Mixed audience: analysts, engineers, business stakeholders.
- Minimal jargon; explain key terms once.
- Use concrete examples (e.g., Xmas = Dec 25 anchor date).

## Information Architecture (README sections)

1) **What this dbt project produces**
   - “Clean, tested models from JustWatch telemetry”
   - “Lightdash-ready datasets”
   - “Chatbot-ready recommendation marts”

2) **Key concepts (plain definitions)**
   - Clickout = watched proxy signal
   - Market/locale = `app_locale` (user-selected market)
   - Bot traffic = identified via user-agent classification; filtered out from intermediate onward

3) **Pipeline stages**
   - Sources → Staging (`base_*`) → Intermediate (`int_*`) → Marts (`dim_*`, `fct_*`, `mart_*`) → Semantic layer
   - One or two bullets per stage

4) **Final datasets to use**
   - Daily popularity: `marts.mart_movie_popularity_daily_top50`
   - Rolling popularity (recommended for OpenClaw): `marts.mart_movie_popularity_rolling_29d_top20`
   - Clarify when to use which

5) **How ranking works**
   - Daily rank: per `event_date × app_locale`
   - Rolling rank: per `anchor_date × app_locale × genre_bucket` within ±14 days

6) **Rolling window + triangular weighting**
   - Unweighted vs weighted
   - Triangular: center day counts most, linear decay to edges

7) **Genre buckets**
   - `__all__` (overall, no genre constraint)
   - Single-genre buckets
   - Curated multi-genre buckets (e.g., RomCom)

8) **How OpenClaw queries it (examples)**
   - “Top movies around Xmas” by anchor date + locale
   - Optional genre bucket filter
   - Optional keyword filter (title/description)

9) **Lightdash workflow (short)**
   - `dbt build …` then `lightdash deploy`
   - Point to `platforms/lightdash/setup.md` for step-by-step

10) **Link to the formal spec**
   - `.claude/specs/cineclaw-dbt-pipeline/spec.md`

## Non-goals

- No Lightdash API or chatbot code in this README.
- No deep Snowplow schema reference (link to `data/` docs instead).

## Acceptance Criteria

- A new reader can answer:
  1) “What table should the chatbot query for Xmas recommendations?”
  2) “What does `__all__` mean?”
  3) “Why is Dec 25 weighted more than Dec 24 (if weighted)?”
  4) “Where do bots get filtered out?”
  5) “What’s the difference between daily vs rolling popularity marts?”

