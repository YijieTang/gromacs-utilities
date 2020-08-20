#!/usr/bin/gawk -f
BEGIN {
  sectionregex="[ +[a-zA-Z0-9]+ +]";
  print("[ bondedtypes ]")
  print("; Column 1 : default bondtype")
  print("; Column 2 : default angletype")
  print("; Column 3 : default proper dihedraltype")
  print("; Column 4 : default improper dihedraltype")
  print("; Column 5 : This controls the generation of dihedrals from the bonding.")
  print(";            All possible dihedrals are generated automatically. A value of")
  print(";            1 here means that all these are retained. A value of")
  print(";            0 here requires generated dihedrals be removed if")
  print(";              * there are any dihedrals on the same central atoms")
  print(";                specified in the residue topology, or")
  print(";              * there are other identical generated dihedrals")
  print(";                sharing the same central atoms, or")
  print(";              * there are other generated dihedrals sharing the")
  print(";                same central bond that have fewer hydrogen atoms")
  print("; Column 6 : number of neighbors to exclude from non-bonded interactions")
  print("; Column 7 : 1 = generate 1,4 interactions between pairs of hydrogen atoms")
  print(";            0 = do not generate such")
  print("; Column 8 : 1 = remove proper dihedrals if found centered on the same")
  print(";                bond as an improper dihedral")
  print(";            0 = do not generate such")
  print("; bonds  angles  dihedrals  impropers all_dihedrals nrexcl HH14 RemoveDih")
  print("     1       1          9          4        1         3      1     0")
}
{
  if (match($0, sectionregex)) {
    section=$0;
    if (section=="[ dihedrals ] ; propers") {
      section="[ dihedrals ]"
    }
    if (section=="[ dihedrals ] ; impropers") {
      section="[ impropers ]"
    }
    if (section=="[ atoms ]" || section=="[ bonds ]" || section=="[ angles ]" || section=="[ dihedrals ]" || section=="[ impropers ]") {
      print(section);
    }
  }
  if (section=="[ moleculetype ]" && NF>1) {
    if (!match($0, "^;.+") && !match($0, sectionregex)) {
      printf("[ %s ]\n",$1)
    }
  }
  if (section=="[ atoms ]" && NF>7) {
    if (!match($0, "^;.+")) {
      printf("%6s%8s%15s%5s\n", $5,$2,$7,$1-1)
    }
  }
  if (section=="[ bonds ]" && NF>7) {
    if (!match($0, "^;.+")) {
      printf("%8s%8s\n", $7,$9)
    }
  }
  if (section=="[ angles ]" && NF>7) {
    if (!match($0, "^;.+")) {
      printf("%8s%8s%8s\n", $8,$10,$12)
    }
  }
  if (section=="[ dihedrals ]" && NF>7) {
    if (!match($0, "^;.+")) {
      gsub("-","",$13);
      gsub("-","",$14);
      gsub("-","",$15);
      gsub("-","",$16);
      printf("%8s%8s%8s%8s\n", $13,$14,$15,$16)
    }
  }
  if (section=="[ impropers ]" && NF>7) {
    if (!match($0, "^;.+")) {
      gsub("-","",$10);
      gsub("-","",$11);
      gsub("-","",$12);
      gsub("-","",$13);
      printf("%8s%8s%8s%8s\n", $10,$11,$12,$13)
    }
  }
}
END {
  print "ATTN: you need to change bondedtypes by yourself!" > "/dev/stderr"
  print "check function types in each section of .top file" > "/dev/stderr"
  print "Also, change the residue name as intended" > "/dev/stderr"
}
