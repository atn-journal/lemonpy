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
nativecontacts :1-$((${res}/2)) :$((${res}/2+1))-$res \
    byresidue resoffset 4 \
    out contacts-inter_all.dat \
    contactpdb contacts-inter_native-strength.pdb \
    map mapout contacts-inter_map.dat \
    savenonnative nncontactpdb contacts-inter_non-native-strength.pdb \
    series resseries present resseriesout contacts-inter_series.dat
nativecontacts :TRP,TYR,MET,ALA,ILE,LEU,PHE,VAL,PRO,GLY \
    byresidue resoffset 4 \
    out contacts-hydrophobic_all.dat \
    contactpdb contacts-hydrophobic_native-strength.pdb \
    map mapout contacts-hydrophobic_map.dat \
    savenonnative nncontactpdb contacts-hydrophobic_non-native-strength.pdb \
    series resseries present resseriesout contacts-hydrophobic_series.dat
nativecontacts :ARG,LYS,ASP,GLU,GLN,ASN,HIS,SER,THR,TYR,CYS \
    byresidue resoffset 4 \
    out contacts-hydrophilic_all.dat \
    contactpdb contacts-hydrophilic_native-strength.pdb \
    map mapout contacts-hydrophilic_map.dat \
    savenonnative nncontactpdb contacts-hydrophilic_non-native-strength.pdb \
    series resseries present resseriesout contacts-hydrophilic_series.dat
run
EOF

cat << EOF > SASA.in
parm ${prmtop}.prmtop
trajin ${nc}.nc 1 last $skip
rmsd :1-${res}@CA,C,N first
molsurf :1-${res} \
    out sasa.dat
surf :TRP,TYR,MET,ALA,ILE,LEU,PHE,VAL,PRO,GLY&!@CA,C,O,N,H \
    out sasa_nonpolar.dat
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

cat << EOF > RADGYR.in
parm ${prmtop}.prmtop
trajin ${nc}.nc 1 last $skip
rmsd :1-${res}@CA,C,N first
radgyr :1-${res}@CA,C,N \
    out radgyr.dat
run
EOF

cat << EOF > PCA.in
parm ${prmtop}.prmtop
trajin ${nc}.nc 1 last $skip
rmsd :1-${res}@CA,C,N,O first
average crdset AVG
createcrd TRAJ
run
crdaction TRAJ rmsd \
    :1-${res}@CA,C,N,O \
    ref AVG
crdaction TRAJ matrix covar \
    :1-${res}&!@H= \
    name COVAR
runanalysis diagmatrix COVAR \
    vecs 3 name EVECS \
    nmwiz nmwizvecs 3 nmwizfile evecs.nmd nmwizmask :1-${res}&!@H= \
    out evecs.dat
crdaction TRAJ projection PROJ \
    :1-${res}&!@H= \
    evecs EVECS \
    beg 1 end 3
hist norm name PROJ-1 \
    PROJ:1 bins 100 \
    out hist.dat
hist norm name PROJ-2 \
    PROJ:2 bins 100 \
    out hist.dat
hist norm name PROJ-3 \
    PROJ:3 bins 100 \
    out hist.dat
run
EOF

# Redirect stdout and stderr to log
exec > >(tee analyze.log) 2>&1

echo topology=$prmtop
echo trajectory=$nc
echo residues=$res

# Run analysis
cpptraj.OMP -i RMSD.in
cpptraj.OMP -i RMSF.in
cpptraj.OMP -i RADGYR.in
cpptraj.OMP -i SASA.in
cpptraj.OMP -i PCA.in
cpptraj.OMP -i CLUSTER.in
cpptraj.OMP -i HBONDS.in
cpptraj.OMP -i CONTACTS.in

# Create trajectory of PCA
PCMIN=$(awk 'FNR == 2 {print $1}' pca-hist.dat)
PCMIN=$(echo "$PCMIN-5" | bc)

PCMAX=$(awk 'END{print $1}' pca-hist.dat)
PCMAX=$(echo "$PCMAX+5" | bc)

cat << EOF > PCA-trajout.in
readdata pca-evecs.dat name EVECS
parm ${prmtop}.prmtop
parmstrip !(:1-${res}&!@H=)
parmwrite out ${prmtop}_PCA.prmtop
runanalysis modes name EVECS \
    pcmin $PCMIN pcmax $PCMAX tmode 1 \
    trajoutmask :1-${res}&!@H= trajoutfmt netcdf \
    trajout ${nc}_PCA.nc
EOF

cpptraj.OMP -i PCA-trajout.in
