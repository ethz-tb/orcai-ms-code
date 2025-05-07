library(tidyverse)
library(knitr)
library(kableExtra)
library(here)

test_sampled_data_mc_table_paths <- tibble(
    dataset = "all",
    path = c(
        here("trained_models", "orcai-v1", "test", "test_sampled_data_misclassification_table_pred_true.csv")
    )
)


sampled_data_TP <- here(
    "trained_models", "orcai-v1", "test",
    "test_sampled_data_misclassification_table_true_pred.csv"
) |>
    read_csv(
        col_types = cols(Label = col_character(), .default = col_double())
    ) |>
    separate_wider_delim(Label, delim = "_", names = c(" ", "Label")) |>
    rename_with(.cols = contains("pred_"), ~ str_remove(.x, "pred_")) |>
    rename_with(~ case_match(.x,
        "HERDING" ~ "HERD",
        "TAILSLAP" ~ "TS",
        "WHISTLE" ~ "WH",
        "NOLABEL" ~ "NONE",
        "fraction_time" ~ "fraction time",
        .default = .x
    )) |>
    mutate(
        Label = case_match(
            Label,
            "HERDING" ~ "HERD",
            "TAILSLAP" ~ "TS",
            "WHISTLE" ~ "WH",
            "NOLABEL" ~ "NONE",
            .default = Label
        ),
    )
sampled_data_PT <- here(
    "trained_models", "orcai-v1", "test",
    "test_sampled_data_misclassification_table_pred_true.csv"
) |>
    read_csv(
        col_types = cols(Label = col_character(), .default = col_double())
    ) |>
    separate_wider_delim(Label, delim = "_", names = c(" ", "Label")) |>
    rename_with(.cols = contains("true_"), ~ str_remove(.x, "true_")) |>
    rename_with(~ case_match(.x,
        "HERDING" ~ "HERD",
        "TAILSLAP" ~ "TS",
        "WHISTLE" ~ "WH",
        "NOLABEL" ~ "NONE",
        "fraction_time" ~ "fraction time",
        .default = .x
    )) |>
    mutate(
        Label = case_match(
            Label,
            "HERDING" ~ "HERD",
            "TAILSLAP" ~ "TS",
            "WHISTLE" ~ "WH",
            "NOLABEL" ~ "NONE",
            .default = Label
        ),
        ` ` = "predicted"
    )

sampled_data_TP |>
    kbl(
        format = "latex", digits = 4,
        booktabs = TRUE
    ) |>
    add_header_above(c(" " = 2, "predicted" = 8, " " = 1)) %>%
    collapse_rows(1, latex_hline = "none") |>
    write_lines(file = here("plots_and_tables", "output", "mc_table_TP.tex"))

sampled_data_PT |>
    kbl(
        format = "latex", digits = 4,
        booktabs = TRUE
    ) |>
    add_header_above(c(" " = 2, "true" = 8, " " = 1)) %>%
    collapse_rows(1, latex_hline = "none") |>
    write_lines(file = here("plots_and_tables", "output", "mc_table_PT.tex"))
