#!/usr/bin/gawk -f
BEGIN {
  sectionregex="[ +[a-zA-Z0-9]+ +]";
}
{
  if (match($0, sectionregex)) {
    section=$0;
    if (section=="[ dihedrals ] ; propers") {
      section="[ dihedraltypes ]"
      print(section)
    }
    if (section=="[ dihedrals ] ; impropers") {
      section="[ dihedraltypes ]"
      print(section)
    }
    if (section=="[ bonds ]") {
      section="[ bondtypes ]"
      print(section)
    }
    if (section=="[ angles ]") {
      section="[ angletypes ]"
      print(section)
    }
  }

  if (section=="[ atoms ]" && NF>7) {
    atomDict[$1] = $2
  }
  if (section=="[ bondtypes ]" && NF>7) {
    if (!match($0, "^;.+")) {
      printf("%5s%5s", atomDict[$1], atomDict[$2], $3, $4, $5)
      $1=""
      $2=""
      print($0)
    }
  }
  if (section=="[ angletypes ]" && NF>7) {
    if (!match($0, "^;.+")) {
      printf("%5s%5s%5s", atomDict[$1], atomDict[$2], atomDict[$3])
      $1=""
      $2=""
      $3=""
      print($0)
    }
  }
  if (section=="[ dihedraltypes ]" && NF>7) {
    if (!match($0, "^;.+")) {
      printf("%5s%5s%5s%5s", atomDict[$1], atomDict[$2], atomDict[$3], atomDict[$4])
      $1=""
      $2=""
      $3=""
      $4=""
      print($0)
    }
  }
}
END {
  print "ATTN: remember to include the output into forcefield.itp file." > "/dev/stderr"
}
