#!/bin/bash
#SBATCH --job-name=MD                             #
#SBATCH --time=100:00:00                          #
#SBATCH --tmp=50G                                 #
#SBATCH --mail-user=a@gmail.com                   #
##SBATCH --dependency=afterok:JOBID                #
#SBATCH --partition=normal
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --qos=gpu
#SBATCH --gres=gpu:1
#SBATCH --mail-type=BEGIN,END,FAIL
#SBATCH --output=%j.log

echo $SLURM_JOB_ID; hostname; date

# Load modules
source /etc/profile.d/modules.sh

# Load AMBER
module use /clusteruy/home03/biosim_ip/modulefiles
module load amber18-tools19

# Define names
top='basename_of_prmtop'                   #
inp='basename_of_input_coord'              #
out='basename_of_output_trajectory'        #

# Move files to scratch
mkdir /scratch/$USER/$SLURM_JOB_ID
cp ~/JOBID/${inp}/{md.in,${top}.prmtop,${inp}.rst,strip-traj.sh} /scratch/$USER/$SLURM_JOBID/     #
cd /scratch/$USER/$SLURM_JOB_ID

# RUN MD
pmemd.cuda -O -i md.in -o ${out}.out -p ${top}.prmtop -c ${inp}.rst -r ${out}.rst -x ${out}.nc  # Beware that first MD run uses coordinates with .inpcrd extension

# Reduce trajectory filesize
./strip-traj.sh -p ${top}.prmtop -t ${out}.nc

# Recover files and remove from scratch
mkdir -p ~/$SLURM_JOB_ID/${out}
cp /scratch/$USER/$SLURM_JOB_ID/* ~/$SLURM_JOB_ID/${out}
rm -rf /scratch/$USER/$SLURM_JOB_ID
