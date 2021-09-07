#!/usr/bin/env bash

# Extracted from:
# https://www.researchgate.net/post/How_can_I_Convert_Fasta_format_or_aln_format_to_PIR_format_I_need_this_for_modeller_but_clustal_W_doesnt_have_this_option
# 19th Jan, 2016 / Kirill E Medvedev, University of Texas Southwestern Medical Center

# Usage: ./fas2pir.sh sequence.fasta

name=$(basename $1 .fasta)

cp $name.fasta $name.sequence # copy your fasta to a new file

sed -i '1d' $name.sequence # remove the top line and rewrite

grep pattern $name.sequence | tr '\n' ' ' # consolidates multiple lines into one

touch temp_pir.ali # make a temp file

cat << EOF >> temp_pir.ali # this copys the following to tempfile
>P1;$name
sequence:$name:::::::0.00: 0.00
EOF

cat $name.sequence >> temp_pir.ali # append the protein sequence to this file

mv temp_pir.ali $name.ali # rename the temp file to match your fasta input file

rm $name.sequence # deletes the temp file containing the seq

sed -i '${s/$/*/}' $name.ali # adds a * to the end of the last line
