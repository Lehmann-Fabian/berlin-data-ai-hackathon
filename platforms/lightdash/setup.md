# Lightdash Setup

## GUI Access

- **URL**: [hackathon.lightdash.cloud](https://hackathon.lightdash.cloud)
- **Login**: you'll receive an email invite — click the link and create your account
- **Project**: your team project (Team 1, Team 2, etc.) is pre-selected based on your group

## Install and authenticate the Lightdash CLI

```bash
# Install
npm install -g @lightdash/cli

# Verify
lightdash --version

# Authenticate
lightdash login https://hackathon.lightdash.cloud --token <YOUR_PERSONAL_ACCESS_TOKEN>
```

To get your personal access token:

1. Log in to [hackathon.lightdash.cloud](https://hackathon.lightdash.cloud)
2. Click your avatar (bottom-left) → **Settings**
3. Go to **Personal Access Tokens** → **Create new token**
4. Copy the token and use it in the command above

## Set your team project

```bash
# List available projects to find your team's project UUID
lightdash config list-projects

# Set your team's project as default
lightdash config set-project --project <PROJECT_UUID>
```

## Deploy dbt models to Lightdash

> **Important:** Each team's Lightdash project is connected to your team's private database (`DB_TEAM_<N>`), **not** the shared database. Your dbt models read from `DB_JW_SHARED.CHALLENGE` but write to your team database — that's where Lightdash looks.

From your dbt project directory:

```bash
# Compile dbt and deploy models to Lightdash
lightdash deploy
```

After deploying, your dbt models appear under **Explore** in the Lightdash UI.

## Adding models and re-deploying

After adding or changing dbt models:

```bash
dbt build --select staging.* intermediate.* marts.*
lightdash deploy
```

## “Xmas movie” recommendations (final product)

Use the daily popularity mart `marts.mart_movie_popularity_daily_top50` to answer:
"What are the top movies in a given time window (e.g. around Xmas)?".

For “around a date” recommendations with a rolling ±14 day window (recommended for the chatbot),
use `marts.mart_movie_popularity_rolling_29d_top20`.

**Suggested Explore setup:**
- Explore: `mart_movie_popularity_daily_top50`
- Filter: `event_date` between your desired dates
- Metric: `clickouts` (sum)
- Dimension: `movie_title`
- Optional breakdown: `app_locale`

**Suggested Explore setup (rolling window, chatbot-ready):**
- Explore: `mart_movie_popularity_rolling_29d_top20`
- Filter: `anchor_date` = your target date (e.g. Dec 25)
- Filter: `genre_bucket` = `__all__` (or a specific genre/bucket like `RomCom`)
- Metric: `weighted_clickouts_29d` (sum)
- Dimension: `movie_title`

**Chart options:**
- Top movies in a window: Table chart sorted by `clickouts`
- Distribution by date: Line chart with `event_date` on X, `clickouts` on Y, series = `movie_title` (limit to top N)

## End-to-end flow

```text
┌─────────────────────────────────────────────────────────────────┐
│  DB_JW_SHARED.CHALLENGE     DB_TEAM_<N>        Lightdash       │
│  (shared, read-only)        (your team DB)     (your project)  │
│                                                                 │
│  T1–T4             ──dbt──▶  staging.base_events_* ──deploy──▶ │
│  OBJECTS/PACKAGES   ──dbt──▶  staging.base_objects/packages     │
│                             intermediate.int_*                 │
│                             marts.dim_*/fct_*/mart_*   Explore │
└─────────────────────────────────────────────────────────────────┘
```

## Resources

- [Lightdash documentation](https://docs.lightdash.com/)
- [Lightdash AI agent documentation](https://docs.lightdash.com/guides/ai-agents)
