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
#SBATCH --mail-type=FAIL
#SBATCH --output=%x.out

####################################################################################
####################################################################################
# Define basenames, input time, T (in K, integer), path (no trailing '/') and email
prmtop='prmtop'
ns_in='0'
temp='temperature'
path='path'
ID='ID'
email='@'
####################################################################################
####################################################################################

echo job_ID=$SLURM_JOB_ID
hostname

# Load modules
source /etc/profile.d/modules.sh

# Load AMBER
module use /clusteruy/home03/biosim_ip/modulefiles
module load amber18-tools19

ns_out=$(($ns_in+50))
if test $ns_in -eq 0
then
    coord=${prmtop}_eq
    output=${prmtop}_md0${ns_out}ns-${temp}K
else
    coord=${prmtop}_md${ns_in}ns-${temp}K
    output=${prmtop}_md${ns_out}ns-${temp}K
fi

echo topology=$prmtop
echo input=$coord
echo output=$output
echo path=$path
echo ID=$ID

# Move files to scratch
mkdir -p /scratch/$USER/$SLURM_JOB_ID
cp ${path}/{${prmtop}.prmtop,${coord}.rst} /scratch/$USER/$SLURM_JOBID/
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

echo -e "Subject: Run $output from $ID started in ClusterUY" | sendmail $email

# RUN MD
echo -e "\n##################################################"
date
echo "Running $output"
echo -e "##################################################\n"
pmemd.cuda -O -i md.in -o ${output}.out -p ${prmtop}.prmtop -c ${coord}.rst -r ${output}.rst -x ${output}.nc -inf ${output}.mdinfo

# Recover files and remove from scratch
cp /scratch/$USER/$SLURM_JOB_ID/* $path/
rm -rf /scratch/$USER/$SLURM_JOB_ID/*

# Send email
echo -e "Subject: Run $output from $ID finished in ClusterUY" | sendmail $email

echo -e "\n############################################################"
date
echo "$output finished"
tail -n 18 $output.out
echo -e "############################################################\n"

# Re-define names
coord=$output
ns_in=$ns_out
ns_out=$(($ns_in+50))
output=${prmtop}_md${ns_out}ns-${temp}K

echo new input=$coord
echo new output=$output

# Move files to scratch
cp $path/{md.in,${prmtop}.prmtop,${coord}.rst} /scratch/$USER/$SLURM_JOBID/

echo -e "Subject: Run $output from $ID started in ClusterUY" | sendmail $email

# RUN MD
echo -e "\n##################################################"
date
echo "Running $output"
echo -e "##################################################\n"
pmemd.cuda -O -i md.in -o ${output}.out -p ${prmtop}.prmtop -c ${coord}.rst -r ${output}.rst -x ${output}.nc -inf ${output}.mdinfo

# Recover files and remove from scratch
cp /scratch/$USER/$SLURM_JOB_ID/* $path/
rm -rf /scratch/$USER/$SLURM_JOB_ID

# Send email
echo -e "Subject: Run $output from $ID finished in ClusterUY" | sendmail $email

echo -e "\n############################################################"
date
echo "$output finished"
tail -n 18 $output.out
echo -e "############################################################\n"
