#!/bin/bash

prmtop=''
coord=''
ns_in=''
temp=''
ID=''

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

# Define input coord., output name and host
host=$(hostname)

ns_out=$(($ns_in+50))

if test $ns_in -eq 0
then
    output=${prmtop}-md00${ns_out}ns-${temp}K
else
    coord=${prmtop}-md$(printf "%04d" $ns_in)ns-${temp}K
    output=${prmtop}-md$(printf "%04d" $ns_out)ns-${temp}K
fi

# Redirect stdout and stderr to log
exec 3>&1 4>&2 1>> >(tee $ID-$(($ns_in+100))ns.log) 2>&1

# Print variables
echo topology=$prmtop
echo input=$coord
echo output=$output
echo ID=$ID
echo host=$host

echo -e "\n##################################################"
date
echo "Running $output"
echo -e "##################################################\n"

# RUN MD
pmemd.cuda -O -i md.in -o $output.out -p $prmtop.prmtop -c $coord.rst -r $output.rst -x $output.nc -inf $output.mdinfo

echo -e "\n############################################################"
date
echo "$output finished"
tail -n 18 $output.out
echo -e "############################################################\n"

#################################################################################################

for((i=0;i<1;i++));
do
  # Re-define names
  coord=$output
  ns_in=$ns_out
  ns_out=$(($ns_in+50))
  output=${prmtop}-md$(printf "%04d" $ns_out)ns-${temp}K

  echo new input=$coord
  echo new output=$output

  echo -e "\n##################################################"
  date
  echo "Running $output"
  echo -e "##################################################\n"

  # RUN MD
  pmemd.cuda -O -i md.in -o $output.out -p $prmtop.prmtop -c $coord.rst -r $output.rst -x $output.nc -inf $output.mdinfo

  echo -e "\n############################################################"
  date
  echo "$output finished"
  tail -n 18 $output.out
  echo -e "############################################################\n"
done

# Stop redirection to log
exec 1>&3 2>&4
