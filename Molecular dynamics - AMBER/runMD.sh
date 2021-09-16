#!/bin/bash

# Usage: ./runMD.sh -p {prmtop} -c {coordinates} -n {input_ns} -t {temperature}
# Temperature must be an integer provided in K.
# "input_ns" must be an integer.

# Get topology, coordinates, temperature and expected ns of trajectory output
while getopts :p:c:n:t: flag
do
    case "${flag}" in
        p) prmtop=$(basename ${OPTARG} .prmtop);;
        c) coord=$(basename ${OPTARG} .rst);;
        n) ns=$((${OPTARG}+50));;
        t) temp=${OPTARG};;
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

# Define output
output=${prmtop}_md${ns}ns

if test $ns -eq 50
  then
    log=md${ns}ns
else
  log=md$(($ns-50))-$(($ns+50))ns
fi

# Redirect stdout and stderr to log
exec > >(tee $log.log) 2>&1

# Print variables
echo topology=$prmtop
echo input coordinates=$coord
echo temperature=$temp
echo output=$output

echo -e "\n##################################################"
echo "Running $output"
echo -e "##################################################\n"

# RUN MD
time pmemd.cuda -O -i md.in -o $output.out -p $prmtop.prmtop -c $coord.rst -r $output.rst -x $output.nc -inf $output.mdinfo

echo -e "\n##################################################"
echo "$output finished"
echo -e "##################################################\n"

send-email.py "Terminó $output"

# Re-define variables
coord=$output
ns=$((${ns}+50))
output=${prmtop}_md${ns}ns

# Print variables
echo input coordinates=$coord
echo output trajectory=$output

echo -e "\n##################################################"
echo "Running $output"
echo -e "##################################################\n"

# RUN MD
time pmemd.cuda -O -i md.in -o $output.out -p $prmtop.prmtop -c $coord.rst -r $output.rst -x $output.nc -inf $output.mdinfo

echo -e "\n##################################################"
echo "$output finished"
echo -e "##################################################\n"

send-email.py "Terminó $output"
