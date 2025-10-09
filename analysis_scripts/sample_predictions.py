from pathlib import Path

import numpy as np
import pandas as pd
from prediction_plots_fn import (
    CALLS,
    filter_calls,
)

N_PREDICTIONS = 5  # Number of calls to sample from each bin
BINS = [0.5, 0.6, 0.7, 0.8, 0.9, 1.0]
BINS_LABELS = [
    "(0.5-0.6]",
    "(0.6-0.7]",
    "(0.7-0.8]",
    "(0.8-0.9]",
    "(0.9-1.0]",
]

# Seed generated using np.random.SeedSequence().entropy on 2025-07-09
rng = np.random.default_rng(seed=221213288706888228578119251711734307995)

# load recording table
recording_table = pd.read_csv(
    "/Volumes/4TB/orcai_project/orca_recordings/recording_table_ISL.csv",
    dtype={
        "recording": str,
        "base_dir_recording": str,
        "rel_recording_path": str,
        "channel": int,
    },
).set_index("recording")
recording_table["recording_path"] = recording_table.apply(
    lambda row: Path(row["base_dir_recording"], row["rel_recording_path"]), axis=1
)
recording_type = pd.read_csv(
    "/Volumes/4TB/orcai_project/orca_recordings/original_recording_table_ISL.csv",
    usecols=["recording", "recording_type"],
).set_index("recording")

recording_table = recording_table.join(recording_type, how="left")

# Select calls to predict
all_predicted_calls = pd.read_csv(Path("data/all_predictions.csv")).set_index(
    "recording"
)

# filter out predictions of calls in files where these calls can't be recorded
all_predicted_calls_filtered = (
    all_predicted_calls.groupby("recording")
    .apply(lambda df: filter_calls(df, recording_table, CALLS), include_groups=False)
    .reset_index(level=0)
    .reset_index(drop=True)
)

# select from bins
all_predicted_calls_filtered["mean_p_bin"] = pd.cut(
    all_predicted_calls_filtered["mean_p"],
    bins=BINS,
    include_lowest=True,
    labels=BINS_LABELS,
)

all_predicted_calls_filtered.groupby(
    ["label", "mean_p_bin"], observed=False
).size().sort_index()

sampled_calls = (
    all_predicted_calls_filtered.groupby(["label", "mean_p_bin"], observed=True)
    .apply(
        lambda x: x.sample(min(N_PREDICTIONS, len(x)), random_state=rng),
        include_groups=False,
    )
    .reset_index()
)

sampled_calls = sampled_calls.join(
    recording_table[["recording_path", "channel"]],
    on="recording",
    how="left",
)

sampled_calls["sample_index"] = sampled_calls.groupby(
    ["label", "mean_p_bin"], observed=True
).cumcount()

sampled_calls["mean_p_bin_index"] = (
    sampled_calls["mean_p_bin"].astype("category").cat.codes
)

# with pd.option_context('display.max_rows', None):
#     print(sampled_calls)

# print(f"Total sampled calls: {len(sampled_calls)}")
# print("Samples per group:")
# print(sampled_calls.groupby(["label", "mean_p_bin"], observed=True).size().sort_index())

all_predicted_calls_filtered.to_csv(
    Path("analysis_scripts", "output", "csv", "all_predicted_calls.csv"),
)
sampled_calls.to_csv(Path("analysis_scripts", "output", "csv", "sampled_calls.csv"))
