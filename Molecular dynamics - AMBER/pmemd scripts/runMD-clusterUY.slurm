#!/bin/bash
#SBATCH --job-name=ID-0050ns
#SBATCH --time=5-00:00:00
#SBATCH --mail-user=ariel.tijman@gmail.com
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
# Define variables
prmtop=''
ns_in=0
ns_end=500
coord=''
temp=
ID=''
email='ariel.tijman@gmail.com'
####################################################################################
####################################################################################

echo job_ID=$SLURM_JOB_ID
hostname

# Load modules
source /etc/profile.d/modules.sh

# Load AMBER
module use /clusteruy/home03/biosim_ip/modulefiles
module load amber18-tools19

# Define initial names
ns_out=$(($ns_in+50))

if test $ns_in -eq 0
then
    output=${prmtop}_md$(printf "%04d" $ns_out)ns-${temp}K
else
    coord=${prmtop}_md$(printf "%04d" $ns_in)ns-${temp}K
    output=${prmtop}_md$(printf "%04d" $ns_out)ns-${temp}K
fi

echo topology=$prmtop
echo input=$coord
echo output=$output
echo ID=$ID

# Prepare next run
next="$ID-$(printf "%04d" $(($ns_out+50)))ns"

if test $(($ns_out+50)) -le $ns_end
then
  last=false
  cp $SLURM_JOB_NAME.slurm $next.slurm

  sed -r -i "s/^#SBATCH --job-name=.*/#SBATCH --job-name=$next/" $next.slurm
  sed -r -i "s/^#*SBATCH --dependency=afterok:.*/#SBATCH --dependency=afterok:$SLURM_JOB_ID/" $next.slurm
  sed -r -i "s/^ns_in=.*/ns_in=$ns_out/" $next.slurm

  sbatch $next.slurm
else
  last=true
fi

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
    ntpr=500,ntwr=500000,ntwx=5000,
  /
EOF

# RUN MD
echo -e "\n##################################################"
date
echo "Running $output"
echo -e "##################################################\n"
pmemd.cuda -O -i md.in -p ${prmtop}.prmtop -c ${coord}.rst -o ${output}.out -r ${output}.rst -x ${output}.nc -inf ${output}.mdinfo

echo -e "\n############################################################"
date
echo "$output finished"
tail -n 18 $output.out
echo -e "############################################################\n"

# End tasks
FILE=./${output}.out

if grep -q "Final Performance Info" "$FILE"
then
  if [ "$last" = true ]
  then
    echo -e "Subject: Run $output from $ID finished in ClusterUY" | sendmail $email
  fi
else
  echo -e "Subject: FAILED run $output from $ID in ClusterUY" | sendmail $email
  scancel -n $next
fi
