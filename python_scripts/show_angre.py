#!/usr/bin/env python
from pymol import cmd
import re
import os
path = os.getcwd()
filenames = [ ]
for filename in os.listdir(path):
    if re.match("^angre_.*[.]itp$", filename):
        filenames.append(filename)

print("files are: ")
print(filenames)

def filter_func(line):
    words = re.split('\s+', line)
    return words[0].isdigit() and words[1].isdigit()

def map_func(line):
    words = re.split('\s+', line)
    return (int(words[1]), int(words[0]), int(words[3]))

def map_func2(line):
    words = re.split('\s+', line)
    return (words[5], words[6], words[7])

ang_pairs = []
restraints = []

for filename in filenames:
    with open(filename, 'r') as f:
        lines = f.readlines()
        lines = list(filter(filter_func , lines))
        ang_pairs.extend(list(map(map_func, lines)))
        restraints.extend(list(map(map_func2, lines)))

out_lines = []
for ang_pair,restraint in zip(ang_pairs, restraints):
    group1 = "(id %d)" % ang_pair[0]
    group2 = "(id %d)" % ang_pair[1]
    group3 = "(id %d)" % ang_pair[2]
    cmd.angle("%d-%d-%d" % ang_pair, group1, group2, group3)
    resns = []
    resis = []
    atoms = []
    cmd.iterate("id %d+%d+%d" % ang_pair, "resns.append(resn)")
    cmd.iterate("id %d+%d+%d" % ang_pair, "resis.append(resi)")
    cmd.iterate("id %d+%d+%d" % ang_pair, "atoms.append(name)")
    angle = cmd.get_angle(group1, group2, group3)
    out_lines.append("[ %s%s(%s)-%s%s(%s)-%s%s(%s) ~ %.2f degree (%s, %s, %s) ]\n" % ((resns[0], resis[0], atoms[0], resns[1], resis[1], atoms[1], resns[2], resis[2], atoms[2],  angle) + restraint))
    out_lines.append("%d %d %d\n" % ang_pair)

# write dis_pairs to distance_pairs.ndx for analysis
with open("angle_out.ndx", 'w') as f:
    for line in out_lines:
        f.write(line)
        print(line)
