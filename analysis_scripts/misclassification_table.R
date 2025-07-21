library(tidyverse)
library(knitr)
library(kableExtra)
library(here)
library(glue)

best_orcaiv1_model <- read_csv(here("analysis_scripts", "output", "csv", "best_orcaiv1_model.csv"),
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
        ` ` = "annotated signal"
    )

write_csv(
    unfiltered_dataset_TP |>
        mutate(across(where(is.numeric), \(x) round(x, digits = 4))),
    here("analysis_scripts", "output", "csv", "missclassification_unfiltered_TP.csv")
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
        ` ` = "predicted signal"
    )

write_csv(
    unfiltered_dataset_PT |>
        mutate(across(where(is.numeric), \(x) round(x, digits = 4))),
    here("analysis_scripts", "output", "csv", "missclassification_unfiltered_PT.csv")
)

TP_table_raw <- unfiltered_dataset_TP |>
    kbl(
        format = "latex", digits = 4,
        booktabs = TRUE
    ) |>
    add_header_above(c(" " = 2, "predicted signal" = 8, " " = 1)) |>
    collapse_rows(1, latex_hline = "none")

PT_table_raw <- unfiltered_dataset_PT |>
    kbl(
        format = "latex", digits = 4,
        booktabs = TRUE
    ) |>
    add_header_above(c(" " = 2, "annotated signal" = 8, " " = 1)) |>
    collapse_rows(1, latex_hline = "none")

# combine tables

TP_table_str <- TP_table_raw |>
    toString() |>
    str_replace(
        "\\\\raggedright\\\\arraybackslash annotated signal",
        "\\\\rotatebox[origin=c]{90}{annotated signal}"
    ) |>
    str_split(pattern = "(\n)+")

PT_table_str <- PT_table_raw |>
    toString() |>
    str_replace(
        "\\\\raggedright\\\\arraybackslash predicted signal",
        "\\\\rotatebox[origin=c]{90}{predicted signal}"
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

TP_table_footnote_2 <- paste0(
    "\\multicolumn{11}{l}{",
    "TS: tail slaps; ",
    "WH: whistle; ",
    "none: no trained signal annotated",
    "}\\\\"
)

PT_table_footnote_2 <- paste0(
    "\\multicolumn{11}{l}{",
    "TS: tail slaps; ",
    "WH: whistle; ",
    "none: no trained signal predicted",
    "}\\\\"
)

combined_table_footnote_2 <- paste0(
    "\\multicolumn{11}{l}{",
    "TS: tail slaps; ",
    "WH: whistle; ",
    "none: no trained signal annotated (top) / predicted (bottom)",
    "}\\\\"
)

TP_table <- c(
    TP_table_str[[1]][2:16],
    TP_PT_table_footnote_1,
    TP_table_footnote_2,
    PT_table_str[[1]][17]
) |>
    write_lines(file = here("analysis_scripts", "output", "tex", "mc_table_TP.tex"))

PT_table <- c(
    PT_table_str[[1]][2:16],
    TP_PT_table_footnote_1,
    PT_table_footnote_2,
    PT_table_str[[1]][17]
) |>
    write_lines(file = here("analysis_scripts", "output", "tex", "mc_table_PT.tex"))


TP_PT_table <- c(
    TP_table_str[[1]][2:16],
    PT_table_str[[1]][3:16],
    TP_PT_table_footnote_1,
    combined_table_footnote_2,
    PT_table_str[[1]][17]
) |>
    write_lines(file = here("analysis_scripts", "output", "tex", "mc_table_TP_PT.tex"))
