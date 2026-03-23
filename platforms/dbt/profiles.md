# dbt Configuration

## Install dbt

```bash
pip install dbt-snowflake
```

## Create your dbt profile

dbt needs a `profiles.yml` to connect to Snowflake. Create one at `~/.dbt/profiles.yml`:

```yaml
db_team_<N>:
  outputs:
    dev:
      type: snowflake
      account: "<ACCOUNT_ID>"
      user: "<your-email>"
      password: "<your-password>"
      database: DB_TEAM_<N>          # ← your team's private database (e.g. DB_TEAM_1)
      schema: base                  # default schema; models override to staging/intermediate/marts
      warehouse: WH_TEAM_<N>_XS     # ← your team's warehouse (e.g. WH_TEAM_1_XS)
      threads: 4
  target: dev
```

Replace `<ACCOUNT_ID>`, your credentials, and `<N>` with your team number. The `database` must be your team database — this is where dbt will create schemas/views/tables that Lightdash can read.

## Verify connection

```bash
cd my-dbt-project
dbt debug
```

## Build base models

```bash
dbt build --select staging.* intermediate.* marts.*
```

After `dbt build`, you should see relations like `DB_TEAM_<N>.STAGING.BASE_EVENTS_T1`, `DB_TEAM_<N>.INTERMEDIATE.INT_FCT_CLICKOUTS`, and `DB_TEAM_<N>.MARTS.MART_POPULAR_MOVIES_DATASET_PERIOD` in Snowflake (schema names are configured in `platforms/dbt/dbt_project.yml`).
