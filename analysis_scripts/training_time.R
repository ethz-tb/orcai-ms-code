library(tidyverse)
library(jsonlite)
library(here)

model_paths <- list.dirs(here("trained_models"), recursive = FALSE)

extract_training_times_from_log <- function(log) {
    epoch_times <- str_extract(log, pattern = ", (\\d+\\.\\d{2})s\\/epoch,", group = 1)
    device <- str_extract(log,
        pattern = "-> device: 0, name: (.+)(?=, pci).*(?:compute capability: )(\\d\\.\\d)",
        group = 1
    )
    device <- device[!is.na(device)][1]
    compute_capability <- str_extract(log,
        pattern = "-> device: 0, name: (.+)(?=, pci).*(?:compute capability: )(\\d\\.\\d)",
        group = 2
    )
    compute_capability <- as.double(compute_capability[!is.na(compute_capability)][1])
    epoch_times <- as.double(epoch_times[!is.na(epoch_times)])
    out <- tibble(
        epoch = seq_along(epoch_times),
        epoch_time = epoch_times,
        device = device,
        compute_capability = compute_capability,
    )
    return(out)
}

training_times_list <- list()

for (i in seq_along(model_paths)) {
    model_info <- read_json(here(model_paths[i], "orcai_parameter.json"))
    log_path <- list.files(here(model_paths[i], "logs"), pattern = "training_output_.+\\.log", full.names = TRUE)[1]
    log <- readLines(log_path)
    training_times_list[[i]] <- extract_training_times_from_log(log) |>
        mutate(
            model = str_split_i(model_info$name, pattern = "_", 1),
            replicate = as.integer(str_split_i(model_info$name, pattern = "_", 2)),
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

training_times <- bind_rows(training_times_list)

training_times_summary <- training_times |>
    group_by(device, compute_capability, model, replicate, architecture) |>
    summarize(
        across(ends_with("_time"), ~ mean(.x, na.rm = TRUE)),
        .groups = "keep"
    )

training_times_summary_arch <- training_times |>
    group_by(device, compute_capability, model) |>
    summarize(
        across(ends_with("_time"), ~ mean(.x, na.rm = TRUE)),
        .groups = "keep"
    )

write_csv(training_times_summary, here("analysis_scripts", "output", "training_times.csv"))
write_csv(training_times_summary_arch, here("analysis_scripts", "output", "training_times_arch.csv"))
