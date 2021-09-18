#!/usr/bin/env bash

# Usage: ./heat.sh -p {prmtop} -c {coordinates} -r {residues} -t {temperature}
# Temperature must be an integer provided in K.

# Get topology, coordinates, number of residues and target temperature
while getopts :p:c:r:t: flag
do
    case "${flag}" in
        p) prmtop=$(basename ${OPTARG} .prmtop);;
        c) coord=$(basename ${OPTARG} .rst);;
        r) res=${OPTARG};;
        t) temp=${OPTARG};;
    esac
done

# Create heating input file
cat << EOF > heat.in
Heating the system with 5 kcal/mol restraints on PROTEIN,
V = const.
  &cntrl
    t=0.0,dt=0.002,nstlim=50000,
    ntr=1,restraintmask=':1-${res}',restraint_wt=5.0,
    tempi=100.0,ntt=3,ig=-1,gamma_ln=5.0,
    ntc=2,ntf=2,
    nscm=5000,
    cut=9.0,
    ntpr=500,ntwr=0,ntwx=500,
    nmropt=1,
  /
  &wt
    type='TEMP0',
    istep1=0,istep2=5000,
    value1=100.0,value2=${temp}.0,
  /
  &wt
    type='TEMP0',
    istep1=5001,istep2=50000,
    value1=${temp}.0,value2=${temp}.0,
  /
  &wt type='END',
  /

EOF

# Redirect stdout and stderr to log
exec 3>&1 4>&2 1> >(tee heat.log) 2>&1

echo topology=$prmtop
echo coordinates=$coord
echo residues=$res
echo temperature=$temp

# Heat the system
pmemd.cuda -O -i heat.in -o ${prmtop}_heat.out -p ${prmtop}.prmtop -c ${coord}.rst -r ${prmtop}_heat.rst -x ${prmtop}_heat.nc -ref ${coord}.rst -inf ${prmtop}_heat.mdinfo

echo -e "\n##################################################"
echo "Heating took $((${SECONDS}/60)) min"
echo -e "##################################################\n"

# Stop redirection to log
exec 1>&3 2>&4

# Display results in VMD
#vmd ${prmtop}.prmtop ${prmtop}_heat.nc

#send-email.py "Terminó ${prmtop}_heat_${temp}K"
