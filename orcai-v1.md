# orcai-v1 pipeline

## install orcAI

```bash
uv tool install git+https://github.com/ethz-tb/orcAI.git
```

```bash
orcai --version
```

```console
orcai, version 1.1.8
```

## create/update recording table

create recording table from directory with recordings.
update original_recording_table (containing possibilities of calls).
Calls to label are in orcai_parameter_1DC_init_1.json.
Files to exclude are in files_exclude.json.

```bash
orcai create-recording-table Acoustics \
-o recording_table.csv \
-ut original_recording_table.csv \
-p orcai_parameter_1DC_init_1.json \
-ep files_exclude.json \
-up
```

```console
🐳 Creating recording table
orcAI 1.1.8 [started @ 2025-07-14 14:18:49]
🐳 Resolving file paths [0:00:03]
🐳 Filtering 1552 wav files... [0:00:03, 𝚫 0:00:00]
    Remaining files after filtering files that contain ._: 961
    Remaining files after filtering files that contain _ChB: 961
    Remaining files after filtering files that contain _Chb: 961
    Remaining files after filtering files that contain Movie: 961
    Remaining files after filtering files that contain Norway: 961
    Remaining files after filtering files that contain _acceleration: 961
    Remaining files after filtering files that contain _depthtemp: 961
    Remaining files after filtering files that contain _H.: 961
    Remaining files after filtering files that contain _orig: 961
    Remaining files after filtering files that contain _old: 961
🐳 Filtering 897 annotations files... [0:00:03, 𝚫 0:00:00]
    Remaining files after filtering files that contain ._: 502
    Remaining files after filtering files that contain _ChB: 501
    Remaining files after filtering files that contain _Chb: 500
    Remaining files after filtering files that contain Movie: 500
    Remaining files after filtering files that contain Norway: 500
    Remaining files after filtering files that contain _acceleration: 495
    Remaining files after filtering files that contain _depthtemp: 490
    Remaining files after filtering files that contain _H.: 463
    Remaining files after filtering files that contain _orig: 426
    Remaining files after filtering files that contain _old: 391
    ‼️ 4 annotations with missing recordings: {'oo21_184a007', 'oo21_184a006', 'oo21_202b007', 'oo21_189a011'}. These will be ignored.
🐳 Saving recording table to /Volumes/4TB/orcai_project/orca_recordings/recording_table.csv [0:00:03, 𝚫 0:00:00]
    Total recordings: 961
    Total recordins with annotations: 387
🐳 Recordings table created. [0:00:03, 𝚫 0:00:00]
```

## Make spectrograms

Create all spectrograms in recording_table and save to recording_data.
Use orcai_parameter_1DC_init_1.json for spectrogram parameters.
Only for spectrograms with annotations and spectrograms with possible
annotations.

```bash
orcai create-spectrograms recording_table.csv recording_data \
-p orcai_parameter_1DC_init_1.json
```

```console
🐳 Creating spectrograms
orcAI 1.1.8 [started @ 2025-07-14 14:21:18]
🐳 Reading recordings table [0:00:08]
    Excluded 574 recordings because they are not annotated.
    Excluded recordings because they lack any possible annotations:
        ['2015-07-29c' '2015-12-07l' '2015-13-07b' '2015-13-07c' '2015-17-07c'
 '2015-17-07h' '2015-18-07a' '2015-18-07f' '2015-21-07g' '2015-25-07f'
 '2015-25-07i' '2015-25-07j' '2015_07_14b' '2016-05-07C' '2016-12-07C'
 '2016-13-07K' '2016-16-07I' '2016-20-071008' '2016-24-07T323'
 '2016-24-07T328' '2016-25-07T338' '2016-27-07T352' '2016-27-07T363'
 'oo09_200a043' 'oo09_209a012' 'oo14_048a012' 'oo21_175a004'
 'oo21_182a004' 'oo21_184a020' 'oo22_195a004' 'oo22_195a005'
 'oo22_195a006' 'oo22_195a007' 'oo22_195a008' 'oo22_195a009'
 'oo22_195a010' 'oo22_195a011' 'oo22_195a012' 'oo22_195a014'
 'oo22_195a015' 'oo22_228a003' 'oo22_228a005' 'oo23_181a102'
 'oo23_181a105' 'oo23_188a098']
🐳 Creating 342 spectrograms [0:00:08, 𝚫 0:00:00]
Making spectrograms: 100%|███████████████████████████████████████████████████████████████| 342/342 [1:02:19<00:00, 10.93s/it]
🐳 Spectrograms created. [1:02:27, 𝚫 1:02:19]
```

