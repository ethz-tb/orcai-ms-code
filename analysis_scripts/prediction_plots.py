from pathlib import Path

import matplotlib.pyplot as plt
import pandas as pd
from matplotlib import rc
from orcAI.io import read_json
from prediction_plots_fn import (
    CALLS,
    AnnotationPlotAesthetics,
    AnnotationPlotData,
    annotation_figure,
    legend_plot,
)
from sample_predictions import (
    BINS_LABELS,
    N_PREDICTIONS,
)
from tqdm import tqdm

orcai_parameter = read_json(Path("input_parameter/orcai_parameter_v1_1.json"))
spectrogram_parameter = orcai_parameter["spectrogram"]
plot_spectrogram_parameter = orcai_parameter["spectrogram"].copy()
plot_spectrogram_parameter.update(
    {
        "nfft": 8192,
        "n_overlap": 4096,
    }
)

# Load
all_predicted_calls = pd.read_csv(
    Path("analysis_scripts", "output", "csv", "all_predicted_calls.csv")
)
sampled_calls = pd.read_csv(Path("analysis_scripts/output/csv/sampled_calls.csv"))
call_equivalences = read_json(Path("input_parameter/call_equivalences.json"))

page_margin = 20  # mm
page_margin_bottom = 45  # mm
figure_size = (
    (210 - (2 * page_margin)) / 25.4,
    (297 - (page_margin + page_margin_bottom)) / 25.4,
)

rc(
    "font",
    **{
        "family": "sans-serif",
        "sans-serif": ["Arial"],
        "size": 7,
    },
)

for i, label in tqdm(enumerate(CALLS), total=len(CALLS), desc="Plotting"):
    sampled_calls_label = sampled_calls.query("label == @label")
    figure, axs = plt.subplots(
        2, 1, height_ratios=[20, 1], figsize=figure_size, dpi=300, layout="constrained"
    )
    gridspec = axs[0].get_subplotspec().get_gridspec()
    axs[0].remove()
    legend_plot(
        axs[1],
        aesthetics=AnnotationPlotAesthetics(time_limits=[0, 1]),
    )
    subfigure = figure.add_subfigure(gridspec[0, 0])
    subfigures = subfigure.subfigures(
        N_PREDICTIONS, len(BINS_LABELS), hspace=0, wspace=0
    )

    for i, sampled_call in tqdm(
        enumerate(sampled_calls_label.itertuples(index=False)),
        total=len(sampled_calls_label),
        desc=label,
        leave=False,
    ):
        plot_data = AnnotationPlotData.from_sampled_call(
            sampled_call,
            all_predicted_calls,
            call_equivalences,
            plot_spectrogram_parameter,
            sample_extension_absolute=5,
            sample_extension_relative=0,
        )
        col_index = sampled_call.mean_p_bin_index
        row_index = sampled_call.sample_index
        figure_title = BINS_LABELS[col_index] if row_index == 0 else None

        draw_x_axis_label = i == (len(sampled_calls_label) - 1) or row_index == (
            N_PREDICTIONS - 1
        )
        draw_y_axis_label = col_index == 0

        subfigures[row_index, col_index] = annotation_figure(
            subfigures[row_index, col_index],
            plot_data,
            figure_title=figure_title,
            draw_x_axis_label=draw_x_axis_label,
            draw_y_axis_label=draw_y_axis_label,
            draw_recording_label=True,
        )
        if col_index == 0:
            subfigures[row_index, col_index].text(
                -0.2,
                0.5,
                f"Sample {row_index + 1}",
                ha="center",
                va="center",
                rotation="vertical",
                fontweight="bold",
                fontsize=8,
            )
    figure.suptitle(f"Predictions for {label}", fontweight="bold")
    figure.savefig(
        Path(
            "analysis_scripts/output/figures/annotations",
            f"predictions_plot_{label}.pdf",
        ),
        bbox_inches="tight",
    )
