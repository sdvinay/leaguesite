#!$$sh_loc$$

# $Revision$
# $Date$

echo "Content-type: text/plain"
echo
echo


if [ $# = 0 ]
then
        num=20
else
        num=$1
fi


tail -$num $$_data_loc$$/bids.txt | sort -r



