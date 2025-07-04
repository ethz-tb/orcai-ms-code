library(tidyverse)
library(here)
library(glue)
library(jsonlite)

find_overlaps <- function(start, stop) {
    # returns vector of indices that overlap, provided start and stop are ordered ascending by start!
    overlaps_with_list <- list()
    overlaps_with_n_list <- list()
    for (i in seq_len(length(start))) {
        # overlaps at end
        overlaps_with_end <- which(start[-c(1:i)] < stop[i]) + i
        # overlaps at beginning
        overlaps_with_start <- which(stop[start < start[i]] > start[i])

        overlaps_with <- c(overlaps_with_start, overlaps_with_end)
        overlaps_with_n_list[[i]] <- length(overlaps_with)
        overlaps_with_list[[i]] <- overlaps_with
    }

    return(
        tibble(
            overlaps_with_n = unlist(overlaps_with_n_list),
            overlaps_with_str = map_chr(overlaps_with_list, \(x) str_c(x, collapse = ", ")),
            overlaps_with = overlaps_with_list
        )
    )
}

# test_set <- tibble(
#     start = c(1, 2, 4, 6, 7),
#     stop = c(3, 5, 8, 10, 9)
# )

# test_set |>
#     mutate(
#         find_overlaps(start, stop)
#     )


recording_table <- read_csv(
    file = "/Volumes/4TB/orcai_project/orca_recordings/recording_table.csv",
    col_types = cols(
        recording = col_character(),
        channel = col_double(),
        duplicate = col_logical(),
        base_dir_recording = col_character(),
        rel_recording_path = col_character(),
        base_dir_annotation = col_character(),
        rel_annotation_path = col_character(),
        CS = col_logical(),
        HFW = col_logical(),
        IGNORE = col_logical(),
        NOLABEL = col_logical(),
        Unlabelled = col_logical(),
        BR = col_logical(),
        BUZZ = col_logical(),
        HERDING = col_logical(),
        PHS = col_logical(),
        SS = col_logical(),
        TAILSLAP = col_logical(),
        WHISTLE = col_logical()
    )
) |>
    filter(!is.na(base_dir_annotation)) |>
    rowwise() |>
    mutate(
        has_signal = any(BR, BUZZ, HERDING, PHS, SS, TAILSLAP, WHISTLE)
    ) |>
    filter(
        has_signal
    ) |>
    mutate(
        annotation_path = here(base_dir_annotation, rel_annotation_path)
    ) |>
    select(
        recording, channel,
        annotation_path,
        BR, BUZZ, HERDING, PHS, SS, TAILSLAP, WHISTLE
    )

all_annotations_list <- list()

for (i in seq_len(dim(recording_table)[1])) {
    all_annotations_list[[i]] <- read_tsv(
        recording_table$annotation_path[i],
        col_names = c("start", "stop", "origlabel"),
        col_types = "ddc"
    ) |>
        arrange(start) |>
        mutate(recording = recording_table$recording[i], .before = "start")
}

call_equivalences_json <- read_json(here("input_parameter/call_equivalences.json"))
call_equivalences <- tibble(
    origlabel = names(call_equivalences_json),
    label = unlist(call_equivalences_json)
)

all_annotations <- bind_rows(all_annotations_list) |>
    left_join(call_equivalences, by = join_by(origlabel)) |>
    filter(label %in% c("BR", "BUZZ", "HERDING", "PHS", "SS", "TAILSLAP", "WHISTLE")) |>
    select(-origlabel)

all_annotations_overlaps <- all_annotations |>
    group_by(recording) |>
    arrange(start, .by_group = TRUE) |>
    mutate(
        find_overlaps(start, stop)
    )

write_csv(
    all_annotations_overlaps |>
        select(-overlaps_with),
    here("analysis_scripts", "output", "all_annotations_overlaps.csv")
)

all_annotations_overlaps |>
    ungroup() |>
    select(-overlaps_with) |>
    count(overlaps_with_n) |>
    mutate(
        total = sum(n),
        percent = n / sum(n)
    )

hist(all_annotations_overlaps$overlaps_with_n)
