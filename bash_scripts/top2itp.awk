#!/usr/bin/gawk -f
BEGIN {
  sectionregex="[ +[a-zA-Z0-9]+ +]";
}
{
  if (match($0, sectionregex)) {
    section=$0;
    if (section=="[ moleculetype ]") flag="true"
    if (section=="[ system ]") flag="false"
  }
  
  if (section=="[ moleculetype ]" && NF>1) {
    if (!match($0, "^;.+") && !match($0, sectionregex)) {
      name=$1
    }
  }

  
  if (flag=="true") print $0
}
END {
  print("; Include position restraint file")
  printf("#ifdef POSRES_%s\n", name)
  printf("#include \"posre_%s.itp\"\n", name)
  print("#endif")
}
