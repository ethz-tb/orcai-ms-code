library(tidyverse)
library(here)
library(glue)
library(jsonlite)
library(ivs)

source(here("analysis_scripts/annotation_overlap_fns.R"))

all_annotations <- read_csv(here("data/all_annotations.csv"),
    col_types = cols(
        recording = col_character(),
        start = col_double(),
        stop = col_double(),
        label = col_character()
    )
)

all_predictions <- read_csv(
    here("data/all_predictions.csv"),
    col_types = cols(
        recording = col_character(),
        start = col_double(),
        stop = col_double(),
        label = col_character(),
        mean_p = col_double(),
        label_source = col_character()
    )
)


all_annotations_overlaps <- all_annotations |>
    group_by(recording) |>
    arrange(start, .by_group = TRUE) |>
    mutate(
        count_overlaps(start, stop)
    )

all_predictions_overlaps <- all_predictions |>
    group_by(recording) |>
    arrange(start, .by_group = TRUE) |>
    mutate(
        count_overlaps(start, stop)
    )

write_csv(
    all_annotations_overlaps |>
        select(-overlaps_with_list),
    here("analysis_scripts", "output", "all_annotations_overlaps.csv")
)

all_annotations_overlaps_summary <- all_annotations_overlaps |>
    ungroup() |>
    select(-overlaps_with) |>
    count(overlaps_with_n) |>
    mutate(
        total = sum(n),
        percent = 100 * (n / sum(n))
    )

write_csv(
    all_annotations_overlaps_summary,
    here("analysis_scripts", "output", "all_annotations_overlaps_summary.csv")
)

ggplot(
    data = all_annotations_overlaps,
    mapping = aes(overlaps_with_n)
) +
    geom_histogram(binwidth = 1) +
    scale_x_continuous(name = "overlaps with n", breaks = 0:6) +
    theme_bw()

# overlap duration
all_annotations_overlaps_duration <- all_annotations |>
    group_by(recording) |>
    summarise(
        annotation_duration = sum(stop - start),
        overlap_duration = snippet_overlap_duration(start, stop),
        ratio = overlap_duration / annotation_duration
    )

write_csv(
    all_annotations_overlaps_duration,
    here("analysis_scripts", "output", "all_annotations_overlaps_duration.csv")
)

all_annotations_overlaps_duration_summary <- all_annotations_overlaps_duration |>
    summarize(
        total_annotation_duration = sum(annotation_duration),
        total_overlap_duration = sum(all_annotations_overlaps_duration$overlap_duration),
        ratio_with_overlap = total_overlap_duration / total_annotation_duration
    )

write_csv(
    all_annotations_overlaps_duration_summary,
    here("analysis_scripts", "output", "all_annotations_overlaps_duration_summary.csv")
)

# annotation duration

mean_annotation_duration <- all_annotations |>
    ungroup() |>
    mutate(
        duration = stop - start
    ) |>
    group_by(
        label
    ) |>
    summarize(
        ens = n(),
        min = min(duration),
        max = max(duration),
        mean = mean(duration),
        sd = sd(duration),
        se = sd / sqrt(ens)
    )
print(mean_annotation_duration)
