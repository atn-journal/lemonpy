#!/bin/bash
#SBATCH --job-name=MD
#SBATCH --time=100:00:00
#SBATCH --tmp=50G
#SBATCH --mail-user=a@gmail.com
##SBATCH --dependency=afterok:JOBID
#SBATCH --partition=normal
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --qos=gpu
#SBATCH --gres=gpu:1
#SBATCH --mail-type=BEGIN,END,FAIL

echo $SLURM_JOB_ID; hostname; date

# Load modules
source /etc/profile.d/modules.sh

# Load AMBER
module use /clusteruy/home03/biosim_ip/modulefiles
module load amber18-tools19

# Define names
top='basename_of_prmtop'
inp='basename_of_input_coord'
out='basename_of_output_trajectory'

# Move files to scratch
echo Moving files to scratch; date
mkdir -p /scratch/$USER/$SLURM_JOB_ID
#cp ~/PATH/{md.in,${top}.prmtop,${inp}.rst} /scratch/$USER/$SLURM_JOBID/
#cp ~/JOBID/${inp}/{md.in,${top}.prmtop,${inp}.rst} /scratch/$USER/$SLURM_JOBID/
cd /scratch/$USER/$SLURM_JOB_ID

# RUN MD
echo Runnning first MD; date
pmemd.cuda -O -i md.in -o ${out}.out -p ${top}.prmtop -c ${inp}.rst -r ${out}.rst -x ${out}.nc

# Process trajectory
echo Processing first MD; date
strip-traj.sh -p ${top}.prmtop -t ${out}.nc
analyze-traj.sh -p ${top}.prmtop -t ${out}_dry.nc
reduce-traj.sh -p ${top}.prmtop -t ${out}_dry.nc

# Recover files and remove from scratch
echo Recovering data from scratch; date
mkdir -p ~/$SLURM_JOB_ID/${out}
cp /scratch/$USER/$SLURM_JOB_ID/* ~/$SLURM_JOB_ID/${out}
rm -rf /scratch/$USER/$SLURM_JOB_ID/*



# Define names
inp=$out
out='basename_of_output_trajectory'

# Move files to scratch
echo Moving files to scratch; date
cp ~/$SLURM_JOB_ID/${inp}/{md.in,${top}.prmtop,${inp}.rst} /scratch/$USER/$SLURM_JOBID/

# RUN MD
echo Runnning second MD; date
pmemd.cuda -O -i md.in -o ${out}.out -p ${top}.prmtop -c ${inp}.rst -r ${out}.rst -x ${out}.nc

# Process trajectory
echo Processing second MD; date
strip-traj.sh -p ${top}.prmtop -t ${out}.nc
analyze-traj.sh -p ${top}.prmtop -t ${out}_dry.nc
reduce-traj.sh -p ${top}.prmtop -t ${out}_dry.nc

# Recover files and remove from scratch
echo Recovering data from scratch; date
mkdir -p ~/$SLURM_JOB_ID/${out}
cp /scratch/$USER/$SLURM_JOB_ID/* ~/$SLURM_JOB_ID/${out}
rm -rf /scratch/$USER/$SLURM_JOB_ID
