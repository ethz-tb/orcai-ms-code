library(tidyverse)
library(knitr)
library(kableExtra)
library(here)
library(glue)

best_orcaiv1_model <- read_csv(here("analysis_scripts", "output", "best_orcaiv1_model.csv"),
    col_types = cols(
        model = col_character(),
        architecture = col_character(),
        replicate = col_double(),
        epoch = col_double(),
        type = col_character(),
        metric = col_character(),
        value = col_double()
    )
)
best_replicate <- best_orcaiv1_model$replicate[1]

unfiltered_dataset_TP <- here(
    "trained_models", glue("orcai-v1_{best_replicate}"), "test",
    "test_unfiltered_dataset_misclassification_table_true_pred.csv"
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
        "NOLABEL" ~ "none",
        "fraction_time" ~ "fraction time",
        .default = .x
    )) |>
    mutate(
        Label = case_match(
            Label,
            "HERDING" ~ "HERD",
            "TAILSLAP" ~ "TS",
            "WHISTLE" ~ "WH",
            "NOLABEL" ~ "none",
            .default = Label
        ),
    )

unfiltered_dataset_PT <- here(
    "trained_models", glue("orcai-v1_{best_replicate}"), "test",
    "test_unfiltered_dataset_misclassification_table_pred_true.csv"
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
        "NOLABEL" ~ "none",
        "fraction_time" ~ "fraction time",
        .default = .x
    )) |>
    mutate(
        Label = case_match(
            Label,
            "HERDING" ~ "HERD",
            "TAILSLAP" ~ "TS",
            "WHISTLE" ~ "WH",
            "NOLABEL" ~ "none",
            .default = Label
        ),
        ` ` = "predicted"
    )

TP_table <- unfiltered_dataset_TP |>
    kbl(
        format = "latex", digits = 4,
        booktabs = TRUE
    ) |>
    add_header_above(c(" " = 2, "predicted" = 8, " " = 1)) %>%
    collapse_rows(1, latex_hline = "none") |>
    write_lines(file = here("analysis_scripts", "output", "mc_table_TP.tex"))

PT_table <- unfiltered_dataset_PT |>
    kbl(
        format = "latex", digits = 4,
        booktabs = TRUE
    ) |>
    add_header_above(c(" " = 2, "true" = 8, " " = 1)) %>%
    collapse_rows(1, latex_hline = "none") |>
    write_lines(file = here("analysis_scripts", "output", "mc_table_PT.tex"))

# combine tables

TP_table_str <- TP_table |>
    toString() |>
    str_replace(
        "\\\\raggedright\\\\arraybackslash true",
        "\\\\rotatebox[origin=c]{90}{true}"
    ) |>
    str_split(pattern = "(\n)+")

PT_table_str <- PT_table |>
    toString() |>
    str_replace(
        "\\\\raggedright\\\\arraybackslash predicted",
        "\\\\rotatebox[origin=c]{90}{predicted}"
    ) |>
    str_split(pattern = "(\n)+")

TP_PT_table_footnote_1 <- paste0(
    "\\multicolumn{11}{l}{\\rule{0pt}{1em}\\textit{Abbreviations:} ",
    "BR: breathing; ",
    "BUZZ: buzzing; ",
    "HERD: herding calls; ",
    "S: pulsed calls;",
    "}\\\\"
)

TP_PT_table_footnote_2 <- paste0(
    "\\multicolumn{11}{l}{",
    "TS: tail slaps; ",
    "WH: whistle; ",
    "none: no trained calls annotated (top) / predicted (bottom)",
    "}\\\\"
)

TP_PT_table <- c(
    TP_table_str[[1]][2:16],
    PT_table_str[[1]][3:16],
    TP_PT_table_footnote_1,
    TP_PT_table_footnote_2,
    PT_table_str[[1]][17]
) |>
    write_lines(file = here("analysis_scripts", "output", "mc_table_TP_PT.tex"))
