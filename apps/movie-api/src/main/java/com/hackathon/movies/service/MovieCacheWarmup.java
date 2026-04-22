package com.hackathon.movies.service;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.boot.ApplicationArguments;
import org.springframework.boot.ApplicationRunner;
import org.springframework.stereotype.Component;

import java.time.LocalDate;
import java.time.YearMonth;

@Component
public class MovieCacheWarmup implements ApplicationRunner {
    private static final Logger log = LoggerFactory.getLogger(MovieCacheWarmup.class);
    private static final LocalDate START_DATE = LocalDate.of(2026, 1, 1);
    private static final LocalDate END_DATE = LocalDate.of(2026, 12, 31);

    private final MovieQueryService movieQueryService;

    public MovieCacheWarmup(MovieQueryService movieQueryService) {
        this.movieQueryService = movieQueryService;
    }

    @Override
    public void run(ApplicationArguments args) {
        log.info("Warming movie caches for 2026");

        for (LocalDate date = START_DATE; !date.isAfter(END_DATE); date = date.plusDays(1)) {
            movieQueryService.findMovies(date);
            movieQueryService.findPopularMovies(date);
        }

        for (YearMonth month = YearMonth.from(START_DATE); !month.isAfter(YearMonth.from(END_DATE)); month = month.plusMonths(1)) {
            movieQueryService.findRecentMovies(month.atDay(1));
        }

        log.info("Finished warming movie caches for 2026");
    }
}
