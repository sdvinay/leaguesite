#!/bin/sh

# $Revision$
# $Date$

prefix="$1"
if [ $# -lt 2 ]
then
	labelopt=""
else
	labelopt="-nRelease_00_$2"
fi

if [ -d $prefix/RCS ]
then
	for i in `/bin/ls $prefix`
	do
		if [ -d $prefix/$i ] && [ $i != RCS ]
		then
			$0 $prefix/$i $2
		elif [ -f $prefix/$i ]
		then
			rcsdiff $prefix/$i
			ci -l $labelopt $prefix/$i
		fi
	done
fi

