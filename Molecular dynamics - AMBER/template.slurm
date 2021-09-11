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

echo $SLURM_JOB_ID; hostname;

# Load modules
source /etc/profile.d/modules.sh

# Load AMBER
module use /clusteruy/home03/biosim_ip/modulefiles
module load amber18-tools19

# Define names
top='basename_of_prmtop'
inp='basename_of_input_coord'
out='basename_of_output_trajectory'
folder='folder'
dependency='previous_job_ID'

# Move files to scratch
echo "####################";Moving files to scratch
mkdir -p /scratch/$USER/$SLURM_JOB_ID
#cp ~/${folder}/{md.in,${top}.prmtop,${inp}.rst} /scratch/$USER/$SLURM_JOBID/
#cp ~/${folder}/${dependency}/${inp}/{md.in,${top}.prmtop,${inp}.rst} /scratch/$USER/$SLURM_JOBID/
cd /scratch/$USER/$SLURM_JOB_ID

# RUN MD
echo "####################";date;Runnning first MD
pmemd.cuda -O -i md.in -o ${out}.out -p ${top}.prmtop -c ${inp}.rst -r ${out}.rst -x ${out}.nc

# Process trajectory
echo "####################";date;Processing first MD
strip-traj.sh -p ${top}.prmtop -t ${out}.nc
analyze-traj.sh -p ${top}.prmtop -t ${out}_dry.nc
reduce-traj.sh -p ${top}.prmtop -t ${out}_dry.nc

# Recover files and remove from scratch
echo "####################";date;Recovering data from scratch
mkdir -p ~/$folder/$SLURM_JOB_ID/${out}
cp /scratch/$USER/$SLURM_JOB_ID/* ~/$folder/$SLURM_JOB_ID/${out}
rm -rf /scratch/$USER/$SLURM_JOB_ID/*



# Define names
inp=$out
out='basename_of_output_trajectory'

# Move files to scratch
echo "####################";date;Moving files to scratch
cp ~/$folder/$SLURM_JOB_ID/${inp}/{md.in,${top}.prmtop,${inp}.rst} /scratch/$USER/$SLURM_JOBID/

# RUN MD
echo "####################";date;Runnning second MD
pmemd.cuda -O -i md.in -o ${out}.out -p ${top}.prmtop -c ${inp}.rst -r ${out}.rst -x ${out}.nc

# Process trajectory
echo "####################";date;Processing second MD
strip-traj.sh -p ${top}.prmtop -t ${out}.nc
analyze-traj.sh -p ${top}.prmtop -t ${out}_dry.nc
reduce-traj.sh -p ${top}.prmtop -t ${out}_dry.nc

# Recover files and remove from scratch
echo "####################";date;Recovering data from scratch
mkdir -p ~/$folder/$SLURM_JOB_ID/${out}
cp /scratch/$USER/$SLURM_JOB_ID/* ~/$folder/$SLURM_JOB_ID/${out}
rm -rf /scratch/$USER/$SLURM_JOB_ID
