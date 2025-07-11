library(tidyverse)
library(here)
library(jsonlite)

model_paths <- list.dirs(here("trained_models"), recursive = FALSE)

# Load & tidy data

model_training_metrics_list <- list()
model_test_metrics_list <- list()
model_unfiltered_test_metrics_list <- list()

for (i in seq_along(model_paths)) {
    model_info <- read_json(here(model_paths[i], "orcai_parameter.json"))
    model_name <- str_split_i(model_info$name, pattern = "_", 1)
    replicate <- as.integer(str_split_i(model_info$name, pattern = "_", 2))

    model_training_metrics_list[[i]] <- read_json(here(model_paths[i], "training_history.json")) |>
        as_tibble() |>
        unnest(cols = c(MBA, loss, val_MBA, val_loss, learning_rate)) |>
        mutate(
            model = model_name,
            replicate = replicate,
            architecture = model_info$architecture,
            epoch = seq_len(n()),
            .before = MBA
        )

    # test data
    model_test_metrics_list[[i]] <- read_json(here(model_paths[i], "test", "test_data_metrics.json")) |>
        as_tibble() |>
        mutate(
            model = model_name,
            replicate = replicate,
            architecture = model_info$architecture,
            type = "test_filtered",
            .before = "MBA"
        )

    # test data for unfiltered dataset for final model
    if (model_name == "orcai-v1") {
        model_unfiltered_test_metrics_list[[i]] <- read_json(
            here(
                model_paths[i], "test", "test_unfiltered_dataset_metrics.json"
            )
        ) |>
            as_tibble() |>
            mutate(
                model = model_name,
                replicate = replicate,
                architecture = model_info$architecture,
                type = "test_unfiltered",
                .before = "MBA"
            )
    }
}

model_training_metrics_wide <- bind_rows(model_training_metrics_list)

best_models_training_metrics_wide <- model_training_metrics_wide |>
    group_by(model, replicate, architecture) |>
    filter(
        val_MBA == max(val_MBA)
    )

best_models_training_metrics_train <- best_models_training_metrics_wide |>
    select(
        model, architecture, replicate, epoch, loss, MBA, learning_rate
    ) |>
    pivot_longer(
        !c(model, architecture, replicate, epoch),
        names_to = "metric",
        values_to = "value"
    ) |>
    mutate(type = "training", .before = "metric")

best_models_training_metrics_val <- best_models_training_metrics_wide |>
    select(
        model, architecture, replicate, epoch, val_loss, val_MBA
    ) |>
    rename(loss = val_loss, MBA = val_MBA) |>
    pivot_longer(
        !c(model, architecture, replicate, epoch),
        names_to = "metric",
        values_to = "value"
    ) |>
    mutate(type = "validation", .before = "metric")
best_models_training_metrics <- bind_rows(best_models_training_metrics_train, best_models_training_metrics_val)

model_training_metrics_train <- model_training_metrics_wide |>
    select(
        model, architecture, replicate, epoch, loss, MBA, learning_rate
    ) |>
    pivot_longer(
        !c(model, architecture, replicate, epoch),
        names_to = "metric",
        values_to = "value"
    ) |>
    mutate(type = "training", .before = "metric")

model_training_metrics_val <- model_training_metrics_wide |>
    select(
        model, architecture, replicate, epoch, val_loss, val_MBA
    ) |>
    rename(loss = val_loss, MBA = val_MBA) |>
    pivot_longer(
        !c(model, architecture, replicate, epoch),
        names_to = "metric",
        values_to = "value"
    ) |>
    mutate(type = "validation", .before = "metric")
model_training_metrics <- bind_rows(model_training_metrics_train, model_training_metrics_val)

best_models_test_metrics_wide <- bind_rows(model_test_metrics_list, model_unfiltered_test_metrics_list)
best_models_test_metrics <- best_models_test_metrics_wide |>
    pivot_longer(
        !c(model, architecture, replicate, type),
        names_to = "metric",
        values_to = "value"
    ) |>
    left_join(
        best_models_training_metrics |>
            select(model, replicate, architecture, epoch) |>
            distinct(),
        by = join_by(model, replicate, architecture)
    ) |>
    select(model, architecture, replicate, epoch, type, metric, value)

best_models_metrics <- bind_rows(best_models_training_metrics, best_models_test_metrics) |>
    arrange(
        model, architecture, replicate, epoch, type, metric
    )

# save
write_excel_csv(model_training_metrics,
    file = here("analysis_scripts", "output", "csv", "model_training_metrics.csv")
)
write_excel_csv(best_models_metrics,
    file = here("analysis_scripts", "output", "csv", "best_models_metrics.csv")
)
