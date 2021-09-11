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
echo topology=$top
res='residues'
echo residues=$res
inp='rst'
echo input restart=$inp
out='trajectory'
echo output trajectory=$out
folder='folder'
#dependency='jobID'

# Move files to scratch
echo -e "\n##################################################"
echo "Moving files to scratch"
echo -e "##################################################\n"
mkdir -p /scratch/$USER/$SLURM_JOB_ID
cp ~/${folder}/{md.in,${top}.prmtop,${inp}.rst} /scratch/$USER/$SLURM_JOBID/
#cp ~/${folder}/${dependency}/${inp}/{md.in,${top}.prmtop,${inp}.rst} /scratch/$USER/$SLURM_JOBID/
cd /scratch/$USER/$SLURM_JOB_ID

# RUN MD
echo -e "\n##################################################"
date;echo "Running first MD"
echo -e "##################################################\n"
pmemd.cuda -O -i md.in -o ${out}.out -p ${top}.prmtop -c ${inp}.rst -r ${out}.rst -x ${out}.nc -inf ${out}.mdinfo

# Process trajectory
echo -e "\n##################################################"
date;echo "Processing first MD"
echo -e "##################################################\n"
strip-traj.sh -p ${top}.prmtop -t ${out}.nc
analyze-traj.sh -p ${top}.prmtop -t ${out}_dry.nc -r ${res}
reduce-traj.sh -p ${top}.prmtop -t ${out}_dry.nc

# Recover files and remove from scratch
echo -e "\n##################################################"
date;echo "Recovering data from scratch"
echo -e "##################################################\n"
mkdir -p ~/$folder/$SLURM_JOB_ID/${out}
cp /scratch/$USER/$SLURM_JOB_ID/* ~/$folder/$SLURM_JOB_ID/${out}
rm -rf /scratch/$USER/$SLURM_JOB_ID/*

# Send email
echo -e "Subject: Run $out finished in ClusterUY" | sendmail a@gmail.com


# Define names
inp=$out
out='trajectory'

# Move files to scratch
echo -e "\n##################################################"
date;echo "Moving files to scratch"
echo -e "##################################################\n"
cp ~/$folder/$SLURM_JOB_ID/${inp}/{md.in,${top}.prmtop,${inp}.rst} /scratch/$USER/$SLURM_JOBID/

# RUN MD
echo -e "\n##################################################"
date;echo "Running second MD"
echo -e "##################################################\n"
pmemd.cuda -O -i md.in -o ${out}.out -p ${top}.prmtop -c ${inp}.rst -r ${out}.rst -x ${out}.nc -inf ${out}.mdinfo

# Process trajectory
echo -e "\n##################################################"
date;echo "Processing second MD"
echo -e "##################################################\n"
strip-traj.sh -p ${top}.prmtop -t ${out}.nc
analyze-traj.sh -p ${top}.prmtop -t ${out}_dry.nc
reduce-traj.sh -p ${top}.prmtop -t ${out}_dry.nc

# Recover files and remove from scratch
echo -e "\n##################################################"
date;echo "Recovering data from scratch"
echo -e "##################################################\n"
mkdir -p ~/$folder/$SLURM_JOB_ID/${out}
cp /scratch/$USER/$SLURM_JOB_ID/* ~/$folder/$SLURM_JOB_ID/${out}
rm -rf /scratch/$USER/$SLURM_JOB_ID

# Send email
echo -e "Subject: Run $out finished in ClusterUY" | sendmail a@gmail.com
