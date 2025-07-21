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

test_data_confusion <- read_csv(
    file = here(
        "trained_models", glue("orcai-v1_{best_replicate}"),
        "test", "test_data_confusion_table.csv"
    ),
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
    mutate(Set = "filtered data", .before = TP) |>
    arrange(Label)

unfiltered_data_confusion <- read_csv(
    file = here(
        "trained_models", glue("orcai-v1_{best_replicate}"),
        "test", "test_unfiltered_dataset_confusion_table.csv"
    ),
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
    mutate(Set = "unfiltered data", .before = TP) |>
    arrange(Label)

confusion_table <- bind_rows(test_data_confusion, unfiltered_data_confusion) |>
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
    select(Label, Set, TP, FN, FP, TN, PR, RE, F1)

write_csv(
    confusion_table |>
        mutate(across(where(is.numeric), \(x) round(x, digits = 4))),
    here("analysis_scripts", "output", "csv", "confusion_table.csv")
)

confusion_table |>
    select(-Set) |>
    kbl(
        format = "latex", digits = 4,
        booktabs = TRUE
    ) |>
    pack_rows("filtered dataset", 1, 7) |>
    pack_rows("unfiltered dataset", 8, 14) |>
    write_lines(file = here("analysis_scripts", "output", "tex", "confusion_table.tex"))
