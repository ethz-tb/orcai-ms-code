library(tidyverse)
library(here)
library(jsonlite)

model_paths <- c(
    here("orcai", "orcai-v1-3750-LSTM_1"),
    here("orcai", "orcai-v1-3750-1DC_1")
)

training_data_list <- list()

for (i in seq_along(model_paths)) {
    model_info <- read_json(here(model_paths[i], "orcai_parameter.json"))

    training_data_list[[i]] <- read_csv(
        here(model_paths[i], "training_times.csv"),
        col_types = cols(.default = col_double())
    ) |>
        mutate(
            model = model_info$name,
            architecture = model_info$architecture,
            n_batches_epoch = model_info$model$n_batch_train,
            batch_size = model_info$mode$batch_size,
            .before = epoch
        ) |>
        mutate(
            batch_time = epoch_time / n_batches_epoch,
            sample_time = batch_time / batch_size,
        )
}

training_data <- bind_rows(training_data_list)

training_data |>
    group_by(model, architecture) |>
    summarize(
        across(ends_with("_time"), ~ mean(.x, na.rm = TRUE))
    )
