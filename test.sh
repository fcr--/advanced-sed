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

LF='
'
X1=x; X2=x$X1; X3=x$X2; X4=x$X3; X5=x$X4; X6=x$X5; X7=x$X6; X8=x$X7; X9=x$X8
Y1=y; Y2=y$Y1; Y3=y$Y2; Y4=y$Y3; Y5=y$Y4; Y6=y$Y5; Y7=y$Y6; Y8=y$Y7; Y9=y$Y8

sedcode toolset logarithm
RES=`echo "$LF$X1$LF$X2$LF$X3$LF$X4$LF$X5$LF$X7$LF$X8$LF$X9" | $SED "$CODE"`
expect "$LF$LF$Y1$LF$Y1$LF$Y2$LF$Y2$LF$Y2$LF$Y3$LF$Y3"

sedcode toolset minimum
RES=`echo "|${LF}x|$LF|x${LF}x|x${LF}xx|xxx${LF}xxxxx|xxx" | $SED "$CODE"`
expect "$LF$LF${LF}x${LF}xx${LF}xxx"

sedcode toolset maximum
RES=`echo "|${LF}x|$LF|x${LF}x|x${LF}xx|xxx${LF}xxxxx|xxx" | $SED "$CODE"`
expect "${LF}x${LF}x${LF}x${LF}xxx${LF}xxxxx"

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

sedcode advancedexamples treeheight
RES=`echo '[[[[a],5,4]],5,[[],[]]]' | $SED "$CODE"`; expect xxxx
RES=`echo '[1,[[5],8],10,[3,2],5]' | $SED "$CODE"`; expect xxx

sedcode advancedexamples dijkstra
RES=`echo '<1,><1,2,xxxx><1,3,x><3,2,xx><2,4,x>' | $SED "$CODE"`
expect '<1.><3.x><2.xxx><4.xxxx><1,2,xxxx><1,3,x><3,2,xx><2,4,x>'
