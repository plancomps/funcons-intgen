#!/bin/bash
# e.g. $1 = Core, $2 = cbs/
LANG=$1
HSLANG=${LANG//-/}
HSDIR=${2%/}
LIBRARYPATH="$HSDIR/Funcons/$HSLANG"
LIBRARY="$LIBRARYPATH/Library.hs"
LIBRARYMOD="Funcons.$HSLANG.Library"
LANGMOD="Funcons.$HSLANG"

if [[ -z ${1+x} || -z ${2+x} ]]; then 
    echo "usage: gen-hslibrary.sh <LANG> <HS-DIR>
            for example: ./gen-hslibrary.sh CamlLight hs-gen/"
    exit
fi

echo "Generating funcon library"

FILES=$(find $HSDIR/Funcons -type f -name "*.hs")
echo "module $LIBRARYMOD (" > $LIBRARY

echo "    funcons, entities, types," >> $LIBRARY

for full in $FILES
do
    path=${full##"$LIBRARYPATH/"}
    if [ $path != "Library.hs" ]; then 
        strippath=${path%".hs"}
        mod=$LANGMOD"."${strippath//"/"/"."}
        echo "   module $mod," >> $LIBRARY
    fi
done
echo "    ) where " >> $LIBRARY


echo "import Funcons.EDSL" >> $LIBRARY
if [ "Core" != "$LANG" ]; then 
    echo "import Funcons.Tools" >> $LIBRARY
fi

for full in $FILES
do
    path=${full##"$LIBRARYPATH/"}
    if [ $path != "Library.hs" ]; then 
        strippath=${path%".hs"}
        mod=$LANGMOD"."${strippath//"/"/"."}
        echo "import $mod hiding (funcons,types,entities)" >> $LIBRARY
        echo "import qualified $mod" >> $LIBRARY
    fi
done

if [ "Core" != "$LANG" ]; then
  echo "main = mkMainWithLibraryEntitiesTypes funcons entities types" >> $LIBRARY
fi
echo "funcons = libUnions" >> $LIBRARY
echo "    [" >> $LIBRARY

for full in $FILES
do
    path=${full##"$LIBRARYPATH/"}
    if [ $path != "Library.hs" ]; then 
        ((i++))
        strippath=${path%".hs"}
        mod=$LANGMOD"."${strippath//"/"/"."}
        if [ "$i" -gt 1 ]; then 
            comma="," 
        fi
        echo "    $comma $mod.funcons" >> $LIBRARY
    fi
done
echo "    ]" >> $LIBRARY

comma=""
echo "entities = concat " >> $LIBRARY
echo "    [" >> $LIBRARY
for full in $FILES
do
    path=${full##"$LIBRARYPATH/"}
    if [ $path != "Library.hs" ]; then 
        ((j++))
        strippath=${path%".hs"}
        mod=$LANGMOD"."${strippath//"/"/"."}
        if [ "$j" -gt 1 ]; then 
            comma="," 
        fi
        echo "    $comma $mod.entities" >> $LIBRARY
    fi
done
echo "    ]" >> $LIBRARY

comma=""
echo "types = typeEnvUnions " >> $LIBRARY
echo "    [" >> $LIBRARY
for full in $FILES
do
    path=${full##"$LIBRARYPATH/"}
    if [ $path != "Library.hs" ]; then 
        ((h++))
        strippath=${path%".hs"}
        mod=$LANGMOD"."${strippath//"/"/"."}
        if [ "$h" -gt 1 ]; then 
            comma="," 
        fi
        echo "    $comma $mod.types" >> $LIBRARY
    fi
done
echo "    ]" >> $LIBRARY
