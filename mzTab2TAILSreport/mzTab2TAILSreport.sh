# Script to create duplex report from .consensusXML results

#!/bin/sh

# script directory
SCRIPT_PATH=$(dirname -- "$(readlink -f -- "$0")")

if [[ $1 == "" ]]
then
echo "Please specify a file."
exit
fi

# input file
FILE=$1; shift
FILE_ABSOLUTE=$(readlink -f -- $FILE)
FILE_PATH=$(dirname $FILE_ABSOLUTE)
FILE_BASE=$(basename $FILE_ABSOLUTE)
FILE_NAME=${FILE_BASE%.*}

WORK_DIRECTORY="$SCRIPT_PATH/$FILE_NAME"

if ! [[ -f $FILE ]]
then
echo "File does not exist."
exit
fi

echo 'Generating TAILS report from mzTab file '$FILE_ABSOLUTE'.'
mkdir "$WORK_DIRECTORY"
cd "$WORK_DIRECTORY"

# copy mzTab
cp $FILE_ABSOLUTE data.mzTab

# replace dummy by file name
sed -e 's/FILE_NAME_DUMMY/'$FILE_NAME'/g' "$SCRIPT_PATH/mzTab2TAILSreport.Snw" > mzTab2TAILSreport_temp.Snw

# Run the R code
R -e "Sweave('mzTab2TAILSreport_temp.Snw')"

pdflatex mzTab2TAILSreport_temp.tex

mv mzTab2TAILSreport_temp.pdf $FILE_PATH/$FILE_NAME.pdf
mv data.tsv $FILE_PATH/$FILE_NAME.tsv

# clean-up
rm data*
rm FcLogIntensity*
rm frequency*
rm mzTab2TAILSreport_temp.*

rmdir "$WORK_DIRECTORY"

cd $CURRENT_PATH
