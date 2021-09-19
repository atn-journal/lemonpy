#!/bin/bash
#SBATCH --job-name=ID-Xns
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
#SBATCH --output=%x.out

echo job_ID=$SLURM_JOB_ID
hostname

# Load modules
source /etc/profile.d/modules.sh

# Load AMBER
module use /clusteruy/home03/biosim_ip/modulefiles
module load amber18-tools19

####################################################################################
####################################################################################
# Define basenames, input time, T (in K, integer), path (no trailing '/') and email
top='prmtop'
inp='rst'
ns_in='0'
temp='temperature'
path='path'
ID='ID'
email='@'
####################################################################################
####################################################################################

if test $ns_in -eq 0
then
  ns_out=050
else
  ns_out=$(($ns_in+50))
fi

output=${prmtop}_md${ns_out}ns-${temp}K

echo topology=$top
echo input=$inp
echo output=$output
echo path=$path
echo ID=$notebook

# Move files to scratch
mkdir -p /scratch/$USER/$SLURM_JOB_ID
cp ${path}/{${top}.prmtop,${inp}.rst} /scratch/$USER/$SLURM_JOBID/
cd /scratch/$USER/$SLURM_JOB_ID

# Create MD input file
cat << EOF > md.in
Molecular dynamics production of 50 ns
  &cntrl
    ntx=5,irest=1,
    t=0.0,dt=0.002,nstlim=25000000,
    temp0=${temp}.0,ntt=3,ig=-1,gamma_ln=5.0,
    pres0=1.0,ntp=1,barostat=1,taup=5.0,
    ntc=2,ntf=2,
    iwrap=1,
    nscm=5000,
    cut=9.0,
    ntpr=500,ntwr=12500000,ntwx=500,
  /

EOF

# RUN MD
echo -e "\n##################################################"
date
echo "Running first MD"
echo -e "##################################################\n"
pmemd.cuda -O -i md.in -o ${output}.out -p ${top}.prmtop -c ${inp}.rst -r ${output}.rst -x ${output}.nc -inf ${output}.mdinfo

# Recover files and remove from scratch
cp /scratch/$USER/$SLURM_JOB_ID/* $path/
rm -rf /scratch/$USER/$SLURM_JOB_ID/*

# Send email
echo -e "Subject: Run $output from $ID finished in ClusterUY" | sendmail $email

# Second MD
# Define names
inp=$output
ns_in=$ns_out
ns_out=$(($ns_in+50))
output=${prmtop}_md${ns_out}ns-${temp}K

echo new input=$inp
echo new output=$output

# Move files to scratch
cp $path/{md.in,${top}.prmtop,${inp}.rst} /scratch/$USER/$SLURM_JOBID/

# RUN MD
echo -e "\n##################################################"
date
echo "Running second MD"
echo -e "##################################################\n"
pmemd.cuda -O -i md.in -o ${output}.out -p ${top}.prmtop -c ${inp}.rst -r ${output}.rst -x ${output}.nc -inf ${output}.mdinfo

echo $output finished

# Recover files and remove from scratch
cp /scratch/$USER/$SLURM_JOB_ID/* $path/
rm -rf /scratch/$USER/$SLURM_JOB_ID

# Send email
echo -e "Subject: Run $output from $ID finished in ClusterUY" | sendmail $email
