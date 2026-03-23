import { useEffect, useMemo, useState } from 'react';

const API_BASE_URL =
  import.meta.env.VITE_API_BASE_URL ||
  `${window.location.protocol}//${window.location.hostname}:8080`;
const FALLBACK_POSTER = 'https://placehold.co/600x900/1d2733/f4efe4?text=No+Poster';

function formatScore(score) {
  if (score === null || score === undefined || score === '') {
    return 'N/A';
  }
  const numericScore = Number(score);
  return Number.isNaN(numericScore) ? String(score) : numericScore.toFixed(1);
}

function formatRuntime(runtime) {
  if (runtime === null || runtime === undefined || runtime === '') {
    return null;
  }
  const numericRuntime = Number(runtime);
  if (Number.isNaN(numericRuntime)) {
    return String(runtime);
  }
  return `${numericRuntime} min`;
}

function formatGermanDate(dateString) {
  if (!dateString) {
    return '';
  }
  const [year, month, day] = dateString.split('-');
  if (!year || !month || !day) {
    return dateString;
  }
  return `${day}.${month}.${year}`;
}

function formatDayMonth(dateString) {
  if (!dateString) {
    return '';
  }
  const [year, month, day] = dateString.split('-');
  if (!year || !month || !day) {
    return dateString;
  }
  return `${day}.${month}.`;
}

function getMovieTitle(movie) {
  return movie.title || movie.movie_title || movie.translated_title || movie.original_title || 'Untitled movie';
}

function getMovieDescription(movie) {
  return movie.short_description || movie.object_text_short_description || 'No description available.';
}

function MovieSection({ title, subtitle, movies, emptyCopy }) {
  return (
    <section className="content-section">
      <div className="section-heading">
        <h2>{title}</h2>
        {subtitle ? <p>{subtitle}</p> : null}
      </div>

      {movies.length === 0 ? (
        <div className="empty-state compact-empty">
          <p>Nothing here yet.</p>
          <span>{emptyCopy}</span>
        </div>
      ) : (
        <div className="movie-grid">
          {movies.map((movie) => (
            <a
              key={movie.object_id || movie.rolling_popularity_id}
              className="movie-card"
              href={movie.url_imdb || '#'}
              target="_blank"
              rel="noreferrer"
              title={getMovieTitle(movie)}
              onClick={(event) => {
                if (!movie.url_imdb) {
                  event.preventDefault();
                }
              }}
            >
              <img
                src={movie.poster_jw || FALLBACK_POSTER}
                alt={getMovieTitle(movie)}
                loading="lazy"
              />
              <div className="movie-meta">
                <h3>{getMovieTitle(movie)}</h3>
                <p>
                  IMDb {formatScore(movie.imdb_score)}
                  {formatRuntime(movie.runtime) ? ` • ${formatRuntime(movie.runtime)}` : ''}
                </p>
              </div>
              <div className="movie-hover">
                <p>{getMovieDescription(movie)}</p>
              </div>
            </a>
          ))}
        </div>
      )}
    </section>
  );
}

export default function App() {
  const today = useMemo(() => new Date().toISOString().slice(0, 10), []);
  const [selectedDate, setSelectedDate] = useState(today);
  const [discoveryMovies, setDiscoveryMovies] = useState([]);
  const [popularMovies, setPopularMovies] = useState([]);
  const [recentMovies, setRecentMovies] = useState([]);
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState('');
  const [lastLoadedDate, setLastLoadedDate] = useState('');

  async function loadMovies(date) {
    setLoading(true);
    setError('');

    try {
      const [discoveryResponse, popularResponse, recentResponse] = await Promise.all([
        fetch(`${API_BASE_URL}/api/movies?date=${date}`),
        fetch(`${API_BASE_URL}/api/movies/popular?date=${date}`),
        fetch(`${API_BASE_URL}/api/movies/recent?date=${date}`)
      ]);

      if (!discoveryResponse.ok) {
        throw new Error(`Discovery request failed with status ${discoveryResponse.status}`);
      }
      if (!popularResponse.ok) {
        throw new Error(`Popularity request failed with status ${popularResponse.status}`);
      }
      if (!recentResponse.ok) {
        throw new Error(`Recent movies request failed with status ${recentResponse.status}`);
      }

      const [discoveryPayload, popularPayload, recentPayload] = await Promise.all([
        discoveryResponse.json(),
        popularResponse.json(),
        recentResponse.json()
      ]);

      setDiscoveryMovies(Array.isArray(discoveryPayload.movies) ? discoveryPayload.movies : []);
      setPopularMovies(Array.isArray(popularPayload.movies) ? popularPayload.movies : []);
      setRecentMovies(Array.isArray(recentPayload.movies) ? recentPayload.movies : []);
      setLastLoadedDate(
        discoveryPayload.requestedDate || popularPayload.requestedDate || recentPayload.requestedDate || date
      );
    } catch (requestError) {
      setDiscoveryMovies([]);
      setPopularMovies([]);
      setRecentMovies([]);
      setLastLoadedDate('');
      setError(requestError.message || 'Something went wrong while fetching movies.');
    } finally {
      setLoading(false);
    }
  }

  async function handleSubmit(event) {
    event.preventDefault();
    await loadMovies(selectedDate);
  }

  useEffect(() => {
    loadMovies(today);
  }, [today]);

  const formattedDate = formatGermanDate(lastLoadedDate || selectedDate);
  const formattedDayMonth = formatDayMonth(lastLoadedDate || selectedDate);

  return (
    <main className="page-shell">
      <section className="hero-panel">
        <p className="eyebrow">Seasonal Recommender</p>
        <h1>Pick a date, then browse the best-matching movies for that moment.</h1>

        <form className="date-form" onSubmit={handleSubmit}>
          <label htmlFor="movie-date">Date</label>
          <div className="form-row">
            <input
              id="movie-date"
              className="date-picker"
              type="date"
              value={selectedDate}
              onChange={(event) => setSelectedDate(event.target.value)}
              min="2026-01-01"
              max="2026-12-31"
              required
            />
            <button type="submit" disabled={loading}>
              {loading ? 'Loading...' : 'Find Movies'}
            </button>
          </div>
        </form>
        {error ? <p className="error-copy">{error}</p> : null}
      </section>

      <section className="results-panel">
        {discoveryMovies.length === 0 && popularMovies.length === 0 && recentMovies.length === 0 && !loading ? (
          <div className="empty-state">
            <p>No movies loaded yet.</p>
            <span>Choose a date and we will fill this page with ideas for what to watch.</span>
          </div>
        ) : (
          <div className="sections-stack">
            <MovieSection
              title="Newly published movies"
              subtitle="Top 10 newer releases for the month of your selected date, using the first day of that month as the lookup anchor."
              movies={recentMovies}
              emptyCopy="We have no newly published movie data for this month."
            />
            <MovieSection
              title={`What people watch usually around ${formattedDayMonth}`}
              subtitle="The most popular movie picks in Germany around this date based on rolling watch behavior."
              movies={popularMovies}
              emptyCopy="We have no data for this date in the database."
            />
            <MovieSection
              title="Movies you might not know"
              subtitle="A curated pick of titles that best match the mood and themes around your selected date."
              movies={discoveryMovies}
              emptyCopy="No discovery picks were found for this date."
            />
          </div>
        )}
      </section>
    </main>
  );
}
