#!/usr/bin/bash
sbatch train_1DC_1.sh
sbatch train_1DC_2.sh
sbatch train_1DC_3.sh

sbatch train_LSTM_1.sh
sbatch train_LSTM_2.sh
sbatch train_LSTM_3.sh
