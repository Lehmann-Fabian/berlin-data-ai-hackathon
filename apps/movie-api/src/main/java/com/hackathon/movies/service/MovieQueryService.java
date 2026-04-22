package com.hackathon.movies.service;

import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.hackathon.movies.model.MovieResponse;
import org.springframework.core.io.ClassPathResource;
import org.springframework.cache.annotation.Cacheable;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Service;

import java.io.IOException;
import java.io.InputStream;
import java.nio.charset.StandardCharsets;
import java.sql.Array;
import java.sql.Date;
import java.sql.ResultSet;
import java.sql.ResultSetMetaData;
import java.sql.SQLException;
import java.time.LocalDate;
import java.time.format.DateTimeFormatter;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

@Service
public class MovieQueryService {
    private static final DateTimeFormatter DAY_MONTH_FORMATTER = DateTimeFormatter.ofPattern("dd.MM");

    private final JdbcTemplate jdbcTemplate;
    private final ObjectMapper objectMapper;
    private final String findMoviesSql;
    private final String popularMoviesSql;
    private final String recentMoviesSql;

    public MovieQueryService(JdbcTemplate jdbcTemplate, ObjectMapper objectMapper) throws IOException {
        this.jdbcTemplate = jdbcTemplate;
        this.objectMapper = objectMapper;
        this.findMoviesSql = readSql("sql/find_movies.sql");
        this.popularMoviesSql = readSql("sql/popular_movies.sql");
        this.recentMoviesSql = readSql("sql/recent_movies.sql");
    }

    @Cacheable(cacheNames = "findMoviesByDate", key = "#date")
    public MovieResponse findMovies(LocalDate date) {
        List<Map<String, Object>> movies = runDateQuery(findMoviesSql, date);
        return new MovieResponse(date, movies.size(), movies);
    }

    @Cacheable(cacheNames = "popularMoviesByDate", key = "#date")
    public MovieResponse findPopularMovies(LocalDate date) {
        List<Map<String, Object>> movies = runDayMonthQuery(popularMoviesSql, date);
        return new MovieResponse(date, movies.size(), movies);
    }

    @Cacheable(cacheNames = "recentMoviesByDate", key = "#date")
    public MovieResponse findRecentMovies(LocalDate date) {
        List<Map<String, Object>> movies = runDateQuery(recentMoviesSql, date);
        return new MovieResponse(date, movies.size(), movies);
    }

    private List<Map<String, Object>> runDateQuery(String sql, LocalDate date) {
        return jdbcTemplate.query(
            connection -> {
                var statement = connection.prepareStatement(sql);
                statement.setDate(1, Date.valueOf(date));
                return statement;
            },
            (resultSet, rowNum) -> mapRow(resultSet)
        );
    }

    private List<Map<String, Object>> runDayMonthQuery(String sql, LocalDate date) {
        return jdbcTemplate.query(
            connection -> {
                var statement = connection.prepareStatement(sql);
                statement.setString(1, date.format(DAY_MONTH_FORMATTER));
                return statement;
            },
            (resultSet, rowNum) -> mapRow(resultSet)
        );
    }

    private String readSql(String path) throws IOException {
        try (InputStream inputStream = new ClassPathResource(path).getInputStream()) {
            return new String(inputStream.readAllBytes(), StandardCharsets.UTF_8);
        }
    }

    private Map<String, Object> mapRow(ResultSet resultSet) throws SQLException {
        ResultSetMetaData metaData = resultSet.getMetaData();
        Map<String, Object> row = new LinkedHashMap<>();

        for (int i = 1; i <= metaData.getColumnCount(); i++) {
            String key = metaData.getColumnLabel(i).toLowerCase();
            Object value = resultSet.getObject(i);
            row.put(key, normalizeValue(value));
        }

        return row;
    }

    private Object normalizeValue(Object value) {
        if (value == null) {
            return null;
        }
        if (value instanceof Date date) {
            return date.toLocalDate().toString();
        }
        if (value instanceof Array sqlArray) {
            try {
                Object arrayValue = sqlArray.getArray();
                if (arrayValue instanceof Object[] objects) {
                    return Arrays.asList(objects);
                }
                return arrayValue;
            } catch (SQLException exception) {
                return null;
            }
        }
        if (value instanceof String text) {
            String trimmed = text.trim();
            if ((trimmed.startsWith("[") && trimmed.endsWith("]"))
                    || (trimmed.startsWith("{") && trimmed.endsWith("}"))) {
                try {
                    return objectMapper.readValue(trimmed, Object.class);
                } catch (JsonProcessingException ignored) {
                    return text;
                }
            }
            return text;
        }
        if (value instanceof Iterable<?> iterable) {
            List<Object> items = new ArrayList<>();
            for (Object item : iterable) {
                items.add(item);
            }
            return items;
        }
        return value;
    }
}