## create label arrays

Create all label arrays for recordings in recording_table and save to recording_data.
Use orcai_parameter_1DC_init_1.json for parameters.
Unify call labels according call_equivalences.json.

```bash
orcai create-label-arrays recording_table.csv recording_data \
-p orcai_parameter_1DC_init_1.json \
-ce call_equivalences.json
```

```console
🐳 Creating label arrays
orcAI 1.1.8 [started @ 2025-07-14 15:25:19]
🐳 Reading recordings table [0:00:03]
    Skipping 574 because of missing annotation files.
    Skipping 0 recordings because they already have Labels.
🐳 Making label arrays [0:00:03, 𝚫 0:00:00]
Making label arrays: 100%|██████████████████████████████████████████████████████████| 387/387 [00:51<00:00,  7.46recording/s]
    ‼️ No valid labels present in ['2015-07-29c', '2015-12-07l', '2015-13-07b', '2015-13-07c', '2015-17-07c', '2015-17-07h', '2015-18-07a', '2015-18-07f', '2015-21-07g', '2015-25-07f', '2015-25-07i', '2015-25-07j', '2015_07_14b', '2016-05-07C', '2016-12-07C', '2016-13-07K', '2016-16-07I', '2016-20-071008', '2016-24-07T323', '2016-24-07T328', '2016-25-07T338', '2016-27-07T352', '2016-27-07T363', 'oo09_200a043', 'oo09_209a012', 'oo14_048a012', 'oo21_175a004', 'oo21_182a004', 'oo21_184a020', 'oo22_195a004', 'oo22_195a005', 'oo22_195a006', 'oo22_195a007', 'oo22_195a008', 'oo22_195a009', 'oo22_195a010', 'oo22_195a011', 'oo22_195a012', 'oo22_195a014', 'oo22_195a015', 'oo22_228a003', 'oo22_228a005', 'oo23_181a102', 'oo23_181a105', 'oo23_188a098']
🐳 Finished making label arrays [0:00:55, 𝚫 0:00:52]
```

## create snippets

```bash
orcai create-snippet-table recording_table.csv recording_data \
-p orcai_parameter_1DC_init_1.json
```

```console
 Creating snippet table
orcAI 1.1.8 [started @ 2025-07-14 15:26:42]
🐳 Reading recording table [0:00:02]
    ‼️ Missing recording data directories for 45 recordings. Skipping these recordings.
    ‼️ Did you create the spectrograms & Labels?
🐳 Making snippet tables [0:00:02, 𝚫 0:00:00]
Making snippet tables: 100%|████████████████████████████████████████████████████████| 342/342 [20:36<00:00,  3.61s/recording]
    Created snippet table for 333 recordings.
    Total recording duration: 235:54:10.
    Total number of snippets: 2434541.
    Total number of segments: 4092
    Creating snippet table failed for 9 recordings.
        reason
        shorter than segment_duration    9
🐳 Saving snippet table... [0:20:39, 𝚫 0:20:36]
🐳 Snippet table saved to /Volumes/4TB/orcai_project/orca_recordings/tvt_data/all_snippets.csv.gz [0:20:48, 𝚫 0:00:09]
```

## create tvt snippet tables

Create snippet tables for training, validation and test dataset. Create an additional unfiltered test data set (-uts)

```bash
orcai create-tvt-snippet-tables tvt_data -p orcai_parameter_1DC_init_1.json -uts
```

