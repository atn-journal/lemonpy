#!/usr/bin/env python3

# For modelling of homodimer from multiple template alignment with no refinement.
# Usage: change alignment, templates and sequence names. Excecute as './model.py > model.log'

from modeller import *
from modeller.automodel import *
import sys

log.verbose()

# Override the 'special_restraints' and 'user_after_single_model' methods:
class MyModel(AutoModel):
    def special_restraints(self, aln):
        # Constrain the A and B chains to be identical (but only restrain
        # the C-alpha atoms, to reduce the number of interatomic distances
        # that need to be calculated):
        s1 = Selection(self.chains['A']).only_atom_types('CA')
        s2 = Selection(self.chains['B']).only_atom_types('CA')
        self.restraints.symmetry.append(Symmetry(s1, s2, 1.0))
    def user_after_single_model(self):
        # Report on symmetry violations greater than 1A after building
        # each model:
        self.restraints.symmetry.report(1.0)

env = Environ()
# directories for input atom files
env.io.atom_files_directory = ['.', '../atom_files']
env.io.hetatm = True

# Be sure to use 'MyModel' rather than 'AutoModel' here!
a = MyModel(env,
            alnfile = 'alignment.ali',     # alignment filename
            knowns = ('4ce5', '4cmd'),               # codes of the templates
            sequence = 'TACap',            # code of the target
            assess_methods=assess.normalized_dope)

a.starting_model = 1
a.ending_model  = 10
a.md_level = None
a.write_intermediates = False
a.trace_output = 0

a.make()

# Get a list of all successfully built models from a.outputs
ok_models = [x for x in a.outputs if x['failure'] is None]

# Rank the models by DOPE score
key = 'Normalized DOPE score'
ok_models.sort(key=lambda a: a[key])

# Get top model
m = ok_models[0]
print("Top model: %s (DOPE score %.3f)" % (m['name'], m[key]))
