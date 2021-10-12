#!/usr/bin/env bash

# Usage: ./analyze-traj.sh -p {prmtop} -t {trajectory} -r {residues}

# Get topology, trajectory and number of residues
while getopts :p:t:r: flag
do
    case "${flag}" in
        p) prmtop=$(basename ${OPTARG} .prmtop);;
        t) nc=$(basename ${OPTARG} .nc);;
        r) res=${OPTARG};;
    esac
done

skip=1

# Write out scripts for analysis
cat << EOF > RMSD.in
parm ${prmtop}.prmtop
trajin ${nc}.nc 1 last $skip
rmsd :1-${res}@CA,C,N \
    first \
    mass \
    out rmsd.dat
rms2d :1-${res}@CA,C,N \
    mass \
    out rmsd-2d.dat
EOF

cat << EOF > RMSF.in
parm ${prmtop}.prmtop
trajin ${nc}.nc 1 last $skip
rmsd :1-${res}@CA,C,N first
trajout ${prmtop}_Bfactor.pdb pdb stop 1
run
average :1-${res}@CA,C,N \
    crdset AVG
run
rmsd :1-${res}@CA,C,N \
    ref AVG
rmsf :1-${res}@CA,C,N \
    byres \
    out rmsf.dat
run
rmsf Bfactor :1-${res}@CA,C,N \
    bfactor
run
loadcrd ${prmtop}_Bfactor.pdb PDB
crdout PDB ${prmtop}_Bfactor.pdb \
    bfacdata Bfactor
run
EOF

cat << EOF > CONTACTS.in
parm ${prmtop}.prmtop
trajin ${nc}.nc 1 last $skip
rmsd :1-${res}@CA,C,N first
nativecontacts :1-${res} \
    byresidue resoffset 4 \
    writecontacts contacts_native.dat \
    resout contacts_residue-pairs.dat \
    out contacts_all.dat \
    contactpdb contacts_native-strength.pdb \
    map mapout contacts_map.dat \
    savenonnative nncontactpdb contacts_non-native-strength.pdb
run
EOF

cat << EOF > SAS.in
parm ${prmtop}.prmtop
trajin ${nc}.nc 1 last $skip
rmsd :1-${res}@CA,C,N first
molsurf :1-${res} \
    out sas.dat
run
EOF

cat << EOF > HBONDS.in
parm ${prmtop}.prmtop
trajin ${nc}.nc 1 last $skip
rmsd :1-${res}@CA,C,N first
hbond :1-${res} \
    avgout hbonds_avg.dat printatomnum \
    series uuseries hbonds_series.dat
run
EOF

cat << EOF > CLUSTER.in
parm ${prmtop}.prmtop
trajin ${nc}.nc 1 last $skip
cluster rms :1-${res}@CA,C,N \
    sieve 10 \
    summary clusters.dat \
    cpopvtime cluster-population-vs-time.dat normframe \
    singlerepout clusters.nc \
    repout cluster repfmt pdb
run
EOF

# Redirect stdout and stderr to log
exec > >(tee analyze.log) 2>&1

echo topology=$prmtop
echo trajectory=$nc
echo residues=$res

# Run analysis
cpptraj -i RMSD.in
cpptraj -i RMSF.in
cpptraj -i CONTACTS.in
cpptraj -i SAS.in
cpptraj -i HBONDS.in
cpptraj -i CLUSTER.in
