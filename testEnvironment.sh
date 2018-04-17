#!/bin/bash

##########################################################################
# Copyright 2018, Jelena Telenius (jelena.telenius@ndcls.ox.ac.uk)       #
#                                                                        #
# This file is part of plateScreen96 .                                   #
#                                                                        #
# plateScreen96 is free software: you can redistribute it and/or modify  #
# it under the terms of the GNU General Public License as published by   #
# the Free Software Foundation, either version 3 of the License, or      #
# (at your option) any later version.                                    #
#                                                                        #
# plateScreen96 is distributed in the hope that it will be useful,       #
# but WITHOUT ANY WARRANTY; without even the implied warranty of         #
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the          #
# GNU General Public License for more details.                           #
#                                                                        #
# You should have received a copy of the GNU General Public License      #
# along with plateScreen96.  If not, see <http://www.gnu.org/licenses/>. #
##########################################################################

function finish {
echo
echo
echo "###########################################"
echo
echo "Finished with tests !"
echo
echo "Check that you got no errors in above listings !"
echo
echo "###########################################"
echo
echo
}
trap finish EXIT

# Set the default return value
exitCode=0

echo
echo "This is test for plateScreen96 configuration setup ! "
echo
echo "( For automated testing : Return value of the script is '0' if all clear or only warnings, and '1' if fatal errors encountered. )"
echo
sleep 2
echo "Running test script $0"
echo
echo "###########################################"
echo
echo "1) Testing that the UNIX basic tools (sed, awk, etc) are found"
echo "2) Testing that the needed scripts are found 'near by' the main script "
echo "3) Setting the environment - running the conf/config.sh , to set the user-defined parameters"
echo "4) Listing the set genome fastas"
echo "5) Testing that all toolkits (blat etc) are found in the user-defined locations"
echo
sleep 5

##########################################################################

echo "###########################################"
echo
echo "1) Testing that the UNIX basic tools (sed, awk, grep, et cetera) are found"
echo

echo "Calling sed .."
echo
sed --version | head -n 1
sed --version >> /dev/null
exitCode=$(( ${exitCode} + $? ))
echo

sleep 2

echo "Calling awk .."
echo
awk --version | head -n 1
awk --version >> /dev/null
exitCode=$(( ${exitCode} + $? ))
echo

sleep 2

echo "Calling grep .."
echo
grep --version | head -n 1
grep --version >> /dev/null
exitCode=$(( ${exitCode} + $? ))
echo

sleep 2

echo "Calling GNU coreutils .."
echo

cat    --version | head -n 1
cat    --version >> /dev/null
exitCode=$(( ${exitCode} + $? ))
chmod  --version | head -n 1
chmod  --version >> /dev/null
exitCode=$(( ${exitCode} + $? ))
cp     --version | head -n 1
cp     --version >> /dev/null
exitCode=$(( ${exitCode} + $? ))
cut    --version | head -n 1
cut    --version >> /dev/null
exitCode=$(( ${exitCode} + $? ))
date   --version | head -n 1
date   --version >> /dev/null
exitCode=$(( ${exitCode} + $? ))
join   --version | head -n 1
join   --version >> /dev/null
exitCode=$(( ${exitCode} + $? ))
ln     --version | head -n 1
ln     --version >> /dev/null
exitCode=$(( ${exitCode} + $? ))
ls     --version | head -n 1
ls     --version >> /dev/null
exitCode=$(( ${exitCode} + $? ))
mkdir  --version | head -n 1
mkdir  --version >> /dev/null
exitCode=$(( ${exitCode} + $? ))
mv     --version | head -n 1
mv     --version >> /dev/null
exitCode=$(( ${exitCode} + $? ))
paste  --version | head -n 1
paste  --version >> /dev/null
exitCode=$(( ${exitCode} + $? ))
rm     --version | head -n 1
rm     --version >> /dev/null
exitCode=$(( ${exitCode} + $? ))
rmdir  --version | head -n 1
rmdir  --version >> /dev/null
exitCode=$(( ${exitCode} + $? ))
sort   --version | head -n 1
sort   --version >> /dev/null
exitCode=$(( ${exitCode} + $? ))
tail   --version | head -n 1
tail   --version >> /dev/null
exitCode=$(( ${exitCode} + $? ))
tr     --version | head -n 1
tr     --version >> /dev/null
exitCode=$(( ${exitCode} + $? ))
uniq   --version | head -n 1
uniq   --version >> /dev/null
exitCode=$(( ${exitCode} + $? ))
unlink --version | head -n 1
unlink --version >> /dev/null
exitCode=$(( ${exitCode} + $? ))
dirname --version | head -n 1
dirname --version >> /dev/null
exitCode=$(( ${exitCode} + $? ))
echo

