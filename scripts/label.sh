#!/bin/sh

# $Revision: 1.5 $
# $Date: 2003/03/03 02:53:52 $

prefix="$1"
if [ $# -lt 2 ]
then
	labelopt=""
else
	labelopt="-NRelease_00_$2"
fi

checkinopts="-l -zLT"
checkoutopts="-l -zLT"

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
			ci $checkinopts $labelopt $prefix/$i
			if [ $exe ] ; then chmod u+x $prefix/$i; fi
		fi
	done
fi

