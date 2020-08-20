#!/usr/bin/env python
from pymol import cmd
import re
import os
path = os.getcwd()
filenames = [ ]
for filename in os.listdir(path):
    if re.match("disre_.*[.]itp", filename):
        filenames.append(filename)

print("files are: ")
print(filenames)

def filter_func(line):
    words = re.split('\s+', line)
    return words[0].isdigit() and words[1].isdigit()

def map_func(line):
    words = re.split('\s+', line)
    return (int(words[0]), int(words[1]))

def map_func2(line):
    words = re.split('\s+', line)
    return (words[5], words[6], words[7])
    
dis_pairs = []
restraints = []

for filename in filenames:
    with open(filename, 'r') as f:
        lines = f.readlines()
        lines = list(filter(filter_func , lines))
        dis_pairs.extend(list(map(map_func, lines)))
        restraints.extend(list(map(map_func2, lines)))

out_lines = []
for dis_pair,restraint in zip(dis_pairs, restraints):
    group1 = "(id %d)" % dis_pair[0]
    group2 = "(id %d)" % dis_pair[1]
    cmd.distance("%d-%d" % (dis_pair[0], dis_pair[1]), group1, group2)
    resns = []
    resis = []
    atoms = []
    cmd.iterate("id %d+%d" % dis_pair, "resns.append(resn)")
    cmd.iterate("id %d+%d" % dis_pair, "resis.append(resi)")
    cmd.iterate("id %d+%d" % dis_pair, "atoms.append(name)")
    distance = cmd.get_distance(atom1=group1, atom2=group2)
    out_lines.append("[ %s%s(%s)-%s%s(%s) ~ %.2fA (%s, %s, %s)]\n" % ((resns[0], resis[0], atoms[0], resns[1], resis[1], atoms[1], distance) + restraint))
    out_lines.append("%d %d\n" % dis_pair)

# write dis_pairs to distance_pairs.ndx for analysis
with open("dist_out.ndx", 'w') as f:
    for line in out_lines:
        f.write(line)
        print(line)
