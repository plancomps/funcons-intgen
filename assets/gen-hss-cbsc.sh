#!/bin/bash

## e.g. to generate Unstables-Funcons-Beta
## $1 = Core, $2 = cbs/, #3 = <PATH://>Unstable-Funcons-Beta/

CBSC=cbsc
FDIR=${3%/}/$4
HSDIR=${2%/}
LANG=$1
HSLANG=${LANG//-/}
LIBRARYPATH=$HSDIR/Funcons/$LANG
LIBRARY=$LIBRARYPATH/Library.hs
LIBRARYMOD="Funcons.$HSLANG.Library"

if [[ -z ${3+x} || -z ${2+x} || -z ${1+x} ]]; then 
    echo "usage: gen-hss.sh <LANG> <HS-DIR> <FUNCONS-DIR> <SUB-DIR>
            for example: ./gen-hss.hs CamlLight hs-gen/ ../Funcons"
    exit
fi
echo "Generating Haskell modules in $HSDIR for language $LANG ($HSLANG) from .cbs files found in $FDIR."

function run-compile {
  ${CBSC} ${i} ${HSDIR} ${LANG}
}

#find $FDIR -type f -name "*.cbs" -exec $CBSC {} $HSDIR $LANG \;
for i in $(find $FDIR -type f -name "*.cbs")
do
  run-compile $i
done
