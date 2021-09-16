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
#SBATCH --mail-type=BEGIN,FAIL

echo $SLURM_JOB_ID
hostname
date

# Load modules
source /etc/profile.d/modules.sh

# Load AMBER
module use /clusteruy/home03/biosim_ip/modulefiles
module load amber18-tools19

# Define basenames
top='prmtop'
res='residues'
inp='rst'
out='trajectory'
path='path'

echo topology=$top
echo residues=$res
echo input restart=$inp
echo output trajectory=$out
echo path=$path

# Move files to scratch
mkdir -p /scratch/$USER/$SLURM_JOB_ID
cp ${path}/{md.in,${top}.prmtop,${inp}.rst} /scratch/$USER/$SLURM_JOBID/
cd /scratch/$USER/$SLURM_JOB_ID

# RUN MD
echo -e "\n##################################################"
date;echo "Running first MD"
echo -e "##################################################\n"
pmemd.cuda -O -i md.in -o ${out}.out -p ${top}.prmtop -c ${inp}.rst -r ${out}.rst -x ${out}.nc -inf ${out}.mdinfo

# Recover files and remove from scratch
mkdir -p $path/${out}
cp /scratch/$USER/$SLURM_JOB_ID/* $path/${out}/
rm -rf /scratch/$USER/$SLURM_JOB_ID/*

# Send email
echo -e "Subject: Run $out finished in ClusterUY" | sendmail a@gmail.com

# Second MD

# Define names
inp=$out
out='trajectory'

# Move files to scratch
cp $path/${inp}/{md.in,${top}.prmtop,${inp}.rst} /scratch/$USER/$SLURM_JOBID/

# RUN MD
echo -e "\n##################################################"
date;echo "Running second MD"
echo -e "##################################################\n"
pmemd.cuda -O -i md.in -o ${out}.out -p ${top}.prmtop -c ${inp}.rst -r ${out}.rst -x ${out}.nc -inf ${out}.mdinfo

# Recover files and remove from scratch
mkdir -p $path/${out}
cp /scratch/$USER/$SLURM_JOB_ID/* $path/${out}/
rm -rf /scratch/$USER/$SLURM_JOB_ID

# Send email
echo -e "Subject: Run $out finished in ClusterUY" | sendmail a@gmail.com
