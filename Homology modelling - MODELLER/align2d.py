#!/usr/bin/env python3

# For alignment of sequence-structure using one template. For multiple templates go for align2d_mult.py
# Usage: change template and sequence names and execute as ./align2d.py

from modeller import *

env = Environ()
aln = Alignment(env)

template = 'template.pdb'               #
template_base = template[0:-4]

seq = 'sequence.ali'                    #
seq_base = seq[0:-4]

seq_temp = "-".join([seq_base, template_base])
seq_temp_ali = ".".join([seq_temp, "ali"])
seq_temp_pap = ".".join([seq_temp, "pap"])

mdl = Model(env, file=template_base, model_segment=('FIRST:A', 'LAST:A'))
aln.append_model(mdl, align_codes=template_base, atom_files=template)
aln.append(file=seq, align_codes=seq_base)
aln.align2d()
aln.write(file=seq_temp_ali, alignment_format='PIR')
aln.write(file=seq_temp_pap, alignment_format='PAP')
