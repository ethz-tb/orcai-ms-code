library(tidyverse)
library(jsonlite)
library(glue)
library(here)

best_models_metrics <- read_csv(
    here("analysis_scripts", "output", "csv", "best_models_metrics.csv"),
    col_types = cols(
        model = col_character(),
        replicate = col_double(),
        architecture = col_character(),
        epoch = col_double(),
        type = col_character(),
        metric = col_character(),
        value = col_double()
    )
)

# best orcai-v1 model
best_orcaiv1_replicate <- best_models_metrics |>
    filter(model == "orcai-v1", type == "validation", metric == "MBA") |>
    filter(value == max(value)) |>
    pull(replicate)

best_orcaiv1 <- best_models_metrics |>
    filter(model == "orcai-v1", replicate == best_orcaiv1_replicate)

# mean, sd, se
model_metrics_summary <- best_models_metrics |>
    filter(metric != "learning_rate") |>
    group_by(model, architecture, metric, type) |>
    summarise(
        mean = mean(value),
        sd = sd(value),
        ens = n(),
        se = sd / sqrt(ens),
        .groups = "drop"
    ) |>
    arrange(
        model, metric, type
    ) |>
    mutate(
        text = glue("{signif(mean * 100,3)}±{signif(se * 100, 3)} SE")
    )

write_excel_csv(model_metrics_summary, file = here("analysis_scripts", "output", "csv", "model_metrics_summary.csv"))
write_excel_csv(best_orcaiv1, file = here("analysis_scripts", "output", "csv", "best_orcaiv1_model.csv"))
