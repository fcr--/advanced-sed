#!/bin/bash

sedcode() {
  FILE=$1
  NAME=$2
  CODE=$(${SED-sed} -n '
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

LF='
'

sedcode toolset fibonacci
RES=`echo "${LF}x${LF}xx${LF}xxx${LF}xxxx${LF}xxxxx${LF}xxxxxx" | sed "$CODE"`
expect "${LF}x${LF}x${LF}xx${LF}xxx${LF}xxxxx${LF}xxxxxxxx"

sedcode advancedexamples uniq
RES=`echo a-a-b-c-c-c | tr - '\n' | sed "$CODE"`; expect "a${LF}b${LF}c"
RES=`echo "a${LF}a" | sed "$CODE"`; expect a
RES=`echo a | sed "$CODE"`; expect a
RES=`echo | sed "$CODE"`; expect

sedcode advancedexamples vigenere
RES=`{ echo LEMON; echo ATTACKATDAWN; } | sed "$CODE"`
expect LXFOPVEFRNHR
