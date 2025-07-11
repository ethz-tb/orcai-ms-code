library(tidyverse)
library(patchwork)
library(here)

model_training_metrics <- read_csv(
    here("analysis_scripts", "output", "csv", "model_training_metrics.csv"),
    col_types = cols(
        model = col_character(),
        architecture = col_character(),
        replicate = col_double(),
        epoch = col_double(),
        metric = col_character(),
        type = col_character(),
        value = col_double()
    )
)

best_models_test_metrics <- read_csv(
    here("analysis_scripts", "output", "csv", "best_models_metrics.csv"),
    col_types = cols(
        model = col_character(),
        replicate = col_double(),
        architecture = col_character(),
        type = col_character(),
        metric = col_character(),
        value = col_double()
    )
) |>
    filter(
        type == "test_filtered"
    )

common_theme <- theme_bw() + theme(
    text = element_text(size = 7),
    legend.margin = margin(),
    legend.title = element_blank()
)

# plot individual runs
model_colors <- c(
    "orcai-v1" = rgb(34, 160, 43, maxColorValue = 255),
    "orcai-v1-3750-LSTM" = rgb(32, 119, 180, maxColorValue = 255),
    "orcai-v1-3750-1DC" = rgb(255, 127, 15, maxColorValue = 255)
)
common_theme <- theme_bw() + theme(
    text = element_text(size = 7),
    legend.margin = margin(),
    legend.title = element_blank()
)
replicate_alpha <- c(
    "1" = 0.5,
    "2" = 0.7,
    "3" = 0.9
)

type_lines <- c(
    "validation" = 1,
    "training" = 2
)

epoch_limits <- c(0, 30)
epoch_breaks <- seq(epoch_limits[1], epoch_limits[2], 5)

# model_training_metrics |>
#     group_by(metric) |>
#     summarize(
#         min = min(value, na.rm = TRUE),
#         max = max(value, na.rm = TRUE)
#     )

loss_limits <- c(0, 0.7)
loss_breaks <- seq(loss_limits[1], loss_limits[2], 0.1)

mba_limits <- c(0.9, 0.98)
mba_breaks <- seq(mba_limits[1], mba_limits[2], 0.01)

lr_limits <- c(0, 1e-4)
lr_breaks <- waiver() # default breaks

plot_loss <- model_training_metrics |>
    filter(model != "orcai-v1", metric == "loss") |>
    ggplot(
        mapping = aes(
            x = epoch, y = value,
            colour = model,
            alpha = as.character(replicate),
            linetype = type
        )
    ) +
    geom_line() +
    geom_point(
        data = best_models_test_metrics |> filter(model != "orcai-v1", metric == "loss"),
    ) +
    scale_linetype_manual(values = type_lines, name = "", guide = guide_legend(order = 2)) +
    scale_colour_manual(values = model_colors, name = "", guide = guide_legend(order = 1)) +
    scale_alpha_manual(values = replicate_alpha, name = "", guide = "none") +
    scale_x_continuous(limits = epoch_limits, breaks = epoch_breaks) +
    scale_y_continuous(limits = loss_limits, breaks = loss_breaks) +
    labs(
        y = "Loss (Masked Binary Crossentropy)",
        x = "Epoch"
    ) +
    common_theme +
    theme(
        legend.position = "inside",
        legend.position.inside = c(0.95, 0.95),
        legend.justification = c(1, 1),
        legend.text = element_text(size = 5)
    )

plot_MBA <- model_training_metrics |>
    filter(model != "orcai-v1", metric == "MBA") |>
    ggplot(
        mapping = aes(
            x = epoch, y = value,
            colour = model,
            alpha = as.character(replicate),
            linetype = type
        )
    ) +
    geom_line() +
    geom_point(
        data = best_models_test_metrics |> filter(model != "orcai-v1", metric == "MBA"),
    ) +
    scale_linetype_manual(values = type_lines, name = "") +
    scale_colour_manual(values = model_colors, name = "") +
    scale_alpha_manual(values = replicate_alpha, name = "", guide = "none") +
    scale_x_continuous(limits = epoch_limits, breaks = epoch_breaks) +
    scale_y_continuous(limits = mba_limits, breaks = mba_breaks) +
    labs(
        y = "Masked Binary Accuracy",
        x = "Epoch"
    ) +
    common_theme +
    theme(legend.position = "none")


plot_LR <- model_training_metrics |>
    filter(model != "orcai-v1", metric == "learning_rate", type == "training") |>
    ggplot(
        mapping = aes(
            x = epoch, y = value,
            colour = model,
            alpha = as.character(replicate)
        )
    ) +
    geom_line() +
    scale_colour_manual(values = model_colors, name = "") +
    scale_alpha_manual(values = replicate_alpha, name = "", guide = "none") +
    scale_x_continuous(limits = epoch_limits, breaks = epoch_breaks) +
    scale_y_continuous(limits = lr_limits, breaks = lr_breaks) +
    labs(
        y = "Learning Rate",
        x = "Epoch"
    ) +
    common_theme +
    theme(legend.position = "none")

plot_all <- plot_loss + plot_MBA + plot_LR +
    plot_annotation(tag_levels = "A")

ggsave(
    plot = plot_all,
    here("analysis_scripts", "output", "figures", "fig2_training_history.pdf"),
    width = 183,
    height = 80,
    unit = "mm"
)

ggsave(
    plot = plot_all,
    here("analysis_scripts", "output", "figures", "fig2_training_history.png"),
    width = 183,
    height = 80,
    unit = "mm"
)
