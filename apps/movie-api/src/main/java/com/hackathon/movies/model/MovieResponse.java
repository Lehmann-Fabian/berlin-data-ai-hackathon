package com.hackathon.movies.model;

import java.time.LocalDate;
import java.util.List;
import java.util.Map;

public record MovieResponse(
        LocalDate requestedDate,
        int count,
        List<Map<String, Object>> movies
) {
}
