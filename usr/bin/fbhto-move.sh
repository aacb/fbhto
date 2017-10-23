#!/bin/bash

################
## fbhto.sh ##
################

####
##  fbhto-move.sh
##  From black hole to organized
##  
##  This is a user script. It will move the file(s),
##  given as argument(s), to the directory that is
##  configured as the blackhole.
##
##  (c) 2017 by Antonio Augusto de Cintra Batista <antonio.a.c.batista@gmail.com>
##  Licensed under GNU GPL v3
##  Version 0.2.3 - 2017-10-23
##
####

source /usr/lib/fbhto/common-lib.sh
source /usr/lib/fbhto/fbhto-lib.sh

###
# read the configuration files
###
# regular expression: expected configuration line sintax
regExpConf='^[a-zA-Z0-9\._-]+=[a-zA-Z0-9\.\$/_"-]'
numLinha=0
while read linha; do
  ((numLinha++))
  linha=$(echo "$linha" |sed -e 's#^[[:space:]]*##g' |sed -e 's/^\(.*\)#.*$/\1/g' |sed -e 's#[[:space:]]*$##g')
  if [[ "${linha:0:1}" != "#" && "${linha:0:1}" != "" ]]; then
  # skip comments
    if [[ "$linha" =~ $regExpConf ]]; then
    # conf line will be accepted
      fNesteNivelDeDebugEscrever 7 "linha $numLinha: ""$linha"
      eval "$linha"
    else
      fNesteNivelDeDebugEscrever 0 "SINTAX ERROR found at line $numLinha of /etc/fbhto/fbhto.conf"
      fNesteNivelDeDebugEscrever 0 "$linha"
      exit 1
    fi
  fi
done </etc/fbhto/fbhto.conf

if [[ $# == 0 ]]; then
  cat <<EOF
ERROR: you need to specify at least one file

$nomeDoScript - move the specified file(s) to the configured fbhto blackhole

The configured fbhto blackhole is at: $pastaBh

USAGE
-----
$nomeDoScript file1 file2 ... fileN

where file1, file2, ... fileN can be a directory or a file

EOF

fi

regExpInvalidArguments='[;|&<>`$]'
argumento="$1"
tamanhoArgumento=${#argumento}
while [[ $tamanhoArgumento > 0 ]]; do
  if [[ "$argumento" =~ $regExpInvalidArguments ]]; then
    echo "Invalid argument: ""$argumento"
  else
    comando="mv -f '""$argumento""' '""$pastaBh""'/."
    if [[ -e "$argumento" ]]; then
      echo "Blackholed this file: ""$argumento"
      eval "$comando"
    else
      echo "NOT FOUND: ""$argumento"
    fi
  fi
  shift
  argumento="$1"
  tamanhoArgumento=${#argumento}
done


