#!/usr/bin/bash
#SBATCH --job-name=orcai-hpsearch
#SBATCH --output=/cluster/home/angstd/orcAI/20250428_orcai/logs/hpsearch_%j.log
#SBATCH --tmp=80G

#SBATCH --gpus=4
#SBATCH --time=96:00:00
#SBATCH --mem-per-cpu=24g
#SBATCH --gres=gpumem:24g
module load stack/2024-06 gcc/12.2.0 openblas/0.3.24 cuda/12.4.1 python_cuda/3.11.6 py-pip
export XLA_FLAGS=--xla_gpu_cuda_data_dir=$CUDA_EULER_ROOT
export CUDA_DIR=$CUDA_EULER_ROOT
source /cluster/home/angstd/orcAI/venv/bin/activate

SOURCE_FILE="/nfs/nas22/fs2201/usys_ibz_tb_data/TB-data/Daniel_Angst/orcAI/orcai_tvt_data_3750.zip"
filename=$(basename -- "$SOURCE_FILE")

rsync_cmd="rsync -avz $SOURCE_FILE $TMPDIR"
echo -e "\nrunning $rsync_cmd\n"
eval $rsync_cmd

unzip_cmd="unzip $TMPDIR/$filename -d $TMPDIR"
echo -e "\nrunning $unzip_cmd\n"
eval $unzip_cmd

data_dir="$TMPDIR"
output_dir="/cluster/home/angstd/orcAI/20250428_orcai"
parameter_file="$output_dir/orcai_parameter_HPS.json"
hps_parameter_file="$output_dir/hps_parameter.json"

hp_search_cmd="orcai hpsearch $data_dir $output_dir -p $parameter_file -hp $hps_parameter_file -pl"
echo -e "\nrunning $hp_search_cmd\n"
orcai --version
eval $hp_search_cmd
