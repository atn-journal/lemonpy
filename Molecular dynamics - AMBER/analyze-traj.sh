#!/usr/bin/env bash

# Usage: ./analyze-traj.sh -p {prmtop} -t {trajectory} -r {residues}

# Get topology, trajectory and number of residues
while getopts :p:t: flag
do
    case "${flag}" in
        p) prmtop=$(basename ${OPTARG} .prmtop);;
        t) nc=$(basename ${OPTARG} .nc);;
        r) res=${OPTARG};;
    esac
done

# Write out script for analysis
cat << EOF > analyze.in
parm ${prmtop}.prmtop
trajin ${nc}.nc
rms first mass out ${nc}_rmsd.dat :1-${res}
nativecontacts :1-${res} writecontacts ${nc}_contacts.dat resout ${nc}_residue-pairs.dat out ${nc}_allcontacts.dat byresidue contactpdb ${nc}_nativecontact.pdb mapout ${nc}_map.dat nncontactpdb ${nc}_nncontact.pdb
molsurf sas :1-${res} out ${nc}_sas.dat
go

EOF

# Redirect stdout and stderr to log
exec > >(tee analyze.log) 2>&1

echo topology=$prmtop
echo trajectory=$nc
echo residues=$res

# Run analysis
cpptraj -i analyze.in
