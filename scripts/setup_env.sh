#!/usr/bin/bash
module load stack/2024-06 gcc/12.2.0 openblas/0.3.24 cuda/12.4.1 python_cuda/3.11.6 py-pip
export XLA_FLAGS=--xla_gpu_cuda_data_dir=$CUDA_EULER_ROOT
export CUDA_DIR=$CUDA_EULER_ROOT
python -m venv venv
source venv/bin/activate

pip install -U git+https://gitlab.ethz.ch/tb/orcai.git
orcai --version
