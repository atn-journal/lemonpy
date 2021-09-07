#!/usr/bin/env bash

echo Nombre de archivo PDB:
read pdb

mv ${pdb}.pdb ${pdb}_ori.pdb
grep -E "^ATOM|^HETATM.*PLP|^TER|^END" ${pdb}_ori.pdb | sed 's/HETATM/ATOM  /g' > ${pdb}.pdb
