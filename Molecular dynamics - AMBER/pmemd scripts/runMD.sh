#!/bin/bash

prmtop=''
coord=''
ns_in=
ns_end=
temp=
ID=''

# Define variables
host=$(hostname)
file=`basename "$0"`

ns_out=$(($ns_in+50))

if test $ns_in -eq 0
then
    output=${prmtop}_md$(printf "%04d" $ns_out)ns-${temp}K
else
    coord=${prmtop}_md$(printf "%04d" $ns_in)ns-${temp}K
    output=${prmtop}_md$(printf "%04d" $ns_out)ns-${temp}K
fi

# Prepare next run
next="$ID-$(printf "%04d" $(($ns_out+50)))ns.sh"

if test $(($ns_out+50)) -le $ns_end
then
  last=false
  cp $file $next
  sed -r -i "s/^ns_in=.*/ns_in=$ns_out/" $next
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

# Redirect stdout and stderr to log
exec 3>&1 4>&2 1>> >(tee $ID-$(printf "%04d" $(($ns_in+50)))ns.log) 2>&1

# Print variables
echo topology=$prmtop
echo input=$coord
echo output=$output
echo ID=$ID
echo host=$host

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
    send-email.py "Run $output from $ID finished in $host"
  else
    send-email.py "Run $output from $ID completed in $host"
    ./$next
  fi
else
  send-email.py "FAILED run $output from $ID in $host"
fi

# Stop redirection to log
exec 1>&3 2>&4