```console
🐳 Creating train, validation and test snippet tables
orcAI 1.1.8 [started @ 2025-07-14 15:48:24]
🐳 Reading snippet table [0:00:03]
    Snippet stats [HMS]:
        data_type     train       val      test     total
        BR         02:21:17  00:17:41  00:16:09  02:55:08
        BUZZ       06:18:07  00:48:16  00:35:34  07:41:57
        HERDING    01:39:27  00:13:32  00:12:29  02:05:28
        PHS        00:43:55  00:04:46  00:02:38  00:51:21
        SS         66:12:58  08:14:02  08:19:46  82:46:47
        TAILSLAP   00:51:30  00:07:25  00:06:54  01:05:51
        WHISTLE    00:20:01  00:02:23  00:02:44  00:25:09
🐳 Filtering snippet table [0:00:04, 𝚫 0:00:01]
    Percentage of snippets containing no label before selection: 88.52 %
    removing 99.0% of snippets without label
    Percentage of snippets containing no label after selection: 7.16 %
    Number of train, val, test snippets:
        data_type
        test      30154
        train    241024
        val       29940
    Extracting 3750 batches of 64 random train snippets (240000 snippets)
    saved train snippets to disk
    Extracting 375 batches of 64 random val snippets (24000 snippets)
    saved val snippets to disk
    Extracting 375 batches of 64 random test snippets (24000 snippets)
    saved test snippets to disk
    Snippet stats for train, val and test datasets [HMS]:
        data_type     train       val      test     total
        BR         02:20:39  00:14:14  00:12:57  02:47:51
        BUZZ       06:16:55  00:38:17  00:29:04  07:24:17
        HERDING    01:39:11  00:10:51  00:10:07  02:00:09
        PHS        00:43:46  00:03:41  00:02:06  00:49:34
        SS         65:55:49  06:37:10  06:37:12  79:10:12
        TAILSLAP   00:51:26  00:05:45  00:05:33  01:02:44
        WHISTLE    00:19:57  00:01:50  00:02:08  00:23:56
    Extracting 240000 unfiltered test snippets
    saved unfiltered test snippets to disk
🐳 All snippet tables created and saved to disk [0:00:07, 𝚫 0:00:03]
```

## create tvt data

```bash
orcai create-tvt-data tvt_data -p orcai_parameter_1DC_init_1.json
```

```console
🐳 Creating train, validation and test datasets
orcAI 1.1.8 [started @ 2025-07-14 15:50:12]
🐳 Reading in snippet tables and generating loaders [0:00:03]
Creating loaders: 4/4
    Data shape:
        Input spectrogram batch shape: (736, 171, 1)
        Input label batch shape: (46, 7)
🐳 Creating test, validation and training datasets [0:05:26, 𝚫 0:05:23]
    Train dataset created. Length 240000.
    Val dataset created. Length 24000.
    Test dataset created. Length 24000.
    Test_unfiltered dataset created. Length 240000.
🐳 Saving datasets to disk [0:05:26, 𝚫 0:00:00]
    Size on disk of train_dataset: 34.75 GB
    Size on disk of val_dataset: 3.47 GB
    Size on disk of test_dataset: 3.38 GB
    Size on disk of test_unfiltered_dataset: 32.71 GB
🐳 Train, validation and test datasets created and saved to disk [1:05:13, 𝚫 0:59:47]
```

zip all data to move it to cluster

```bash
zip -r orcai_tvt_data_3750.zip tvt_data
```

## running hyperparameter search

Run on ETHZ Euler cluster with GPU. Using scripts in [model_training_scripts](model_training_scripts)

```bash
# setup env
bash setup_env.sh

# submit job
sbatch hpsearch_orcai.sh
```

log output is in [hyperparameter_search/orcai-v1-3750-LSTM_HPS/logs/hpsearch.log](hyperparameter_search/orcai-v1-3750-LSTM_HPS/logs/hpsearch.log)

## train & test models

Run on ETHZ Euler cluster with GPU. Using scripts in [model_training_scripts](model_training_scripts)

```bash
# setup env
bash setup_env.sh

# submit job
sbatch train_all_v1.sh
```

log output is in e.g. [trained_models/orcai-v1_1/logs/training_output.log](trained_models/orcai-v1_1/logs/training_output.log)
