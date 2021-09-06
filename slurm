#!/bin/bash
#SBATCH --job-name=MD                             #
#SBATCH --partition=normal
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --qos=gpu
#SBATCH --gres=gpu:1
#SBATCH --time=55:00:00                           #
#SBATCH --tmp=50G                                 #
#SBATCH --mail-type=BEGIN,END,FAIL
#SBATCH --mail-user=a@b.com                       #

# Load modules
source /etc/profile.d/modules.sh

# Load AMBER
module use /clusteruy/home03/biosim_ip/modulefiles
module load amber18-tools19

# Move files to scratch
mkdir /scratch/$USER/$SLURM_JOB_ID
cp ~/path/to/archivos /scratch/$USER/$SLURM_JOBID/     #
cd /scratch/$USER/$SLURM_JOB_ID

# Define names
top='basename_of_prmtop'            #
crd='filename_of_coord'             #
trj='basename_of_trajectory'        #

# RUN MD
pmemd.cuda -O -i md.in -o md.out -p ${top}.prmtop -c ${crd} -r ${trj}.rst -x ${trj}.nc

# Reduce trajectory filesize
./strip-traj.sh -p ${top} -t ${trj}

# Recover files and remove from scratch
mkdir ~/$SLURM_JOB_ID
cp /scratch/$USER/$SLURM_JOB_ID/* ~/$SLURM_JOB_ID
rm -rf /scratch/$USER/$SLURM_JOB_ID
