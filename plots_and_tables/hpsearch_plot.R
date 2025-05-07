library(tidyverse)
library(here)
library(jsonlite)
library(patchwork)

hps_parameter <- read_json(here("orcai", "hps_parameter.json"))

trial_data <- read_csv(
    file = here("orcai", "orcai-v1-3750-LSTM_HPS", "hps_logs", "all_trials.csv"),
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
        loss = col_double(),
        MBA = col_double(),
        val_loss = col_double(),
        val_MBA = col_double(),
        `tuner/trial_id` = col_character()
    )
) |>
    mutate(
        filters = factor(filters, levels = names(hps_parameter$filters)),
        kernel_size = factor(kernel_size, levels = hps_parameter$kernel_size),
        dropout_rate = factor(dropout_rate, levels = hps_parameter$dropout_rate),
        batch_size = factor(batch_size, levels = hps_parameter$batch_size),
        lstm_units = factor(lstm_units, levels = hps_parameter$lstm_units)
    )

best_parameter <- trial_data |>
    slice_max(order_by = score)

common_theme <- theme_bw() + theme(
    text = element_text(size = 7),
    legend.margin = margin(),
    legend.title = element_blank()
)

best_color <- rgb(32, 119, 180, maxColorValue = 255)

filters_plot <- trial_data |>
    ggplot(
        mapping = aes(x = filters, y = score)
    ) +
    geom_boxplot(linewidth = 0.25, outlier.size = 0.5) +
    geom_point(data = best_parameter, color = best_color, shape = 8) +
    labs(x = "Filters", y = "Masked binary accuracy") +
    common_theme

lstm_units_plot <- trial_data |>
    ggplot(
        mapping = aes(x = lstm_units, y = score)
    ) +
    geom_boxplot(linewidth = 0.25, outlier.size = 0.5) +
    geom_point(data = best_parameter, color = best_color, shape = 8) +
    labs(x = "LSTM units", y = "Masked binary accuracy") +
    common_theme

dropout_rate_plot <- trial_data |>
    ggplot(
        mapping = aes(x = dropout_rate, y = score)
    ) +
    geom_boxplot(linewidth = 0.25, outlier.size = 0.5) +
    geom_point(data = best_parameter, color = best_color, shape = 8) +
    labs(x = "Dropout rate", y = "Masked binary accuracy") +
    common_theme

kernel_size_plot <- trial_data |>
    ggplot(
        mapping = aes(x = kernel_size, y = score)
    ) +
    geom_boxplot(linewidth = 0.25, outlier.size = 0.5) +
    geom_point(data = best_parameter, color = best_color, shape = 8) +
    labs(x = "Kernel size", y = "Masked binary accuracy") +
    common_theme

# batch_size_plot <- trial_data |>
#     ggplot(
#         mapping = aes(x = batch_size, y = score)
#     ) +
#     geom_boxplot(linewidth = 0.25, outlier.size = 0.5) +
#     geom_point(data = best_parameter, color = best_color, shape = 8) +
#     labs(x = "Batch size", y = "Masked binary accuracy") +
#     common_theme

hpsearch_plot <- filters_plot +
    lstm_units_plot +
    dropout_rate_plot +
    kernel_size_plot +
    # batch_size_plot +
    plot_layout(ncol = 4) +
    plot_annotation(tag_levels = "A")

ggsave(
    here("/Volumes/4TB/orcai_project/orcai/hpsearch_plot.pdf"),
    width = 183,
    height = 60,
    unit = "mm",
)
