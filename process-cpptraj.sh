#!/usr/bin/env bash

echo Nombre del .prmtop
read prmtop

echo Nombre del .nc 1
read nc1

# echo Nombre del .nc 2
# read nc2

cat << EOF > trajio.in
parm ${prmtop}.prmtop
trajin ${nc1}.nc 1 last 10
autoimage
strip :Na+
strip :Cl-
strip :WAT
trajout ${nc1}_dry.nc netcdf
go

EOF

cat << EOF > dry.in
parm ${prmtop}.prmtop
parmstrip :Na+
parmstrip :Cl-
parmstrip :WAT
parmwrite out ${prmtop}_dry.prmtop
go

EOF

cpptraj -i trajio.in
cpptraj -i dry.in

vmd ${prmtop}_dry.prmtop ${nc1}_dry.nc