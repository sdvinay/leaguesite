#!/bin/sh

# $Revision: 1.4 $
# $Date: 2003/03/01 05:18:34 $

prefix="$1"
if [ $# -lt 2 ]
then
	labelopt=""
else
	labelopt="-NRelease_00_$2"
fi

if [ -d $prefix/RCS ]
then
	for i in `/bin/ls -A $prefix`
	do
		if [ -d $prefix/$i ] && [ $i != RCS ]
		then
			$0 $prefix/$i $2
		elif [ -f $prefix/$i ]
		then
			rcsdiff $prefix/$i
			if [ -x $prefix/$i ] ; then exe=1;  else exe=; fi
			ci -l $labelopt $prefix/$i
			if [ $exe ] ; then chmod u+x $prefix/$i; fi
		fi
	done
fi

