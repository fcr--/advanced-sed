#!/bin/bash

SED=${SED-sed}

sedcode() {
  FILE=$1
  NAME=$2
  CODE=$($SED -n '
  1,/% *sedcode *'"$NAME"' *:/ d
    s/.*\\verb\(.\)\(.*\)\1.*/\2/p; ta
    /\\begin{[Vv]erbatim}/,/\\end{[Vv]erbatim}/ {
      /\\end{[Vv]erbatim}/ q
      /\\begin{[Vv]erbatim}/!p
    }; d
  :a;q' "$FILE".tex)
}

expect() {
  [ "$RES" = "$1" ] || {
    echo "ERROR at $FILE.tex/$NAME: obtained: <<$RES>>"
    echo "  expected: <<$1>>"
    echo "  code: <<$CODE>>"
    exit 1
  }
}

echo Sed version $SED: `$SED --version`
# busybox  # Uncomment this line if This is not GNU sed version 4.0

LF='
'

sedcode toolset fibonacci
RES=`echo "${LF}x${LF}xx${LF}xxx${LF}xxxx${LF}xxxxx${LF}xxxxxx" | $SED "$CODE"`
expect "${LF}x${LF}x${LF}xx${LF}xxx${LF}xxxxx${LF}xxxxxxxx"

sedcode toolset bitwise-xor
RES=`echo "10|01${LF}11|10$LF|$LF|0${LF}0|${LF}1|1${LF}000|01" | $SED "$CODE"`
expect "11${LF}1${LF}0${LF}0${LF}0${LF}0${LF}1"

sedcode advancedexamples uniq
RES=`echo a-a-b-c-c-c | tr - '\n' | $SED "$CODE"`; expect "a${LF}b${LF}c"
RES=`echo "a${LF}a" | $SED "$CODE"`; expect a
RES=`echo a | $SED "$CODE"`; expect a
RES=`echo | $SED "$CODE"`; expect

sedcode advancedexamples vigenere
RES=`{ echo LEMON; echo ATTACKATDAWN; } | $SED "$CODE"`
expect LXFOPVEFRNHR

sedcode advancedexamples dijkstra
RES=`echo '<1,><1,2,xxxx><1,3,x><3,2,xx><2,4,x>' | $SED "$CODE"`
expect '<1.><3.x><2.xxx><4.xxxx><1,2,xxxx><1,3,x><3,2,xx><2,4,x>'
