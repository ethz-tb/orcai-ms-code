library(tidyverse)
library(here)
library(glue)
library(jsonlite)
library(ivs)

plot_overlaps <- function(start, stop) {
    intervals <- iv(start, stop)
    locations <- iv_locate_overlaps(intervals, intervals)
    overlaps_plot <- get_overlaps(intervals, locations) |>
        group_by(id, direction) |>
        mutate(
            y = id + seq_len(n()) * direction * 0.05
        ) |>
        transmute(
            y,
            label = str_c(id, overlaps_with, sep = "-"),
            start = iv_start(overlap_iv),
            stop = iv_end(overlap_iv)
        )

    ggplot(
        data = overlaps_plot,
        mapping = aes(x = start, xend = stop, y = y, color = as.character(direction))
    ) +
        geom_segment(linewidth = 2) +
        geom_text(
            data = filter(overlaps_plot, direction != 0),
            mapping = aes(
                x = (start + stop) / 2,
                hjust = 0.5, vjust = 0.5, label = label
            ),
            color = "black"
        ) +
        scale_y_reverse(breaks = test_set$id, minor_breaks = NULL) +
        scale_x_continuous(breaks = seq_len(max(test_set$stop)), minor_breaks = NULL) +
        scale_colour_manual(values = c("-1" = "blue", "0" = "black", "1" = "orange"), name = "", guide = "none") +
        theme_bw()
}

get_overlaps <- function(intervals, locations) {
    locations_ranges <- iv_align(intervals, intervals, locations = locations)
    overlaps <- locations |>
        ungroup() |>
        rename(id = needles, overlaps_with = haystack) |>
        mutate(
            id_iv = locations_ranges$needles,
            overlaps_with_iv = locations_ranges$haystack,
            overlap_iv = iv_pairwise_set_intersect(id_iv, overlaps_with_iv),
            duration = iv_end(overlap_iv) - iv_start(overlap_iv),
            direction = case_when(
                id == overlaps_with ~ 0,
                id < overlaps_with ~ 1,
                id > overlaps_with ~ -1,
            )
        )
    return(overlaps)
}

call_overlap_duration <- function(overlap_ivs) {
    if (length(overlap_ivs) == 0) {
        return(0)
    }
    regions_with_overlap <- overlap_ivs |>
        iv_groups()
    total_overlap_length <- sum(sapply(regions_with_overlap, \(x) iv_end(x) - iv_start(x)))

    return(total_overlap_length)
}

recording_overlap_duration <- function(start, stop) {
    intervals <- iv(start, stop)
    locations <- iv_locate_overlaps(intervals, intervals)
    overlaps <- get_overlaps(intervals, locations) |>
        filter(direction == 1)
    if (dim(overlaps)[1] == 0) {
        overlap_duration <- 0
    } else {
        regions_with_overlap <- overlaps$overlap_iv |>
            iv_groups()
        overlap_duration <- sum(sapply(regions_with_overlap, \(x) iv_end(x) - iv_start(x)))
    }
    return(overlap_duration)
}

count_overlaps <- function(start, stop) {
    intervals <- iv(start, stop)
    locations <- iv_locate_overlaps(intervals, intervals)
    overlaps <- get_overlaps(intervals, locations)

    total_overlap_duration <- overlaps |>
        filter(direction != 0) |>
        group_by(id) |>
        summarize(
            duration_with_overlap = call_overlap_duration(overlap_iv),
            sum_overlaps = sum(duration)
        )

    locations_sum_1 <- locations |>
        group_by(needles) |>
        summarize(
            overlaps_with_list = list(haystack[haystack != needles]),
            overlaps_with_n = lengths(overlaps_with_list)
        ) |>
        mutate(overlaps_with = map_chr(overlaps_with_list, \(x) str_c(x, collapse = ", ")))
    locations_sum <- left_join(locations_sum_1, total_overlap_duration, by = join_by(needles == id)) |>
        select(-needles) |>
        replace_na(list(duration_with_overlap = 0, sum_overlaps = 0))
    return(locations_sum)
}

start <- c(1, 2, 4, 6, 7, 7, 12)
stop <- c(3, 5, 8, 10, 9, 11, 15)

# start <- c(1, 4, 7)
# stop <- c(3, 6, 8)

test_set <- tibble(
    start = start,
    stop = stop
) |>
    arrange(start) |>
    mutate(
        id = seq_along(start),
    )

plot_overlaps(start, stop)

test_set |>
    mutate(
        count_overlaps(start, stop)
    )
recording_overlap_duration(test_set$start, test_set$stop)
