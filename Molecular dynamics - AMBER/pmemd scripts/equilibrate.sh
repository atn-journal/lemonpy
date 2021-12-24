#!/usr/bin/env bash

# Get topology, coordinates and temperature
prmtop=''
coord=''
temp=

# Create equilibration input file
cat << EOF > eq.in
Equilibrating the system during 5000 ps at constant T,
P = 1 bar and coupling = 0.2 ps.
  &cntrl
    ntx=5,irest=1,
    t=0.0,dt=0.002,nstlim=250000,
    temp0=${temp},ntt=3,ig=-1,gamma_ln=5.0,
    pres0=1.0,ntp=1,barostat=1,taup=0.2,
    ntc=2,ntf=2,
    nscm=5000,
    cut=9.0,
    ntpr=500,ntwr=125000,ntwx=500,
  /

EOF

# Redirect stdout and stderr to log
exec 3>&1 4>&2 1> >(tee eq.log) 2>&1

echo topology=$prmtop
echo coordinates=$coord
echo temperature=$temp

# Equilibrate the system
pmemd.cuda -O -i eq.in -o ${prmtop}_eq.out -p ${prmtop}.prmtop -c ${coord}.rst -r ${prmtop}_eq.rst -x ${prmtop}_eq.nc -inf ${prmtop}_eq.mdinfo

echo -e "\n##################################################"
echo "Equilibration took $((${SECONDS}/60)) min"
echo -e "##################################################\n"

# Stop redirection to log
exec 1>&3 2>&4
