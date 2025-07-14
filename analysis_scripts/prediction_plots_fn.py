from dataclasses import dataclass, field
from pathlib import Path

import matplotlib.gridspec as gridspec
import numpy as np
import pandas as pd
from librosa import load
from matplotlib.figure import Figure
from matplotlib.lines import Line2D
from orcAI.io import read_annotation_file
from orcAI.spectrogram import calculate_spectrogram, preprocess_spectrogram

CALLS = ["BR", "BUZZ", "HERDING", "PHS", "SS", "TAILSLAP", "WHISTLE"]
CALL_COLORS = dict(
    zip(
        CALLS,
        [
            (1.0, 0.0, 0.0),
            (1.0, 2 / 3, 0.0),
            (2 / 3, 1.0, 0.0),
            (0.0, 1.0, 0.0),
            (0.0, 1.0, 2 / 3),
            (0.0, 2 / 3, 1.0),
            (0.0, 0.0, 1.0),
        ],
    )
)


@dataclass
class AnnotationPlotAesthetics:
    """
    Aesthetics for the annotation plot.
    """

    time_limits: list
    time_label: str = "time [s]"

    spectrogram_y_limits: list = field(default_factory=lambda: [0, 16000])
    spectrogram_y_ticks: list = field(default_factory=lambda: [0, 16000])
    spectrogram_y_ticks_labels: list = field(default_factory=lambda: ["0", "16"])
    spectrogram_y_label: str = "$F [kHz]$"
    spectrogram_cmap: str = "Grays"

    prediction_y_limits: list = field(default_factory=lambda: [0, 1])
    prediction_y_ticks: list = field(default_factory=lambda: [0, 1])
    prediction_y_ticks_labels: list = field(default_factory=lambda: ["0", "1"])
    prediction_y_label: str = "$p$"
    prediction_line_alpha: float = 0.5

    label_region_line_alpha: float = 0.5
    label_region_line_width: float = 1

    annotation_line_alpha: float = 0.5
    annotation_line_width: float = 2
    annotation_line_style: str = "solid"

    y_axis_label_x_offset: float = -0.2

    call_colors: dict = field(default_factory=lambda: CALL_COLORS)

    def call_color(self, call):
        """
        Get the color for a given call.
        """
        return self.call_colors.get(call, "black")


@dataclass
class AnnotationPlotData:
    sampled_call: pd.Series
    spectrogram: np.ndarray
    frequencies: np.ndarray
    times: np.ndarray
    sample_probabilities: pd.DataFrame
    sample_predicted_labels: pd.DataFrame
    sample_annotated_labels: pd.DataFrame
    aesthetics: AnnotationPlotAesthetics
    calls: list = field(default_factory=lambda: CALLS)

    @classmethod
    def from_sampled_call(
        cls,
        sampled_call,
        all_predicted_calls,
        call_equivalences,
        spectrogram_parameter,
        calls=CALLS,  # calls is accessed in query below
        **aesthetics,
    ):
        recording_path = Path(sampled_call.recording_path)
        probabilities_path = Path(sampled_call.recording_path).with_name(
            f"{sampled_call.recording}_c1_orcai-v1_predicted_probabilities.csv.gz"
        )
        annotations_path = recording_path.with_suffix(".txt")

        sample_start = max(sampled_call.start - 5, 0)
        sample_end = sampled_call.stop + 5
        sample_duration = sample_end - sample_start
        sample_probabilities = pd.read_csv(probabilities_path).query(
            "time >= @sample_start and time <= @sample_end"
        )
        # predicted labels
        sample_predicted_labels = all_predicted_calls[
            all_predicted_calls["recording"] == sampled_call.recording
        ].query(
            "(start >= @sample_start and start <= @sample_end) or (stop >= @sample_start and stop <= @sample_end)"
        )
        # annotated labels
        annotated_labels = read_annotation_file(annotations_path)
        annotated_labels["label"] = annotated_labels["origlabel"].map(call_equivalences)
        # filter out unused calls
        annotated_labels = annotated_labels.query(
            "label in @calls", inplace=False
        ).drop(columns=["origlabel"])
        # filter annotated labels that start or stop within the sample
        sample_annotated_labels = annotated_labels.query(
            "(start >= @sample_start and start <= @sample_end) or (stop >= @sample_start and stop <= @sample_end)",
        )

        wav_file, _ = load(
            recording_path,
            sr=spectrogram_parameter["sampling_rate"],
            offset=sample_start,
            duration=sample_duration,
            mono=False,
        )
        if wav_file.ndim > 1:
            wav_file = wav_file[sampled_call.channel - 1]

        spectrogram, frequencies, times = calculate_spectrogram(
            wav_file,
            channel=sampled_call.channel,
            spectrogram_parameter=spectrogram_parameter,
        )
        spectrogram, frequencies = preprocess_spectrogram(
            spectrogram, frequencies, spectrogram_parameter
        )

        # adjust aesthetics if not given
        aesthetics.setdefault("time_limits", [sample_start, sample_end])

        return cls(
            sampled_call=sampled_call,
            spectrogram=spectrogram,
            frequencies=frequencies,
            times=times,
            sample_probabilities=sample_probabilities,
            sample_predicted_labels=sample_predicted_labels,
            sample_annotated_labels=sample_annotated_labels,
            calls=calls,
            aesthetics=AnnotationPlotAesthetics(
                **aesthetics,
            ),
        )


