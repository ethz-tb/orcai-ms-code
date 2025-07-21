library(tidyverse)
library(here)
library(knitr)
library(kableExtra)

hps_trials_raw <- read_csv(
    here("hyperparameter_search", "hps_logs", "all_trials.csv"),
    col_types = cols(
        filters = col_character(),
        kernel_size = col_double(),
        dropout_rate = col_double(),
        batch_size = col_double(),
        lstm_units = col_double(),
        `tuner/epochs` = col_double(),
        `tuner/initial_epoch` = col_double(),
        `tuner/bracket` = col_double(),
        `tuner/round` = col_double(),
        score = col_double(),
        status = col_character(),
        MBA = col_double(),
        loss = col_double(),
        val_MBA = col_double(),
        val_loss = col_double(),
        `tuner/trial_id` = col_character()
    )
)

hps_trials <- hps_trials_raw |>
    mutate(
        filters = case_match(
            filters,
            "set1" ~ "[10, 20, 30, 40]",
            "set2" ~ "[20, 30, 40, 50]",
            "set3" ~ "[30, 40, 50, 60]"
        )
    ) |>
    rename_with(~ str_replace(.x, "tuner/", "")) |>
    rename_with(~ str_replace(.x, "_", " ")) |>
    select(
        filters:`lstm units`,
        epochs,
        MBA, loss,
        `val MBA`, `val loss`
    )

hps_trials |>
    arrange(desc(`val MBA`)) |>
    kbl(
        format = "latex", digits = 4,
        col.names = c(
            "filters", "kernel", "dropout", "batch", "lstm",
            "epochs", "MBA", "loss", "MBA", "loss"
        ),
        booktabs = TRUE
    ) |>
    add_header_above(c("hyperparameter" = 5, " " = 1, "test data" = 2, "validation data" = 2)) |>
    row_spec(1, bold = TRUE) |>
    write_lines(file = here("analysis_scripts", "output", "tex", "hps_trials_table.tex"))