sleep 4

echo "Calling 'which'  .."
echo
which --version | head -n 1
which --version >> /dev/null
exitCode=$(( ${exitCode} + $? ))
echo

sleep 2

echo "Calling 'gzip'  .."
echo
gzip --version | head -n 1
gzip --version >> /dev/null
exitCode=$(( ${exitCode} + $? ))
echo

sleep 2

echo "Calling 'rev'  .."
echo
man rev | grep util-linux-ng
echo "testReverseCommand" | rev >> /dev/null
exitCode=$(( ${exitCode} + $? ))
echo

sleep 2


diffLoadFailed=0
echo "Calling 'diff' (optional - needed only in this tester script) .."
echo
diff --version | head -n 1
diff --version >> /dev/null
diffLoadFailed=$?
echo

sleep 2

echo "Calling 'hostname' (optional - it is only used to print out the name of the computer) .."
echo
hostname --version 2>&1 
echo

sleep 2

echo "Calling 'module' (optional - only needed if you set your  conf/loadNeededTools.sh   to use the module environment) .."
echo
module --version 2>&1 | head -n 2
echo

sleep 3

##########################################################################

# Test that the script files exist ..

echo "###########################################"
echo
echo "2) Testing that the needed scripts are found 'near by' the main script .."
echo

sleep 2

PipeTopPath="$( dirname $0 )"
dirname $0 >> /dev/null
exitCode=$(( ${exitCode} + $? ))

# From where to call the CONFIGURATION script..

configFilesPath="${PipeTopPath}/config"

BashHelpersPath="${PipeTopPath}/bin/bashHelpers"
PerlHelpersPath="${PipeTopPath}/bin/perlHelpers"
PythonHelpersPath="${PipeTopPath}/bin/pythonHelpers"
RHelpersPath="${PipeTopPath}/bin/rHelpers"

echo
echo "This is where they should be ( will soon see if they actually are there ) :"
echo
echo "PipeTopPath        ${PipeTopPath}"
echo "configFilesPath    ${configFilesPath}"
echo "BashHelpersPath    ${BashHelpersPath}"
echo "PerlHelpersPath    ${PerlHelpersPath}"
echo "PythonHelpersPath  ${PythonHelpersPath}"
echo "RHelpersPath       ${RHelpersPath}"
echo

sleep 4


scriptFilesMissing=0

# Check that it can find the scripts .. ( not checking all - believing that if these exist, the rest exist too )

