#!/usr/bin/env bash

# Usage: ./analyze-traj.sh -p {prmtop} -t {trajectory} -r {residues}

while getopts :p:t: flag
do
    case "${flag}" in
        p) prmtop=$(basename ${OPTARG} .prmtop);;
        t) nc=$(basename ${OPTARG} .nc);;
        r) res=${OPTARG};;
    esac
done

cat << EOF > analyze.in
parm ${prmtop}.prmtop
trajin ${nc}.nc
rms first mass out ${nc}_rmsd.dat :1-${res}
nativecontacts :1-${res} writecontacts ${nc}_contacts.dat resout ${nc}_residue-pairs.dat out ${nc}_allcontacts.dat byresidue contactpdb ${nc}_nativecontact.pdb mapout ${nc}_map.dat nncontactpdb ${nc}_nncontact.pdb
molsurf sas :1-${res} out ${nc}_sas.dat
go

EOF

cpptraj -i analyze.in
