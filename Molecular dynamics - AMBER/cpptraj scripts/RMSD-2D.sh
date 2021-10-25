#!/usr/bin/env bash

# Usage: ./RMSD-2D.sh -p {prmtop} -a {trajectory1} -b {trajectory2} -r {residues}

# Get topology, trajectories and number of residues
while getopts :p:a:b:r: flag
do
    case "${flag}" in
        p) prmtop=$(basename ${OPTARG} .prmtop);;
        a) nc1=$(basename ${OPTARG} .nc);;
        b) nc2=$(basename ${OPTARG} .nc);;
        r) res=${OPTARG};;
    esac
done

skip=10

# Write out script for analysis
cat << EOF > ${prmtop}_RMSD-2D.in
parm $prmtop.prmtop
loadcrd $nc1.nc 1 last $skip name first
loadcrd $nc2.nc 1 last $skip name second
reference first crdset
crdaction first rmsd \
    :1-${res}@CA,C,N \
    reference
crdaction second rmsd \
    :1-${res}@CA,C,N \
    reference
rms2d crdset second :1-${res}@CA,C,N \
    mass \
    reftraj first \
    out ${prmtop}_rmsd-2d.dat
EOF

# Redirect stdout and stderr to log
exec > >(tee rmsd-2d.log) 2>&1

echo topology=$prmtop
echo trajectory1=$nc1
echo trajectory2=$nc2
echo residues=$res

# Run analysis
cpptraj.OMP -i ${prmtop}_RMSD-2D.in
