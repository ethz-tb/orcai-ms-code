library(tidyverse)
library(knitr)
library(kableExtra)
library(here)

test_data_confusion <- read_csv(
    file = here("trained_models", "orcai-v1", "test", "test_data_confusion_table.csv"),
    col_types = cols(
        Label = col_character(),
        TP = col_double(),
        FP = col_double(),
        TN = col_double(),
        FN = col_double(),
        PR = col_double(),
        RE = col_double(),
        F1 = col_double(),
        Total = col_double()
    )
) |>
    mutate(Set = "select", .before = TP) |>
    arrange(Label)

unfiltered_data_confusion <- read_csv(
    file = here("trained_models", "orcai-v1", "test", "test_sampled_data_confusion_table.csv"),
    col_types = cols(
        Label = col_character(),
        TP = col_double(),
        FP = col_double(),
        TN = col_double(),
        FN = col_double(),
        PR = col_double(),
        RE = col_double(),
        F1 = col_double(),
        Total = col_double()
    )
) |>
    mutate(Set = "all", .before = TP) |>
    arrange(Label)

confusion_table <- bind_rows(test_data_confusion, unfiltered_data_confusion) |>
    select(-Set, -Total) |>
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
    ) |>
    # make sure column order is correct
    select(Label, TP, FN, FP, TN, PR, RE, F1)

kbl(confusion_table,
    format = "latex", digits = 4,
    booktabs = TRUE
) |>
    pack_rows("select", 1, 7) |>
    pack_rows("all", 8, 14) |>
    write_lines(file = here("plots_and_tables", "output", "confusion_table.tex"))
