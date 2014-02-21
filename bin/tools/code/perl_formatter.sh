#!/bin/sh

perltidy -nsfs -nolq -b -l 160 -bar -ce -nsbl -vt=2 -sot -sct $1
rm $1.bak
