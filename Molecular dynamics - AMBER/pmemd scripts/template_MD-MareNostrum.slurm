#!/bin/bash
#SBATCH --job-name=ID-Xns
#SBATCH --time=2-00:00:00
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=40
#SBATCH --gres=gpu:1
##SBATCH --dependency=afterok:JOBID
#SBATCH --output=%x.out

####################################################################################
####################################################################################
# Define basenames, input time, T (in K, integer), path (no trailing '/') and email
prmtop=''
coord=''
ns_in=''
temp=''
path=''
####################################################################################
####################################################################################

echo job_ID=$SLURM_JOB_ID
hostname

# Load modules
module load atlas/3.10.3 python/2.7.14 cuda amber/18

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
echo path=$path

# Move files to scratch
cp ${path}/{${prmtop}.prmtop,${coord}.rst} $NVME1DIR
cd $NVME1DIR

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
    ntpr=500,ntwr=12500000,ntwx=5000,
  /
EOF

# RUN MD
echo -e "\n##################################################"
date
echo "Running $output"
echo -e "##################################################\n"
pmemd.cuda -O -i md.in -o ${output}.out -p ${prmtop}.prmtop -c ${coord}.rst -r ${output}.rst -x ${output}.nc -inf ${output}.mdinfo

# Recover files and remove from scratch
cp $NVME1DIR/* $path/
rm -rf $NVME1DIR/*

echo -e "\n############################################################"
date
echo "$output finished"
tail -n 18 $path/$output.out
echo -e "############################################################\n"

####################################################################################
# Re-define names
coord=$output
ns_in=$ns_out
ns_out=$(($ns_in+50))
output=${prmtop}_md$(printf "%04d" $ns_out)ns-${temp}K

echo new input=$coord
echo new output=$output

# Move files to scratch
cp $path/{md.in,${prmtop}.prmtop,${coord}.rst} $NVME1DIR/

# RUN MD
echo -e "\n##################################################"
date
echo "Running $output"
echo -e "##################################################\n"
pmemd.cuda -O -i md.in -o ${output}.out -p ${prmtop}.prmtop -c ${coord}.rst -r ${output}.rst -x ${output}.nc -inf ${output}.mdinfo

# Recover files and remove from scratch
cp $NVME1DIR/* $path/

echo -e "\n############################################################"
date
echo "$output finished"
tail -n 18 $path/$output.out
echo -e "############################################################\n"
