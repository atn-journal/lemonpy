#!/bin/bash

# Usage: ./runMD.sh -p {prmtop} -c {coordinates} -n {input_ns} -t {temperature} -i {ID}
# Temperature must be an integer provided in K.
# "input_ns" must be an integer.

# Get topology, coordinates, temperature and expected ns of trajectory output
while getopts :p:c:n:t:i: flag
do
    case "${flag}" in
        p) prmtop=$(basename ${OPTARG} .prmtop);;
        c) coord=$(basename ${OPTARG} .rst);;
        n) ns=$((${OPTARG}+50));;
        t) temp=${OPTARG};;
        i) ID=${OPTARG};;
    esac
done

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

# Define output name and host
output=${prmtop}_md${ns}ns-${temp}K
host=$(hostname)

# Redirect stdout and stderr to log
exec 3>&1 4>&2 1>> >(tee MD_from$(($ns-50))ns-${temp}K.log) 2>&1

# Print variables
echo topology=$prmtop
echo input=$coord
echo output=$output
echo ID=$ID
echo host=$host

echo -e "\n##################################################"
echo "Running $output"
echo -e "##################################################\n"

# RUN MD
time pmemd.cuda -O -i md.in -o $output.out -p $prmtop.prmtop -c $coord.rst -r $output.rst -x $output.nc -inf $output.mdinfo

echo -e "\n##################################################"
echo "$output finished"
echo -e "##################################################\n"

send-email.py "Run $output from $ID finished in $host"

# Re-define variables
coord=$output
ns=$((${ns}+50))
output=${prmtop}_md${ns}ns-${temp}K

# Print variables
echo input=$coord
echo output=$output

echo -e "\n##################################################"
echo "Running $output"
echo -e "##################################################\n"

# RUN MD
time pmemd.cuda -O -i md.in -o $output.out -p $prmtop.prmtop -c $coord.rst -r $output.rst -x $output.nc -inf $output.mdinfo

echo -e "\n##################################################"
echo "$output finished"
echo -e "##################################################\n"

send-email.py "Run $output from $ID finished in $host"

# Stop redirection to log
exec 1>&3 2>&4
