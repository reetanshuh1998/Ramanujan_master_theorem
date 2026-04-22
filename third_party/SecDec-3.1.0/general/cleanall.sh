#!/bin/sh
#****l* SecDec/general/cleanall.sh
# NAME
#  cleanall.sh
# USAGE
#  ./cleanall.sh
# USES
#  
# PURPOSE
#  Removes any 'decompose[graph]' executables and removes all
#  job error and output files from the batch system in the "loop/" directory
#****
 ls job*.* 2>>lserr | while read jbs; do
 rm "$jbs"
 done
 ls togsub*.* 2>>lserr | while read tgs; do
 rm "$tgs"
 done
rm lserr