def spectrogram_plot(
    ax,
    plot_data: AnnotationPlotData,
    draw_y_ticks=True,
    draw_y_label=False,
):
    """
    Plot the spectrogram on the given axes.
    """
    ax.set_ylim(plot_data.aesthetics.spectrogram_y_limits)
    ax.set_xlim(plot_data.aesthetics.time_limits)
    ax.spines["top"].set_visible(False)
    ax.spines["right"].set_visible(False)
    ax.set_xticks([])

    if draw_y_ticks:
        ax.yaxis.set_ticks_position("left")
        if plot_data.aesthetics.spectrogram_y_ticks is not None:
            ax.set_yticks(
                plot_data.aesthetics.spectrogram_y_ticks,
                labels=plot_data.aesthetics.spectrogram_y_ticks_labels,
            )
    else:
        ax.spines["left"].set_visible(False)
        ax.yaxis.set_ticks([])

    if draw_y_label:
        ax.set_ylabel(plot_data.aesthetics.spectrogram_y_label)
        ax.yaxis.set_label_coords(plot_data.aesthetics.y_axis_label_x_offset, 0.5)

    im = ax.imshow(
        plot_data.spectrogram.T,
        aspect="auto",
        origin="lower",
        extent=[
            *plot_data.aesthetics.time_limits,
            *plot_data.aesthetics.spectrogram_y_limits,
        ],
        cmap=plot_data.aesthetics.spectrogram_cmap,
    )

    return im


def prediction_plot(
    ax,
    plot_data: AnnotationPlotData,
    draw_x_ticks=True,
    draw_x_label=True,
    draw_y_ticks=True,
    draw_y_label=False,
):
    """
    Plot the prediction probabilities on the given axes.
    """
    ax.set_ylim(plot_data.aesthetics.prediction_y_limits)
    ax.set_xlim(plot_data.aesthetics.time_limits)
    ax.spines["top"].set_visible(False)
    ax.spines["right"].set_visible(False)

    if draw_x_ticks:
        ax.xaxis.set_ticks_position("bottom")
    else:
        ax.spines["bottom"].set_visible(False)

    if draw_y_ticks:
        ax.yaxis.set_ticks_position("left")
        if plot_data.aesthetics.prediction_y_ticks is not None:
            ax.set_yticks(
                plot_data.aesthetics.prediction_y_ticks,
                labels=plot_data.aesthetics.prediction_y_ticks_labels,
            )
    else:
        ax.spines["left"].set_visible(False)
        ax.yaxis.set_ticks([])

    if draw_y_label:
        ax.set_ylabel(plot_data.aesthetics.prediction_y_label)
        ax.yaxis.set_label_coords(plot_data.aesthetics.y_axis_label_x_offset, 0.5)
    if draw_x_label:
        ax.set_xlabel(plot_data.aesthetics.time_label)

    for label in plot_data.calls:
        if label in plot_data.sample_probabilities.columns:
            ax.plot(
                plot_data.sample_probabilities["time"],
                plot_data.sample_probabilities[label],
                label=label,
                color=plot_data.aesthetics.call_color(label),
                alpha=plot_data.aesthetics.prediction_line_alpha,
            )
    return ax


