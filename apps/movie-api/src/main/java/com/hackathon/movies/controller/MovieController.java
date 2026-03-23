package com.hackathon.movies.controller;

import com.hackathon.movies.model.MovieResponse;
import com.hackathon.movies.service.MovieQueryService;
import org.springframework.format.annotation.DateTimeFormat;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import java.time.LocalDate;

@RestController
@RequestMapping("/api/movies")
public class MovieController {

    private final MovieQueryService movieQueryService;

    public MovieController(MovieQueryService movieQueryService) {
        this.movieQueryService = movieQueryService;
    }

    @GetMapping
    public MovieResponse findMovies(
            @RequestParam("date")
            @DateTimeFormat(iso = DateTimeFormat.ISO.DATE)
            LocalDate date
    ) {
        return movieQueryService.findMovies(date);
    }

    @GetMapping("/popular")
    public MovieResponse findPopularMovies(
            @RequestParam("date")
            @DateTimeFormat(iso = DateTimeFormat.ISO.DATE)
            LocalDate date
    ) {
        return movieQueryService.findPopularMovies(date);
    }

    @GetMapping("/recent")
    public MovieResponse findRecentMovies(
            @RequestParam("date")
            @DateTimeFormat(iso = DateTimeFormat.ISO.DATE)
            LocalDate date
    ) {
        return movieQueryService.findRecentMovies(date);
    }
}
