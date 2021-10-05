#!/bin/bash
#SBATCH --job-name=ID-join-1us-traj
#SBATCH --time=20:00:00
#SBATCH --mail-user=a@gmail.com
#SBATCH --partition=normal
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --qos=normal
#SBATCH --mail-type=FAIL
#SBATCH --output=%x.out

#######################################################################
#######################################################################
# Define topology, T (in K, integer), path (no trailing '/') and email
prmtop='prmtop'
temp='temperature'
email='@'
#######################################################################
#######################################################################

echo job_ID=$SLURM_JOB_ID
hostname

# Load modules
source /etc/profile.d/modules.sh

# Load AMBER
module use /clusteruy/home03/biosim_ip/modulefiles
module load amber18-tools19

echo topology=$prmtop
echo ID=$ID

# Write out script
cat << EOF > join.in
parm ${prmtop}.prmtop
trajin *md*ns-${temp}K.nc
autoimage
strip :WAT
strip :Na+
strip :Cl-
trajout ${prmtop}_md1us-${temp}K_dry.nc netcdf
go
EOF

# Execute script
cpptraj -i join.in

# Send email
echo -e "Subject: Run $SLURM_JOB_NAME finished in ClusterUY" | sendmail $email