def annotation_plot_region(
    ax,
    plot_data: AnnotationPlotData,
):
    ax.axvline(
        x=plot_data.sampled_call.start,
        color=plot_data.aesthetics.call_color(plot_data.sampled_call.label),
        alpha=plot_data.aesthetics.label_region_line_alpha,
        linewidth=plot_data.aesthetics.label_region_line_width,
    )
    ax.axvline(
        x=plot_data.sampled_call.stop,
        color=plot_data.aesthetics.call_color(plot_data.sampled_call.label),
        alpha=plot_data.aesthetics.label_region_line_alpha,
        linewidth=plot_data.aesthetics.label_region_line_width,
    )

    return ax


def annotation_plot_line(
    ax, y, labels, aesthetics: AnnotationPlotAesthetics, show_tick_labels: bool = False
):
    """
    Plot the annotated labels on the given axes.
    """
    ax.set_xlim(aesthetics.time_limits)
    ax.spines["top"].set_visible(False)
    ax.spines["right"].set_visible(False)
    ax.spines["bottom"].set_visible(False)
    ax.spines["left"].set_visible(False)

    if show_tick_labels:
        ax.tick_params(labelleft=True, left=False, labelbottom=False, bottom=False)
    else:
        ax.tick_params(labelleft=False, left=False, labelbottom=False, bottom=False)

    for _, row in labels.iterrows():
        ax.hlines(
            y=y,
            xmin=row["start"],
            xmax=row["stop"],
            color=aesthetics.call_color(row["label"]),
            alpha=aesthetics.annotation_line_alpha,
            linewidth=aesthetics.annotation_line_width,
            linestyles=aesthetics.annotation_line_style,
        )
    return ax


def legend_plot(
    ax,
    aesthetics: AnnotationPlotAesthetics,
):
    """
    Create a legend for the calls.
    """
    handles = [
        Line2D(
            [0],
            [0],
            color=aesthetics.call_color(call),
            lw=2,
            label=call,
        )
        for call in aesthetics.call_colors.keys()
    ]
    ax.legend(handles=handles, loc="center", frameon=False, ncols=len(handles))
    ax.axis("off")
    return ax


def annotation_figure(
    figure: Figure,
    plot_data: AnnotationPlotData,
    figure_title: str,
    draw_y_ticks: bool = True,
    draw_y_axis_label: bool = True,
    draw_x_ticks: bool = True,
    draw_x_axis_label: bool = True,
):
    """
    Create a figure with the spectrogram, annotated labels, and prediction probabilities.
    """

    gs = gridspec.GridSpec(3, 1, height_ratios=[12, 1, 4], hspace=0)
    spectrogram_ax = figure.add_subplot(gs[0])
    spectrogram_plot(
        spectrogram_ax,
        plot_data,
        draw_y_ticks=draw_y_ticks,
        draw_y_label=draw_y_axis_label,
    )
    spectrogram_ax = annotation_plot_region(spectrogram_ax, plot_data)

    labels_ax = figure.add_subplot(gs[1])
    labels_ax = annotation_plot_line(
        labels_ax,
        y="annotated",
        labels=plot_data.sample_annotated_labels,
        aesthetics=plot_data.aesthetics,
        show_tick_labels=False,
    )

    prediction_ax = figure.add_subplot(gs[2])
    prediction_ax = prediction_plot(
        prediction_ax,
        plot_data,
        draw_x_ticks=draw_x_ticks,
        draw_x_label=draw_x_axis_label,
        draw_y_ticks=draw_y_ticks,
        draw_y_label=draw_y_axis_label,
    )
    # handles, labels = prediction_ax.get_legend_handles_labels()
    # figure.legend(handles, labels, ncols=len(calls), loc="lower center")
    if figure_title is not None:
        figure.suptitle(figure_title, fontweight="bold")

    return figure


def filter_calls(df, recording_table, calls):
    """
    Filter calls in the DataFrame based on the recording table.
    """
    recording_type = recording_table.loc[df.index[0]].recording_type
    # no breathing and prey handling sounds in array recordings
    if recording_type == "array":
        possible_calls = [call for call in calls if call not in ["BR", "PHS"]]
    else:
        return df
    return df[df["label"].isin(possible_calls)]
