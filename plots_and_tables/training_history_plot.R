library(tidyverse)
library(here)
library(jsonlite)
library(patchwork)

model_paths <- c(
    here("orcai-v1-3750-LSTM_1"),
    here("orcai-v1-3750-1DC_1")
)

model_data_list <- list()

for (i in seq_along(model_paths)) {
    model_info <- read_json(here(model_paths[i], "orcai_parameter.json"))

    model_data_list[[i]] <- read_json(here(model_paths[i], "training_history.json")) |>
        as_tibble() |>
        unnest(cols = c(MBA, loss, val_MBA, val_loss, learning_rate)) |>
        mutate(
            model = model_info$name,
            architecture = model_info$architecture,
            epoch = seq_len(n()),
        )
}


model_data <- bind_rows(model_data_list)

model_data_training <- model_data |>
    select(
        model, architecture, epoch, loss, MBA, learning_rate
    ) |>
    pivot_longer(
        !c(model, architecture, epoch),
        values_to = "training"
    )
model_data_validation <- model_data |>
    select(
        model, architecture, epoch, val_loss, val_MBA
    ) |>
    rename(loss = val_loss, MBA = val_MBA) |>
    pivot_longer(
        !c(model, architecture, epoch),
        values_to = "validation"
    )

plot_data <- left_join(model_data_training, model_data_validation,
    by = join_by(model, architecture, epoch, name)
) |>
    pivot_longer(training:validation, names_to = "type")

unique(plot_data$architecture)
range(plot_data$epoch)

arch_colors <- c(
    "ResNetLSTM" = rgb(32, 119, 180, maxColorValue = 255),
    "ResNet1DConv" = rgb(255, 127, 15, maxColorValue = 255)
)
type_lines <- c(
    "validation" = 1,
    "training" = 2
)

common_theme <- theme_bw() + theme(
    text = element_text(size = 7),
    legend.margin = margin(),
    legend.title = element_blank()
)

plot_loss <- plot_data |>
    filter(name == "loss") |>
    ggplot(
        mapping = aes(x = epoch, y = value, colour = architecture, linetype = type)
    ) +
    geom_line() +
    labs(
        y = "Loss (Masked Binary Crossentropy)",
        x = "Epoch"
    ) +
    scale_linetype_manual(values = type_lines, name = "", guide = guide_legend(order = 2)) +
    scale_colour_manual(values = arch_colors, name = "", guide = guide_legend(order = 1)) +
    scale_x_continuous(limits = c(0, 30), breaks = seq(0, 30, 5)) +
    scale_y_continuous(limits = c(0, 0.7), breaks = seq(0, 0.7, 0.1)) +
    common_theme +
    theme(legend.position = "inside", legend.position.inside = c(0.95, 0.95), legend.justification = c(1, 1))

plot_MBA <- plot_data |>
    filter(name == "MBA") |>
    ggplot(
        mapping = aes(x = epoch, y = value, colour = architecture, linetype = type)
    ) +
    scale_colour_manual(values = arch_colors, name = "") +
    scale_linetype_manual(values = type_lines, name = "") +
    scale_x_continuous(limits = c(0, 30), breaks = seq(0, 30, 5)) +
    scale_y_continuous(limits = c(0.91, 0.97), breaks = seq(0.91, 0.97, 0.01)) +
    geom_line() +
    labs(
        y = "Masked Binary Accuracy",
        x = "Epoch"
    ) +
    common_theme +
    theme(legend.position = "none")

plot_LR <- plot_data |>
    filter(name == "learning_rate", type == "training") |>
    ggplot(
        mapping = aes(x = epoch, y = value, colour = architecture)
    ) +
    scale_colour_manual(values = arch_colors, name = "") +
    scale_x_continuous(limits = c(0, 30), breaks = seq(0, 30, 5)) +
    scale_y_continuous(limits = c(0, 1e-4)) +
    geom_line() +
    labs(
        y = "Learning Rate",
        x = "Epoch"
    ) +
    common_theme +
    theme(legend.position = "none")

plot <- plot_loss + plot_MBA + plot_LR +
    plot_annotation(tag_levels = "A")


ggsave(
    here("/Volumes/4TB/orcai_project/orcai/training_history.pdf"),
    width = 183,
    height = 80,
    unit = "mm"
)
