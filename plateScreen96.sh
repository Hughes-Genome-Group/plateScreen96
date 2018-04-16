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

minLenSet(){
    
    # Set them - along given parameters.
    
    if [ "${MINLEN8}" -eq 1000 ];then
        MINLEN8=${minLen}
    fi
    
    if [ "${MINLEN12}" -eq 1000 ];then
        MINLEN12=${minLen}
    fi
    
unset minLen    
    
}

printRunStartArraysFastq(){
    
    echo
    echo "Ready to run ! - here printout of main for loop parameters : "
    echo
   
    for k in $( seq 0 $((${#nameList[@]} - 1)) ); do
        echo "nameList[$k]  ${nameList[$k]}"
    done    

    echo    

    for k in $( seq 0 $((${#fileList1[@]} - 1)) ); do
        echo "fileList1[$k]  ${fileList1[$k]}"
    done    
    echo    
        
    if [ "${SINGLE_END}" -eq 0 ] ; then
      
    for k in $( seq 0 $((${#fileList2[@]} - 1)) ); do
        echo "fileList2[$k]  ${fileList2[$k]}"
    done    
    echo          
        
    fi
    
    
}

printRunStartArraysIndex(){
    
    echo
    echo "Set the index file parameters ! - here printout of them : "
    echo
   
    echo "SPACERrev ${SPACER12}"
    echo "PRIMERrev ${PRIMER12}"
    echo
    
    echo -e "REVindexName\tplateCoord\tsequence\trevCompl"
    echo
    
    for k in $( seq 0 $((${#indexNames12[@]} - 1)) ); do
        echo -e "${indexNames12[$k]}\t${indexShortNames12[$k]}\t${indexSeqs12[$k]}\t${indRevSqs12[$k]}"
    done
    
    echo "----------------------------------"
    
    echo
    echo "SPACERfwd ${SPACER8}"
    echo "PRIMERfwd ${PRIMER8}"
    echo
    
    echo -e "FWDindexName\tplateCoord\tsequence\trevCompl"
    echo

    for k in $( seq 0 $((${#indexNames8[@]} - 1)) ); do
        echo -e "${indexNames8[$k]}\t${indexShortNames8[$k]}\t${indexSeqs8[$k]}\t${indRevSqs8[$k]}"
    done
    
    echo
    
}

# ------------------------------------------

LANES=1
GZIP=0
SINGLE_END=0

# echo "--singleEnd ( to run single end sequencing files - default behavior is paired end files)"
# THIS WAS NEVER IMPLEMENTED FULLY - AS IT DOES NOT MAKE SENSE TO USE SINGLE END SEQUENCING IN THIS SITUATION (INDICES WILL NOT BE RESOLVED VERY WELL)
# BELOW IN DETAIL, HOW LONG THE SINGLE-END SUPPORT REACHES.
# Single end support : not fully implemented. The flag exists and is fully integrated to the code.
# The fastqs can be red in (as using NGseqBasic subs to do this) and tested for integrity (as using pyramid subs to do this),
# but they will not be analysed properly (will generate a lot of errors of "missing R2 file" in the analysis part of tha code
# - the single end support for the 96-plate specific parts of the code is not built. 21Feb2017

GENOME="UNDEFINED"

flashX=0
SONICATIONSIZE=300
FLASHOVERLAP=40
MINPCRCOUNT=100
MAXPERWELL=20

# This is just to set values to the below 2 - never to be used in the script !
minLen=0
# Giving unrealistic values here, to keep track if user has set these or not.
MINLEN8=1000
MINLEN12=1000


timestamp=$( date +%d%b%Y_%H_%M )

#------------------------------------------
# Help requests ..


if [ $# -eq 1 ]
then
if [ $@ == "-h" ] || [ $@ == "--help" ]
then
    
PipeTopPath="$( which $0 | sed 's/\/plateScreen96.sh$//' )"
BashHelpersPath="${PipeTopPath}/bin/bashHelpers"
. ${BashHelpersPath}/usageAndVersion.sh
    
usage

exit 0

fi
fi


#------------------------------------------

echo "plateScreen96.sh - by Jelena Telenius, 14/02/2017"
echo
timepoint=$( date )
echo "run started : ${timepoint}"
echo
echo "Script located at"
which $0
echo

echo "RUNNING IN MACHINE : "
hostname --long

echo "run called with parameters :"
echo "plateScreen96.sh" $@
echo

echo "" > runSummary.txt
SUMMARYFILE=$( fp runSummary.txt )

echo "plateScreen96.sh - by Jelena Telenius, 14/02/2017" >> ${SUMMARYFILE}
echo >> ${SUMMARYFILE}
timepoint=$( date ) >> ${SUMMARYFILE}
echo "run started : ${timepoint}" >> ${SUMMARYFILE}
echo >> ${SUMMARYFILE}
echo "Script located at" >> ${SUMMARYFILE}
which $0 >> ${SUMMARYFILE}
echo >> ${SUMMARYFILE}

echo "RUNNING IN MACHINE : " >> ${SUMMARYFILE}
hostname --long >> ${SUMMARYFILE}

echo "run called with parameters :" >> ${SUMMARYFILE}
echo "plateScreen96.sh" $@ >> ${SUMMARYFILE}
echo >> ${SUMMARYFILE}

# For making sure we know where we are ..
weAreHere=$( pwd )

#------------------------------------------

# Loading subroutines in ..

echo "Loading subroutines in .."

PipeTopPath="$( which $0 | sed 's/\/plateScreen96.sh$//' )"

BashHelpersPath="${PipeTopPath}/bin/bashHelpers"
PerlHelpersPath="${PipeTopPath}/bin/perlHelpers"
PythonHelpersPath="${PipeTopPath}/bin/pythonHelpers"
RHelpersPath="${PipeTopPath}/bin/rHelpers"

configFilesPath="${PipeTopPath}/config"

# READING THE PARAMETER FILES IN (in NGseqBasic style)
. ${BashHelpersPath}/parameterFileReaders.sh
# TEST THE FASTQ PARAMETER FILES FOR INCONSISTENCIES (pyramid VS004 17Feb2017 copied subroutines - only testing, no generating or parsing)
. ${BashHelpersPath}/fastqChecksFromPyramid.sh

# LOADING FASTQS AND COMBINING LANES (NGseqBasic style - basic subroutines, tester subs in GEObuilder style)
. ${BashHelpersPath}/inputFastqs.sh

# RUNNING THE ACTUAL ANALYSIS
. ${BashHelpersPath}/runscript.sh

# PRINTING HELP AND VERSION MESSAGES
. ${BashHelpersPath}/usageAndVersion.sh

# PRINTING TO LOG AND ERROR FILES
. ${BashHelpersPath}/logFilePrinter.sh
# TEST THE EXISTENCE OF INPUT FILES
. ${BashHelpersPath}/fileTesters.sh

#------------------------------------------

echo
echo "PipeTopPath ${PipeTopPath}"
echo "BashHelpersPath ${BashHelpersPath}"
echo "PerlHelpersPath ${PerlHelpersPath}"
echo "PythonHelpersPath ${PythonHelpersPath}"
echo "RHelpersPath ${RHelpersPath}"
echo "configFilesPath ${configFilesPath}"
echo

#------------------------------------------

# Calling in the CONFIGURATION script and its default setup :

echo "Calling in the conf/*.sh scripts and their default setup .."

supportedGenomes=()
GenomeFastaList=()

. ${confFolder}/loadNeededTools.sh
. ${confFolder}/genomeBuildSetup.sh

setGenomeLocations

echo 
echo "Supported genomes : "
for g in $( seq 0 $((${#supportedGenomes[@]}-1)) ); do echo -n "${supportedGenomes[$g]} "; done
echo 
echo

#------------------------------------------

# Blat parameter defaults :

# -minIdentity=0 -minScore=0 -stepSize=1 -tileSize=6 -minMatch=1

stepSize=1
tileSize=6
minScore=0
minIdentity=0
minMatch=1

#------------------------------------------


OPTS=`getopt -o h,g: --long help,lanes:,singleEnd,gz,flashX:,sonicationSize:,flashOverlap:,minPCRcount:,minLen:,minLen8:,minLen12:,maxPerWell:,stepSize:,tileSize:,minScore:,minIdentity:,minMatch: -- "$@"`
if [ $? != 0 ]
then
    usage ;
fi

eval set -- "$OPTS"

while true ; do
    case "$1" in
        -h) usage ; shift;;
        -g) GENOME=$2 ; shift 2;;
        --help) usage ; shift;;
        --lanes) LANES=$2 ; shift 2;;
        --singleEnd) SINGLE_END=1 ; shift;;
        --gz) GZIP=1 ; shift;;
        --flashX) flashX=$2 ; shift 2;;
        --sonicationSize) SONICATIONSIZE=$2 ; shift 2;;
        --flashOverlap) FLASHOVERLAP=$2 ; shift 2;;
        --minPCRcount) MINPCRCOUNT=$2 ; shift 2;;
        --minLen) minLen=$2 ; shift 2;;
        --minLenFwd) MINLEN8=$2 ; shift 2;;
        --minLenRev) MINLEN12=$2 ; shift 2;;
        --maxPerWell) MAXPERWELL=$2 ; shift 2;;
        --stepSize) stepSize=$2 ; shift 2;;
        --tileSize) tileSize==$2 ; shift 2;;
        --minScore) minScore=$2 ; shift 2;;
        --minIdentity) minIdentity=$2 ; shift 2;;
        --minMatch) minMatch=$2 ; shift 2;;
        --) shift; break;;
    esac
done

#---------------------------------------------

# Set MINLEN parameters ..
minLenSet

# Set BLAT parameters ..

# -minIdentity=0 -minScore=0 -stepSize=1 -tileSize=6 -minMatch=1

blatParams="-minIdentity=${minIdentity} -minScore=${minScore} stepSize=${stepSize} -tileSize=${tileSize} -minMatch=${minMatch}"

# --------------------------------------------

if [ "${GENOME}" == "UNDEFINED" ]; then
    echo  >&2
    echo "Give the GENOME BUILD to use, with parameter -g (for example -g mm9) ! Now it wasn't given - 96 well plate analysis aborted !"  >&2
    echo  >&2
    echo "Usage instructions available with :"  >&2
    echo "plateScreen96.sh --help "  >&2
    echo  >&2
    exit 1    
fi

#--------Generating-the-parameter-files-for-the-subscripts------------------------------------------------------

# If any param file is missing ..
if [ ! -s "./PIPE_fastqPaths.txt" ] || [ ! -s "./PIPE_spacerBarcodePrimer_FWD.txt" ] || [ ! -s "./PIPE_spacerBarcodePrimer_REV.txt" ] || [ ! -s "./PIPE_targetLocus_${GENOME}.bed" ] ;then
    
    
if [ ! -s "./PIPE_fastqPaths.txt" ] ;then
    echo  >&2
    echo "PIPE_fastqPaths.txt file not found : fastq paths cannot be set ! - 96 well plate analysis aborted"  >&2
    echo  >&2
    echo "Usage instructions available with :"  >&2
    echo "plateScreen96.sh --help "  >&2
    echo  >&2
fi

if [ ! -s "./PIPE_spacerBarcodePrimer_FWD.txt" ] ;then
    echo  >&2
    echo "PIPE_spacerBarcodePrimer_FWD.txt file not found : Forward indices of the design cannot be set ! - 96 well plate analysis aborted"  >&2
    echo  >&2
    echo "Usage instructions available with :"  >&2
    echo "plateScreen96.sh --help "  >&2
    echo  >&2
fi

if [ ! -s "./PIPE_spacerBarcodePrimer_REV.txt" ] ;then
    echo  >&2
    echo "PIPE_spacerBarcodePrimer_REV.txt file not found : Reverse indices of the design cannot be set ! - 96 well plate analysis aborted"  >&2
    echo  >&2
    echo "Usage instructions available with :"  >&2
    echo "plateScreen96.sh --help "  >&2
    echo  >&2

fi

if [ ! -s "./PIPE_targetLocus_${GENOME}.bed" ]; then
    echo  >&2
    echo "No target locus coordinate file PIPE_targetLocus_${GENOME}.bed found !  - 96 well plate analysis aborted"  >&2
    echo  >&2
    echo "Usage instructions available with :"  >&2
    echo "plateScreen96.sh --help "  >&2
    echo  >&2
fi

exit 1
    
fi


#---------------------------------------------------------
# Here parsing the parameter files - if they are not purely tab-limited, but partially space-limited, or multiple-tab limited, this fixes it.
# Also, removing emptylines.

echo
echo "PARAMETER FILES GIVEN IN RUN FOLDER :"
echo

for file in ./PIPE*.txt
    do
        echo ${file}
        sed -i 's/\s\s*/\t/g' ${file}
        sed -i 's/^\s*//' ${file}
        sed -i 's/\s*$//' ${file}
        mv -f ${file} TEMP.txt
        cat TEMP.txt | sed 's/^\s*$//' | grep -v "^\s*$" > ${file}
        rm -f TEMP.txt
    done

for file in ./PIPE*.bed
    do
        echo ${file}
        sed -i 's/\s\s*/\t/g' ${file}
        sed -i 's/^\s//' ${file}
        sed -i 's/\s$//' ${file}
        mv -f ${file} TEMP.txt
        cat TEMP.txt | sed 's/^\s*$//' | grep -v "^\s*$" > ${file}
        rm -f TEMP.txt
    done

#---------------------------------------------------------

echo
echo "Run with parameters :"
echo ""


echo "GENOME ${GENOME}"
echo
echo "LANES ${LANES}"
echo "GZIP ${GZIP}"
# echo "SINGLE_END ${SINGLE_END}"
echo
echo "flashX ${flashX} "
echo "SONICATIONSIZE ${SONICATIONSIZE}"
echo "FLASHOVERLAP ${FLASHOVERLAP}"
echo "MINPCRCOUNT ${MINPCRCOUNT}"
echo "MINLENfwd ${MINLEN8}"
echo "MINLENrev ${MINLEN12}"
echo "MAXPERWELL ${MAXPERWELL}"


echo

#---------------------------------------------------------

echo >> ${SUMMARYFILE}
echo "Run with parameters :" >> ${SUMMARYFILE}
echo "" >> ${SUMMARYFILE}


echo "GENOME ${GENOME}" >> ${SUMMARYFILE}
echo >> ${SUMMARYFILE}
echo "LANES ${LANES}" >> ${SUMMARYFILE}
echo "GZIP ${GZIP}" >> ${SUMMARYFILE}
# echo "SINGLE_END ${SINGLE_END}" >> ${SUMMARYFILE}
echo >> ${SUMMARYFILE}
echo "flashX ${flashX} " >> ${SUMMARYFILE}
echo "SONICATIONSIZE ${SONICATIONSIZE}" >> ${SUMMARYFILE}
echo "FLASHOVERLAP ${FLASHOVERLAP}" >> ${SUMMARYFILE}
echo "MINPCRCOUNT ${MINPCRCOUNT}" >> ${SUMMARYFILE}
echo "MINLENfwd ${MINLEN8}" >> ${SUMMARYFILE}
echo "MINLENrev ${MINLEN12}" >> ${SUMMARYFILE}
echo "MAXPERWELL ${MAXPERWELL}" >> ${SUMMARYFILE}
echo "blatParams ${blatParams}"


echo >> ${SUMMARYFILE}


# ##########################################################################################
# FIRST PART - PARAMETER FILE INTEGRITY TESTS (using pyramid-copied subroutines)
# ##########################################################################################

# Testing that parameter files make sense .
# If not, after tests crashing the run.

#--------THE-TEST-PARAMETER-FILE-LOOP-over-all-FASTQ-files------------------------------------------------------

printThis="Found parameter file PIPE_fastqPaths.txt - will check that the FASTQ parameters are fine .."
printNewChapterToLogFile

fastqDataOK=1

rm -rf TEMPdir
mkdir TEMPdir
cd TEMPdir
# Exit, if it didn't happen : avoid overwriting intact PIPE_fastqPaths.txt just because some crazy error.
if [ "$( basename $( pwd ))" != "TEMPdir" ]; then print "Couldn't make a TEMP dir for exploring parameter files - exiting ! " >&2 ; exit 1 ; fi

    # Test that we have uniq lines, uniq files, uniq lanes, etc, here ..
    # ( using PYRAMID VS004 copied 17Feb2017 subroutines )
    
    # The divideFastqFilenames needs file ../PIPE_fastqPaths.txt to read in (this has rep column as 2nd column)..
    rm -f PIPE_fastqPaths.txt
    cut -f 1 ../PIPE_fastqPaths.txt > TEMPcol1.txt
    # Generate the rep column by repeating name column.
    paste TEMPcol1.txt ../PIPE_fastqPaths.txt > PIPE_fastqPaths.txt
    rm -f TEMPcol1.txt
    
    checkFastqFiles
    
    if [ -s "./FASTQ_LOAD.err" ]; then
        mv FASTQ_LOAD.err ../.
    fi
    
cd ..
rm -rf TEMPdir

# The above generates FASTQ_LOAD.err - checking for the existence of it is enough to see if it went wrong !
# Also - parameter value fastqDataOK=0 would tell the same.


#--------THE-LOOP-over-all-INDEX-LIST-files------------------------------------------------------  

printThis="Found parameter file PIPE_spacerBarcodePrimer_FWD.txt - will check that INDEX DATA parameters are fine .."
printNewChapterToLogFile

indexDataFWDOK=1
whichFileName="FWD"

indexParameterFileTester


# The above generates INDEXfileFWD_LOAD.err - checking for the existence of it is enough to see if it went wrong !
# Also - parameter value indexDataFWDOK=0 would tell the same.

#--------------------------------------------------------------  

printThis="Found parameter file PIPE_spacerBarcodePrimer_REV.txt - will check that INDEX DATA parameters are fine .."
printNewChapterToLogFile

indexDataREVOK=1
whichFileName="REV"

indexParameterFileTester

# The above generates INDEXfileREV_LOAD.err - checking for the existence of it is enough to see if it went wrong !
# Also - parameter value indexDataEEVOK=0 would tell the same.

#--------Crashing-if-needed---------------------------------------------------------------------

if [ "${fastqDataOK}" -eq 0 ] || [ "${indexDataFWDOK}" -eq 0 ] || [ "${indexDataREVOK}" -eq 0 ] ; then

printThis="Run crashed - parameter files given wrong. Check output files FASTQ_LOAD.err and/or INDEXfileFWD_LOAD.err INDEXfileREV_LOAD.err"
printToLogFile

printThis="  fastqDataOK ${fastqDataOK}\n indexDataFWDok ${indexData8OK}\nindexDataREVok ${indexData12OK}"
printToLogFile

if [ -s "./FASTQ_LOAD.err" ] ; then
    cat FASTQ_LOAD.err  >&2
    cat FASTQ_LOAD.err  
fi
 
if [ -s "./INDEXfileFWD_LOAD.err" ] ; then
    cat INDEXfileFWD_LOAD.err  >&2
    cat INDEXfileFWD_LOAD.err
fi

if [ -s "./INDEXfileREV_LOAD.err" ] ; then
    cat INDEXfileREV_LOAD.err  >&2
    cat INDEXfileREV_LOAD.err
fi

exit 1

fi

# ##########################################################################################
# SECOND PART - SETTING UP THE GENOME AND FETCHING FASTA ..
# ##########################################################################################

#--------Setting-the-environment------------------------------------------------------------

# Loading the environment - either with module system or setting them into path.
# This subroutine comes from conf/config.sh file

printThis="LOADING RUNNING ENVIRONMENT"
printToLogFile

setPathsForPipe


# convert --version
# cluster nodes don't have convert (so converting multiple pngs to pdf is not one command only).

#--------THE-LOOP-over-all-GENOME-dependent-files------------------------------------------------------  

# Here we need to :
# 1) check that the genome is supported
# 2) set the genome fasta file
# 3) fetch the fasta - and save it already now, for future use.
# 4) check that the fetched fasta is fine

#--------Reading-target-locus-file------------------------------------------------------------

printThis="Found parameter file PIPE_targetLocus_${GENOME}.bed - will check that TARGET LOCUS coordinates are fine .."
printNewChapterToLogFile

setGenomeFasta

weHaveHighlight=0
howManyHighlights=0
highLightStarts=""
highLightEnds=""

targetLocusDataOK=1
fetchTargetLocus
# weHaveHighlight will be 1 or 0, after this, depending on whether we found columns 4,5 etc (for highlighting)

# The above generates TARGETlocus_LOAD.err - checking for the existence of it is enough to see if it went wrong !
# Also - parameter value targetLocusDataOK=0 would tell the same.

echo "weHaveHighlight ${weHaveHighlight}" >> ${SUMMARYFILE}
echo "howManyHighlights ${howManyHighlights}" >> ${SUMMARYFILE}
echo "highLightStarts ${highLightStarts}" >> ${SUMMARYFILE}
echo "highLightEnds ${highLightEnds}" >> ${SUMMARYFILE}

#--------Crashing-if-needed---------------------------------------------------------------------

# If fasta wasn't fine :

if [ "${targetLocusDataOK}" -eq 0 ] ; then

    printThis="Run crashed - parameter files given wrong. Check output file TARGETlocus_LOAD.err "
    printToLogFile

    cat TARGETlocus_LOAD.err  >&2

    exit 1

fi

# ---------------------------------------

# Printing the generated fasta..

echo "All fine !"

echo
echo "Here the generated fasta file (onto which we will map our data with blat) : "
echo
cat targetLocus.fa
echo

echo >> ${SUMMARYFILE}
echo "Here the generated fasta file (onto which we will map our data with blat) : " >> ${SUMMARYFILE}
echo >> ${SUMMARYFILE}
cat targetLocus.fa >> ${SUMMARYFILE}
echo >> ${SUMMARYFILE}

#--------Reading-index-files------------------------------------------------------------

printThis="Found parameter files PIPE_spacerBarcodePrimer_REV.txt and PIPE_spacerBarcodePrimer_FWD.txt - will now set the INDEX parameters !"
printNewChapterToLogFile

indexNames12=()
indexSeqs12=()
indRevSqs12=()
    
indexNames8=()
indexSeqs8=()
indRevSqs8=()


printThis="Now running : indexParameterFileReader"
printToLogFile

primersOK=1
indexParameterFileReader
if [ "${primersOK}" -ne 1 ]; then
  printThis="Couldn't find FORWARD and/or REVERSE primer within the target locus. - Aborting !\nCheck error messages in PRIMER_ERRORS.log file !" 
  printToLogFile
  exit 1
fi

printThis="Now running : printRunStartArraysIndex"
printToLogFile

printRunStartArraysIndex

# Finding the "common denominators" - the shortest "still-resolving" part of the index :

printThis="Now running : shortestResolvingIndex"
printToLogFile

last8uniq=0
last12uniq=0
shortestResolvingIndex
# The above sets also the minIndexSeqs arrays (which we don't actually need in the run. But in case we some point in future need them ..)
# minIndexSeqs12=()
# minIndexSeqs8=()

echo
echo "NOTE !! the shortest resolving indices are NOT used in the run."
echo "Instead, full index sequence is required."
echo "Inform Jelena about all samples which would need the shortest resolving indices to be taken into account !"
echo

echo >> ${SUMMARYFILE}
echo "NOTE !! the shortest resolving indices are NOT used in the run." >> ${SUMMARYFILE}
echo "Instead, full index sequence is required." >> ${SUMMARYFILE}
echo "Inform Jelena about all samples which would need the shortest resolving indices to be taken into account !" >> ${SUMMARYFILE}
echo >> ${SUMMARYFILE}


# Setting the "effective primer" - for parsing.
# That is, if we want to include sequences which don't have full PRIMER..

printThis="Now running : setEffectivePrimer"
printToLogFile

effPrimer8=""
effPrimer12=""
effPrimer8=""
effPrimer12=""

setEffectivePrimer


# ##########################################################################################
# THIRD PART - RUNNING THE STUFF - NOW AS WE KNOW PARAMETER FILES ARE FINE ..
# ##########################################################################################


#--------THE-LOOP-over-all-FASTQ-files------------------------------------------------------   

printThis="Found parameter file PIPE_fastqPaths.txt - will proceed with FASTQ file storing !"
printNewChapterToLogFile

# pwd >&2
cd ${weAreHere} 
# pwd >&2

    nameList=()
    fileList1=()
    fileList2=()
    fastqParameterFileReader
    # The above reads PIPE_fastqPaths.txt
    # And sets these :
    # LISTS : nameList fileList1 fileList2
    
    printRunStartArraysFastq

for (( i=0; i<=$(( ${#nameList[@]} -1 )); i++ ))
do
    printThis="Starting FASTQ loading for sample : ${nameList[$i]}"
    printNewChapterToLogFile
    
    echo "" >> ${SUMMARYFILE}
    echo "---------------------------------------------------" >> ${SUMMARYFILE}
    echo "Starting FASTQ loading for sample : ${nameList[$i]}" >> ${SUMMARYFILE}
    echo "---------------------------------------------------" >> ${SUMMARYFILE}
    echo "" >> ${SUMMARYFILE}
    
    mkdir ${nameList[i]}
    cd ${nameList[i]}
    
    pwd
    pwd >&2
    
    #Fetch FASTQ :
    if [ "$LANES" -eq 1 ] ; then 
    # If we have single lane sequencing.
    fetchFastq
    inspectFastq
    # The actual pipe run !
    printThis="Fastqs loaded - Starting THE 96-WELL ANALYSER RUN for sample : ${nameList[$i]}"
    printNewChapterToLogFile

    echo "---------------------------------------------------" >> ${SUMMARYFILE}
    echo "Fastqs loaded - Starting THE 96-WELL ANALYSER RUN for sample : ${nameList[$i]}" >> ${SUMMARYFILE}
    echo "---------------------------------------------------" >> ${SUMMARYFILE}
    run96wellPipe
    
    else
    # If we have MULTIPLE lanes from sequencing.
    fetchFastqMultilane
    inspectFastqMultilane
    # The actual pipe run !
    printThis="Fastqs loaded - Starting THE 96-WELL ANALYSER RUN for sample : ${nameList[$i]}"
    printNewChapterToLogFile
    
    echo "---------------------------------------------------" >> ${SUMMARYFILE}
    echo "Fastqs loaded - Starting THE 96-WELL ANALYSER RUN for sample : ${nameList[$i]}" >> ${SUMMARYFILE}
    echo "---------------------------------------------------" >> ${SUMMARYFILE}   
    run96wellPipe
    
    fi

    cd ..

done

# ----------------------------------------
# All done !

timepoint=$( date )
echo
echo "run finished : ${timepoint}"
echo

cat ${SUMMARYFILE} | grep convert > PDFgeneratorCommands.txt

echo >> ${SUMMARYFILE}
echo "run finished : ${timepoint}" >> ${SUMMARYFILE}
echo >> ${SUMMARYFILE}

filenametimepoint=$( date +%d%b%Y_%H_%M )

mv -f runSummary.txt runSummary_${filenametimepoint}.txt

exit 0