echo
echo "Master script and its tester script :"
echo
ls ${PipeTopPath}/plateScreen96.sh
scriptFilesMissing=$(( ${scriptFilesMissing} + $? ))
ls ${PipeTopPath}/testEnvironment.sh 
scriptFilesMissing=$(( ${scriptFilesMissing} + $? ))
echo
sleep 3
echo "Bash subroutines :"
echo
ls ${BashHelpersPath}/cleaningUp.sh
scriptFilesMissing=$(( ${scriptFilesMissing} + $? ))
ls ${BashHelpersPath}/curateParsed.sh
scriptFilesMissing=$(( ${scriptFilesMissing} + $? ))
ls ${BashHelpersPath}/fastqChecksFromPyramid.sh
scriptFilesMissing=$(( ${scriptFilesMissing} + $? ))
ls ${BashHelpersPath}/fileTesters.sh
scriptFilesMissing=$(( ${scriptFilesMissing} + $? ))
ls ${BashHelpersPath}/fromPslToFigure.sh
scriptFilesMissing=$(( ${scriptFilesMissing} + $? ))
ls ${BashHelpersPath}/indexmanipulation.sh
scriptFilesMissing=$(( ${scriptFilesMissing} + $? ))
ls ${BashHelpersPath}/inputFastqs.sh
scriptFilesMissing=$(( ${scriptFilesMissing} + $? ))
ls ${BashHelpersPath}/logFilePrinter.sh
scriptFilesMissing=$(( ${scriptFilesMissing} + $? ))
ls ${BashHelpersPath}/parameterFileReaders.sh
scriptFilesMissing=$(( ${scriptFilesMissing} + $? ))
ls ${BashHelpersPath}/QC_and_Trimming.sh
scriptFilesMissing=$(( ${scriptFilesMissing} + $? ))
ls ${BashHelpersPath}/runscript.sh
scriptFilesMissing=$(( ${scriptFilesMissing} + $? ))
ls ${BashHelpersPath}/runscriptHelpers.sh
scriptFilesMissing=$(( ${scriptFilesMissing} + $? ))
ls ${BashHelpersPath}/usageAndVersion.sh
scriptFilesMissing=$(( ${scriptFilesMissing} + $? ))
echo
sleep 3
echo "Perl scripts :"
echo
ls ${PerlHelpersPath}/fastq_int_scores.pl
scriptFilesMissing=$(( ${scriptFilesMissing} + $? ))
echo
echo "Python scripts :"
echo
ls ${PythonHelpersPath}/figurer.py
scriptFilesMissing=$(( ${scriptFilesMissing} + $? ))
ls ${PythonHelpersPath}/figurerWithHighlight.py
scriptFilesMissing=$(( ${scriptFilesMissing} + $? ))
ls ${PythonHelpersPath}/figurerWithUnlimitedHighlight.py
scriptFilesMissing=$(( ${scriptFilesMissing} + $? ))
echo
echo "R scripts :"
echo
ls ${RHelpersPath}/makeOneFigure.R
scriptFilesMissing=$(( ${scriptFilesMissing} + $? ))
echo
sleep 3
echo "Configuration setters :"
echo
ls ${configFilesPath}/genomeBuildSetup.sh
scriptFilesMissing=$(( ${scriptFilesMissing} + $? ))
ls ${configFilesPath}/loadNeededTools.sh
scriptFilesMissing=$(( ${scriptFilesMissing} + $? ))
echo
sleep 3
echo "Configuration tester helpers :"
echo
ls ${BashHelpersPath}/validateSetup/g.txt
scriptFilesMissing=$(( ${scriptFilesMissing} + $? ))
ls ${BashHelpersPath}/validateSetup/l.txt
scriptFilesMissing=$(( ${scriptFilesMissing} + $? ))
echo
sleep 3

if [ "${scriptFilesMissing}" -ne 0 ]
then
echo
echo "###########################################"
echo
echo "ERROR !   The scripts plateScreen96.sh is dependent on, are not found in their correct relative paths !"
echo "          Maybe your tar archive was corrupted, or you meddled with the folder structure after unpacking ?"
echo
echo "###########################################"
echo
echo "This is what you SHOULD see if you run 'tree' command in your plateScreen96 folder :"
echo

echo ' |-- plateScreen96.sh'
echo ' |-- testEnvironment.sh'
echo ' |'
echo ' `-- bin'
echo '     |-- bashHelpers'
echo '     |   |-- cleaningUp.sh curateParsed.sh fastqChecksFromPyramid.sh'
echo '     |   |-- fileTesters.sh fromPslToFigure.sh indexmanipulation.sh'
echo '     |   |-- inputFastqs.sh logFilePrinter.sh'
echo '     |   |-- parameterFileReaders.sh QC_and_Trimming.sh'
echo '     |   `-- runscript.sh runscriptHelpers.sh usageAndVersion.sh'
echo '     |'
echo '     |-- perlHelpers'
echo '     |   `-- fastq_int_scores.pl'
echo '     |-- pythonHelpers'
echo '     |   `-- figurer.py figurerWithHighlight.py figurerWithUnlimitedHighlight.py'
echo '     `-- rHelpers'
echo '         `-- makeOneFigure.R'
echo ''
echo ' `-- config'
echo '     |-- genomeBuildSetup.sh'
echo '     `-- loadNeededTools.sh'
echo ''

sleep 4

# Return the value : 0 if only warnings, 1 if fatal problems.
exit 1

fi

exitCode=$(( ${exitCode} + ${scriptFilesMissing} ))
sleep 5

##########################################################################

# Test that user has made at least SOME changes to them (otherwise they are running with the WIMM configuration .. )

setupMade=0

echo
echo "###########################################"
echo
echo "3) Setting the environment - running the conf/(setupscripts).sh , to set the user-defined parameters"
echo

sleep 6


setupMade=1

TEMPcount=$(($( diff ${BashHelpersPath}/validateSetup/g.txt ${configFilesPath}/genomeBuildSetup.sh | grep -c "" )))

if [ "${TEMPcount}" -eq 0 ]
then
setupMade=0
echo
echo "WARNING ! It seems you haven't set up your Genome Fasta files !"
echo "          Add your Genome Fastas to this file : "
echo "          ${configFilesPath}/genomeBuildSetup.sh "
echo
sleep 6
fi

