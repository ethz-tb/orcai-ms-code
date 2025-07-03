library(tidyverse)
library(knitr)
library(kableExtra)
library(here)

filtered_snippets_duration <- read_csv(
    here("tvt_data_stats", "filtered_snippets_duration.csv"),
    col_types = cols(
        ...1 = col_character(),
        train = col_time(format = ""),
        val = col_time(format = ""),
        test = col_time(format = ""),
        total = col_time(format = "")
    )
) |>
    rename(Label = `...1`) |>
    mutate(
        Label = case_match(
            Label,
            "BR" ~ "breathing",
            "BUZZ" ~ "buzzing",
            "HERDING" ~ "herding calls",
            "PHS" ~ "prey handling sounds",
            "SS" ~ "pulsed calls",
            "TAILSLAP" ~ "tail slaps",
            "WHISTLE" ~ "whistles"
        )
    )

filtered_snippets_duration |>
    select(Label, train, val, test) |>
    kbl(
        format = "latex", digits = 4,
        col.names = c("", "training", "validation", "test"),
        booktabs = TRUE,
        linesep = ""
    ) |>
    write_lines(file = here("analysis_scripts", "output", "filtered_snippets_duration.tex"))
