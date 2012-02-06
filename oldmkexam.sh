#!/bin/bash

# ./mkexam <asignatura> <examen>
# ./mkexam.sh IPe 20040701

file=$1-$2

set -e

./exam_gen.py $1 $2 > $file.xml
sabcmd xsl/latex_view.xsl $file.xml $file.tex
pdflatex --interaction=batchmode $file.tex
pdflatex --interaction=batchmode $file.tex
