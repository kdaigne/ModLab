#!/bin/bash
#SBATCH -J 
#SBATCH --account=
#SBATCH --partition=medium
#SBATCH --time='4-00:00:00'
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=20
#SBATCH --mem=8000
#SBATCH --mail-type=FAIL
#SBATCH --mail-type=TIME_LIMIT
#SBATCH --mail-user=
#SBATCH --output=/dev/null --error=/dev/null
#SBATCH -e stderr_%j.txt

echo "Starting at `date`"
echo "Running on hosts : $SLURM_NODELIST"
echo "Running on $SLURM_NNODES nodes."
echo "Running on $SLURM_NPROCS processors."

export OMP_NUM_THREAD=$SLURM_CPUS_PER_TASK
./MELODY_2D_3.95 00000
