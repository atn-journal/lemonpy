#!/usr/bin/env bash

# Usage: ./strip-prmtop.sh -p {prmtop}

# Get topology
while getopts :p: flag
do
    case "${flag}" in
        p) prmtop=$(basename ${OPTARG} .prmtop);;
    esac
done

# Write out script to strip topology file
cat << EOF > strip-prmtop.in
parm ${prmtop}.prmtop
parmstrip :WAT,Na+,Cl-
parmwrite out ${prmtop}_dry.prmtop
go
EOF

# Redirect stdout and stderr to log
exec > >(tee strip-prmtop.log) 2>&1

echo topology=$prmtop

# Strip topology file
cpptraj -i strip-prmtop.in
