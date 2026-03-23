---
name: movie_recommender
description: Use predefined movie recommendation and discovery demo queries for movie questions
user-invocable: true
---

Use this skill when the user asks for:
- movie recommendations
- family movie night suggestions
- recommendations by genre
- recommendations by mood
- similar movies
- personalized recommendations
- trending or popular movies
- seasonal or holiday movie picks
- movie search
- movie details
- provider popularity

This skill must only use the predefined query IDs below.
Never invent SQL.
Never build custom SQL.
Always call the local script and summarize its JSON output.

## Available query IDs and when to use them

### family_movie_night
Use for:
- "recommend a family movie"
- "movie night with kids"
- "family-friendly movie picks"
- "good family movies"

### recommendations_by_genre
Use for:
- "recommend comedy movies"
- "best action movies"
- "good romcoms"
- "top horror movies"

### recommendations_by_mood
Use for:
- "I want something romantic"
- "recommend something funny"
- "I want a scary movie"
- "give me something cozy"
- "I want a thriller"

### similar_movies
Use for:
- "recommend movies like Dune"
- "what is similar to Interstellar"
- "more movies like The Dark Knight"

Note:
This is demo data and already uses a baked-in source movie.

### personalized_recommendations
Use for:
- "what should I watch"
- "recommend movies for me"
- "personalized movie picks"

Note:
This is demo data and already uses a baked-in demo user.

### top_movies_seasonal_across_years
Use for:
- "top Christmas movies"
- "best Halloween movies"
- "popular Valentine's movies"
- "seasonal top movies"

### top_movies_around_date
Use for:
- "top movies around Christmas"
- "popular movies around a specific date"
- "best movies around New Year's"

### top_movies_around_date_by_keyword
Use for:
- "best Christmas family movies"
- "popular vampire movies around Halloween"
- "top romance movies around Valentine's"

Note:
This is based on a baked-in keyword match.

### daily_trending_movies
Use for:
- "what's trending today"
- "daily trending movies"
- "top movies right now"

### seasonal_window_recommendations_for_date
Use for:
- "what should I watch around Christmas"
- "recommend something for this time of year"
- "seasonal movie picks"

Note:
This uses a baked-in demo date.

### movie_details_by_object_id
Use for:
- "show me movie details"
- "get the description and links for the movie"
- "tell me more about this movie"

Note:
This returns details for the baked-in demo source movie.

### search_movies_by_keyword
Use for:
- "find a movie"
- "search for a movie"
- "search movies by keyword"

Note:
This uses a baked-in keyword search.

### top_movies_in_date_range
Use for:
- "top movies in a period"
- "most popular movies in a date range"
- "top movies in a recent window"

Note:
This uses a baked-in date range.

### top_providers_in_date_window
Use for:
- "top streaming providers"
- "where are people watching movies"
- "most popular providers in a time window"

Note:
This uses a baked-in date window.

## Decision guide

Use:
- `family_movie_night` for family-friendly picks
- `recommendations_by_genre` for genre requests
- `recommendations_by_mood` for mood requests
- `similar_movies` for "movies like X"
- `personalized_recommendations` for personalized demo recommendations
- `top_movies_seasonal_across_years` for recurring seasonal / holiday requests
- `top_movies_around_date` for date-based popularity
- `top_movies_around_date_by_keyword` for date-based requests with a topic or keyword angle
- `daily_trending_movies` for trending requests
- `seasonal_window_recommendations_for_date` for curated seasonal picks
- `movie_details_by_object_id` for detail lookup
- `search_movies_by_keyword` for search requests
- `top_movies_in_date_range` for aggregate popularity in a period
- `top_providers_in_date_window` for provider popularity

## Execution format

When using the script, run exactly this pattern:

{baseDir}/.venv/bin/python {baseDir}/run_query.py <<'EOF'
{
"query_id": "<chosen_query_id>",
"params": {},
"max_rows": 10
}
EOF

## Output behavior

After the script returns:
- summarize the result clearly
- explain briefly what kind of recommendation or ranking was used
- mention useful movie fields such as title, year, genre, score, poster, IMDb URL, and TMDb URL when available
- do not claim the results are personalized unless the chosen query is `personalized_recommendations`
- if no predefined query matches the question, say so clearly rather than inventing SQL