TEMPcount=$(($( diff ${BashHelpersPath}/validateSetup/l.txt ${configFilesPath}/loadNeededTools.sh | grep -c "" )))

if [ "${TEMPcount}" -eq 0 ]
then
setupMade=0
echo
echo "WARNING ! It seems you haven't set up the loading of your Needed Toolkits !"
echo "          Add your toolkit paths to this file : "
echo "          ${configFilesPath}/loadNeededTools.sh "
echo
echo "NOTE !!   You need to edit this file ALSO if you want to disable loading the toolkits via the above script."
echo "          To disable the loading of the tools, set : setToolLocations=0 "
echo
sleep 8
fi


# Only continue to the rest of the script, if there is some changes in the above listings ..

if [ "${setupMade}" -eq 0 ]
then
echo 
echo
echo "Could not finish testing, as you hadn't set up your environment !"
echo
echo "Set up your files according to instructions in :"
echo "http://sara.molbiol.ox.ac.uk/public/telenius/plate96/instructionsGeneral.html"
echo
sleep 4

if [ "${exitCode}" -gt 0 ]
then
exit 1
else
exit 0
fi

fi

##########################################################################

supportedGenomes=()
GenomeFastaList=()

# These have been checked earlier. Should exist now.
. ${configFilesPath}/loadNeededTools.sh
. ${configFilesPath}/genomeBuildSetup.sh

setGenomeLocations >/dev/null 2>&1
setPathsForPipe >/dev/null 2>&1

echo
sleep 4

echo "###########################################"
echo
echo "4) Listing the set genome fastas"
echo


echo "Supported genomes : "
echo
for g in $( seq 0 $((${#supportedGenomes[@]}-1)) ); do    
 echo "${supportedGenomes[$g]}"
done

echo
sleep 2

##########################################################################
echo
echo "Fasta files : "
echo
echo -e "GENOME\tFASTA file"
for g in $( seq 0 $((${#supportedGenomes[@]}-1)) ); do    

 echo -en "${supportedGenomes[$g]}\t${GenomeFastaList[$g]}"

TEMPcount=$(($( ls -1 ${GenomeFastaList[$g]}* | grep -c "" )))

if [ "${TEMPcount}" -eq 0 ]; then
    echo -e "\tGENOME FASTA FILE DOES NOT EXIST in the given location !!"
    exitCode=$(( ${exitCode} +1 ))
 else
    echo ""
 fi
 
done

echo
sleep 2

##########################################################################

echo "###########################################"
echo
echo "5) Testing that all toolkits (blat etc) are found in the user-defined locations"
echo

echo "Blat .."
echo
blat 2>&1 | head -n 1
which blat >> /dev/null
exitCode=$(( ${exitCode} + $? ))
echo

sleep 2

echo "Bedtools .."
echo
bedtools --version
bedtools --version >> /dev/null
exitCode=$(( ${exitCode} + $? ))

echo

sleep 2

echo "Flash .."
echo
flash --version
flash --version >> /dev/null
exitCode=$(( ${exitCode} + $? ))
echo

sleep 2

echo "FastqQC .. "
echo "(series 0.10.x is NOT supported. Check below, that you have 0.11.x )"
echo
fastqc --version
fastqc --version >> /dev/null
exitCode=$(( ${exitCode} + $? ))
echo

sleep 4

echo "MultiQC .. "
echo
multiqc --version
multiqc --version >> /dev/null
exitCode=$(( ${exitCode} + $? ))
echo

sleep 4

echo "Perl .."
echo
perl --version | head -n 5 | grep -v "^\s*$"
perl --version >> /dev/null
exitCode=$(( ${exitCode} + $? ))
echo

sleep 2

echo "R .."
echo
R --version | head -n 3
R --version >> /dev/null
exitCode=$(( ${exitCode} + $? ))
echo

sleep 2

echo "Python .."
echo "(Python 3.* is NOT supported. Check below, that you have Python 2.*)"
echo
python --version
python --version >> /dev/null
exitCode=$(( ${exitCode} + $? ))
echo

sleep 4

echo "Matplotlib - within python .."
echo
python -c "import matplotlib as mpl; print mpl.__version__" 
exitCode=$(( ${exitCode} + $? ))
echo

sleep 4


# Return the value : 0 if only warnings, 1 if fatal problems.
if [ "${exitCode}" -gt 0 ]
then
exit 1
else
exit 0
fi

