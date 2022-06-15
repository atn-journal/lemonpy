#!/bin/bash
#SBATCH --job-name=ID-postrun
#SBATCH --time=10:00:00
#SBATCH --partition=normal
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --qos=normal
#SBATCH --mail-user=ariel.tijman@gmail.com
#SBATCH --mail-type=FAIL
#SBATCH --output=%x.out

#######################################################################
#######################################################################
# Define variables
prmtop=''
temp=
ns=
strip='WAT,Na+,Cl-'
#######################################################################
#######################################################################

echo job_ID=$SLURM_JOB_ID
hostname
email=`grep -m 1 mail-user $SLURM_JOB_NAME.slurm | cut -d = -f2`

# Load modules
source /etc/profile.d/modules.sh

# Load AMBER
module use /clusteruy/home03/biosim_ip/modulefiles
module load amber18-tools19

echo topology=$prmtop

# Write out scripts
cat << EOF > postrun1.in
parm ${prmtop}.prmtop
trajin *md*ns-${temp}K.nc
autoimage
strip :$strip parmout ${prmtop}-dry.prmtop
trajout ${prmtop}-md${ns}ns-${temp}K-dry-c10ps.nc netcdf
run
EOF

cat << EOF > postrun2.in
parm ${prmtop}-dry.prmtop
trajin ${prmtop}-md${ns}ns-${temp}K-dry-c10ps.nc 1 last 100
autoimage
trajout ${prmtop}-md${ns}ns-${temp}K-dry-c1000ps.nc netcdf
run
EOF

# Execute scripts and notify
cpptraj -i postrun1.in

if [ $? -eq 0 ]
then
    cpptraj -i postrun2.in
    if [ $? -eq 0 ]
    then
        echo -e "Subject: Run $SLURM_JOB_NAME finished in ClusterUY" | sendmail $email
    else
        echo -e "Subject: FAILED $SLURM_JOB_NAME postrun2" | sendmail $email
    fi
else
    echo -e "Subject: FAILED $SLURM_JOB_NAME postrun1" | sendmail $email
fi
