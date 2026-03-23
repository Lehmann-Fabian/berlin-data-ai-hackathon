# Movie App Stack

## Docker

1. Copy the example env file:

```bash
cp .env.docker.example .env
```

2. Fill in your Snowflake credentials in `.env`.

3. Start both services:

```bash
docker compose up --build
```

Frontend:

```text
http://localhost:5173
```

Backend API:

```text
http://localhost:8080/api/movies?date=2026-03-23
```

## Backend

Location: `apps/movie-api`

Run with Maven:

```bash
cd apps/movie-api
mvn spring-boot:run
```

Snowflake credentials are currently left open through environment-variable placeholders in:

- `apps/movie-api/src/main/resources/application.yml`

## Frontend

Location: `apps/movie-web`

Run with Vite:

```bash
cd apps/movie-web
npm install
npm run dev
```

Open:

```text
http://localhost:5173
```

## Flow

1. Pick a date in the React app.
2. React calls the Spring Boot API.
3. Spring Boot sends the selected date into `find_movies.sql`.
4. Snowflake returns the matching movies.
5. The API returns JSON with the movie list.
6. React renders posters, titles, IMDb scores, hover descriptions, and IMDb links.
