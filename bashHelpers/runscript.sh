#!/bin/bash

# ------------------------------------------

# ONLY NEEDED INSIDE the runscript.sh :

# READ INDEX PARSING
. ${BashHelpersPath}/indexmanipulation.sh
# CURATE PARSED INDICES
. ${BashHelpersPath}/curateParsed.sh
# PARSE BLAT OUTPUT INTO FIGURE
. ${BashHelpersPath}/fromPslToFigure.sh
# CLEAN UP THE OUTPUT FOLDER
. ${BashHelpersPath}/cleaningUp.sh
# GENERAL HELPER SUBROUTINES (mainly read counters and QC subs)
. ${BashHelpersPath}/runscriptHelpers.sh

# ------------------------------------------

run96wellPipe(){
    
# ---------------------------------------------------
# 0) FastQC for raw reads.

printThis="Running fastQC for the input files .."
printToLogFile

${BashHelpersPath}/QC_and_Trimming.sh --fastqc

# ---------------------------------------------------
# 1a) stringent flash

printThis="Running flash for the input files .."
printToLogFile

#Check quality score sceme ..

intQuals=33

    LineCount=$(($( grep -c "" READ1.fastq )/4))
    
    if [ "${LineCount}" -gt 100000 ] ; then
        printThis="bowtieQuals=$( perl ${PerlHelpersPath}/fastq_int_scores.pl -i READ1.fastq -r 90000 )"
        printToLogFile
        bowtieQuals=$( perl ${PerlHelpersPath}/fastq_int_scores.pl -i READ1.fastq -r 90000 )
    else
        rounds=$((${LineCount}-10))
        printThis="bowtieQuals=$( perl ${PerlHelpersPath}/fastq_int_scores.pl -i READ1.fastq -r ${rounds} )"
        printToLogFile
        bowtieQuals=$( perl ${PerlHelpersPath}/fastq_int_scores.pl -i READ1.fastq -r ${rounds} )
    fi
    
    echo "Flash will be ran in quality score scheme : ${intQuals}"
    
echo "flash -x ${flashX} -M $((${SONICATIONSIZE}+50)) -m ${FLASHOVERLAP} -p ${intQuals} READ1.fastq READ2.fastq"
flash -x ${flashX} -M $((${SONICATIONSIZE}+50)) -m ${FLASHOVERLAP} -p ${intQuals} READ1.fastq READ2.fastq > flashing.log

cat flashing.log

# where 
# -x 0 how much mismatches allowed (ratio from 0 to 1) : to be hidden flag, as we don't want users to deviate from 0 here. So developer-flag.
# -M 350 library size (300) + 50 bases. Auto-calculated from the library size, which is user-given parameter. Defaults to 300.
#    This is to efficiently turn off the "parameters allowing mismatches in more easily when overlap is long"
#   As we consider ALL mismatches potentially real.
# -m 40 : the only user-specified parameter : how much the reads need to overlap. Default super stringent 40 bases.
 
rm -f READ1.fastq READ2.fastq
    
# ---------------------------------------------------
# 1b) fastqc for flashed, and non-flashed reads

# out.extendedFrags.fastq
# out.notCombined_1.fastq
# out.notCombined_2.fastq

mv -f out.extendedFrags.fastq FLASHextendedFrags.fastq
mv -f out.notCombined_1.fastq FLASHnotCombined_1.fastq
mv -f out.notCombined_2.fastq FLASHnotCombined_2.fastq

printThis="Running fastQC for the flash-combined file .."
printToLogFile

if [ -s FLASHextendedFrags.fastq ];then
${BashHelpersPath}/QC_and_Trimming.sh --fastqc --basenameR1 FLASHextendedFrags --single 1 
fi

printThis="Running fastQC for the reads not combine-able via flash .."
printToLogFile

if [ -s FLASHnotCombined_1.fastq ];then
${BashHelpersPath}/QC_and_Trimming.sh --fastqc --basenameR1 FLASHnotCombined_1 --basenameR2 FLASHnotCombined_2
fi

# ---------------------------------------------------
# FOR USER INFORMATION - MAX AMOUNT OF READS PARSE-ABLE IN FLASHED READS (which have index, but don't have spacer.)

parseablePreCounts

# ---------------------------------------------------
# FLASHED, NONFLASHED OUTPUT, INDEX SEQUENCES

# 2) flashed : indices parse, save only when both indices can be resolved
#    non-flashed : indices parse, both sequences to same line, save only when both indices can be resolved

# The one below 4 times :
# 8 index forward
# 8 index reverse
# 12 index forward
# 12 index reverse

# Using the EFFECTIVE primer here.
# And the EFFECTIVE spacer (first full lenght)

spacer8=${SPACER8}
spacer12=${SPACER12}
parseIndices
# Input files of above :
# FLASHextendedFrags.fastq
# FLASHnotCombined_1.fastq
# FLASHnotCombined_2.fastq
# Output files of above :


# The next round (for the unresolved ones) : possible SHORTER PRIMER sequences.
# (if parameters given so, that resolving "incomplete primer" is allowed)

# 1) Let's say our sequence is this : GATindexPPRRIIMMEERR
#    We now go from the end (let's say our parameter is -5 - so truncated primer 5 bases from the end is still fine) :
#    ^GATindexPPRRIIMMEER (1)
#    ^GATindexPPRRIIMMEE  (2)
#    ^GATindexPPRRIIMME   (3)
#    ^GATindexPPRRIIMM    (4)
#    ^GATindexPPRRIIM     (5)

# 2) The same - but now coming down in the front :

#    ^ATindexPPRRIIMMEER (1)
#    ^ATindexPPRRIIMMEE  (2)
#    ^ATindexPPRRIIMME   (3)
#    ^ATindexPPRRIIMM    (4)
#    ^ATindexPPRRIIM     (5)

# 3) etc --> all the way until we cannot resolve any more.

# The above (1-3) will be implemented in the parseIndices subroutine
# as a for loop which is loop of one, if the primer loop is not requested
# and loop of (5) if primer loop was requested (with value of -5).


# ---------------------------------------------------
# 3) FINAL FILTERING OF THE READS - fixing the "resolved" around.

# Now we have :

printThis="Listing run folder contents after index parsing : "
printNewChapterToLogFile

echo
ls -lht
echo

# FLASHextended_resolved.txt
# FLASHnotCombined_resolved.txt

# FLASHextended_nonResolved.txt
# FLASHnotCombined_nonResolved_1.txt
# FLASHnotCombined_nonResolved_2.txt

printThis="Counting parsed reads .. "
printNewChapterToLogFile

echo
echo "UNRESOLVED flashed reads :"
unresolvedFlashedCount=$( cat FLASHextended_nonResolved.txt | grep -v '^QUAL_' | grep -c "" )
echo ${unresolvedFlashedCount}
echo
echo "RESOLVED flashed reads ( before sanity checks ) :"
cat FLASHextended_resolved.txt | grep -v '^QUAL_' | grep -c ""
echo
echo "COMBINED conservative-resolved and unresolved (some will be still resolved below) unflashed reads :"

# marking if we have the resolved nonflashed or not..
nonflashedResolved=""
if [ -s "FLASHnotCombined_resolved.txt" ]; then nonflashedResolved="FLASHnotCombined_resolved.txt";fi
paste FLASHnotCombined_nonResolved_1.txt FLASHnotCombined_nonResolved_2.txt | cat -  ${nonflashedResolved} > FLASHnotCombined_forSanityChecks.txt
unresolvedNonFlashedCount=$( cat FLASHnotCombined_forSanityChecks.txt | grep -v '^QUAL_' | grep -c "" )
echo ${unresolvedNonFlashedCount}
echo

# --------------------------------------------
#
# Unresolved reads - digging deeper ...
#
# --------------------------------------------

printThis="Having a peek -  what was left in the UNRESOLVED reads .."
printNewChapterToLogFile

countFinalUnresolved


# --------------------------------------------
#
# Resolved, unresolved reads - fastqc reports !
#
# --------------------------------------------

printThis="Running fastQC for the PARSED - resolved and unresolved - files .."
printNewChapterToLogFile

finalFastQC

# -----------------------------------------

# Curate the resolved files ..

printThis="Final sanity checks after index parsing .."
printNewChapterToLogFile

curateParsed

echo
echo "Counts of resolved reads ( after sanity checks ) :"
echo
echo "Flashed reads :"
cat FLASHextended_SLpairs.txt | grep -c ""
echo
echo "Unflashed reads - R1, R2 :"
cat FLASHnotCombined_SLpairs.txt | grep -c ""
echo

# -----------------------------------------
# We wanted to do this (above - in curateParsed ) :
#
# 0) Save the qual-included files as "for troubleshooting" files
#
# 1) Take out only the sequences
# 2) Turn all of them so, that indices are in order S L
# 3) Check that all of them have both S and L indices available 
# 4) Check that the non-flashed reads have the SAME index in both (R1-R2) S and both (R1-R2) L (if they were resolved twice)
# 5) Provide counts statistics for filter steps (2) and (3) above
#
# --------------------------------------------

# Output of above :

# FLASHextended_SLpairs.txt
# FLASHnotCombined_SLpairs.txt

# --------------------------------------------

printThis="Listing run folder contents after sanity checks :"
printNewChapterToLogFile

ls -lht

# --------------------------------------------

# Now, this remains :

# 6) Sort, uniq counts
# 7) Make fasta for blat
# 8) Run blat

# 6) Sort, uniq counts

printThis="6) Count how many times each uniq sequence is seen .."
printToLogFile

uniqingAndItsQC

# 7) Make fasta for blat

printThis="7) Combine FLASHED and NONflashed to a single fasta file for blat .."
printToLogFile

# Make the NF reads index pair print ..

# Take out the index denominators ..
cat QCfilt_FLASHnotCombined_uniqSLpairs.txt | sed 's/L.*/L/' | sed 's/.*_//' > TEMP_Linds.txt
cat QCfilt_FLASHnotCombined_uniqSLpairs.txt | sed 's/.*S/S/' | sed 's/_.*//' > TEMP_Sinds.txt
paste TEMP_Sinds.txt TEMP_Linds.txt | sed 's/\s/_/' > NFreadIndexpair.txt
rm -f TEMP_Sinds.txt TEMP_Linds.txt

cat QCfilt_FLASHnotCombined_uniqSLpairs.txt | sed 's/S._//g' | sed 's/_.L//g' > NFseqs.txt

paste NFreadIndexpair.txt NFseqs.txt > NF_forCombine.txt
rm -f NFreadIndexpair.txt NFseqs.txt

# (1)    (2)    (3)    (4)    (5)
# Sind   Lind   seq1   seq2   count
# NF_forCombine.txt

#                                                                                          Sind   Lind   count  seq
cat QCfilt_FLASHextended_uniqSLpairs.txt | sed 's/_/\t/g' | awk '{ print ">S_Fid" NR "_"   $1 "_" $3 "_" $4 "_" $2 "_E\n" $2 }' > FLASHextended.fasta

#                                                                                      Sind   Lind   count  seq
cat NF_forCombine.txt | cut -f 3 --complement | sed 's/_/\t/g' | awk '{ print ">S_NF1id" NR "_" $1 "_" $2 "_" $4 "_" $3 "_E\n" $3 }' > FLASHnotCombined_1.fasta
cat NF_forCombine.txt | cut -f 2 --complement | sed 's/_/\t/g' | awk '{ print ">S_NF2id" NR "_" $1 "_" $2 "_" $4 "_" $3 "_E\n" $3 }' > FLASHnotCombined_2.fasta
rm -f NF_forCombine.txt

cat FLASHextended.fasta FLASHnotCombined_1.fasta FLASHnotCombined_2.fasta > ALLreads.fasta
rm -f FLASHextended.fasta FLASHnotCombined_1.fasta FLASHnotCombined_2.fasta

echo "Read count in the fasta file (input to BLAT) : "
inputBlatCount=$(($(($( cat ALLreads.fasta | grep -c "")))/2))
echo ${inputBlatCount}


# 8) Run blat

printThis="8) Run blat ( to see where exactly the reads reside in the locus of interest ) .."
printNewChapterToLogFile

echo
echo "Running blat .."
echo
# echo "blat -minIdentity=0 -minScore=0 -stepSize=1 -tileSize=6 -minMatch=1 ../targetLocus.fa ALLreads.fasta blatted.psl"
echo "blat ${blatParams} ../targetLocus.fa ALLreads.fasta blatted.psl"
echo

# blat -minIdentity=0 -minScore=0 -stepSize=1 -tileSize=6 -minMatch=1 ../targetLocus.fa ALLreads.fasta blatted.psl
blat ${blatParams} ../targetLocus.fa ALLreads.fasta blatted.psl

# Run blat QC-steps (what didn't map ..)

blatQC

# -----------------------------------------------------------

# Now, a whole lot of blat output parsing, before visualisations ..


# 9) Parse blatted.psl output file ..

printThis="9) Parsing blatted.psl output file .."
printNewChapterToLogFile

parseBlatPsl

# -----------------------------------------------------------

# 10) Last step before figure : combine files

parseTextForPythonFigure

# -----------------------------------------------------------

# 12) Make facets for ShinyApp

printThis="11) Make tables for (possible future support of) ShinyApp (for filtering the results interactively) .."
printNewChapterToLogFile

echo -e "orderNO\tflash\tindex1\tindex2\tPCRcount" > TEMPheading.txt

cat TEMPforShiny.txt | paste TEMPheading.txt - > blatted_parsedForShiny.txt

rm -f TEMPforShiny.txt TEMPheading.txt 


# -----------------------------------------------------------


# 13) Image generation ..

printThis="12) Image generation .."
printNewChapterToLogFile

# The parameter of the target sequence lenght - sets the print for the "closest one hundred" + 100
# (figure width how many bases )
if [ "${printingInBatches}" -eq 0 ]; then
basesForFigure=$( cat forFigure.txt | awk 'BEGIN {m=0} { if (length($0)>m) m=length($0)} END {print int(m/100)+1}')
else
basesForFigure=$( cat forFigure_[1234567890]*.txt | awk 'BEGIN {m=0} { if (length($0)>m) m=length($0)} END {print int(m/100)+1}')
fi
# Here the following :
#
# - Lines starting with letter 'D'
#
# read a line, separate (split) based on tab, print like this :
#
# orderNo [ index1 - index2 ]  F/NF1/NF2
# readCount ${count} 
#
# - Lines starting with letter 'S'
#
# the "case" ATCGN-' '  :to allow printing of the sequence.
# (these lines include both the long sequences and the Insertion sequences - thus we need to have ' ' space as allowed character here)
#
# - Lines starting with letter 'I'
#
# just printing : these are the extra lines to print for the Insertion mark ( \/ )
#
#
#

figurescript=""
figureparams=""
if [ "${weHaveHighlight}" -ne 0 ]; then
    # VS02
   # figurescript="figurerWithHighlight.py"
   # VS03 -->
   figurescript="figurerWithUnlimitedHighlight.py"
   figureparams="${basesForFigure} ${highLightStarts} ${highLightEnds}"
else
   figurescript="figurer.py"
   figureparams="${basesForFigure}"
fi
    

# If we have one file or more ..

figureGenerated=1
if [ "${printingInBatches}" -eq 0 ]; then

  printThis="${PythonHelpersPath}/${figurescript} forFigure.txt blattedFigure ${figureparams}"
  printToLogFile
  python ${PythonHelpersPath}/${figurescript} forFigure.txt blattedFigure ${figureparams}
  
  printThis="${PythonHelpersPath}/${figurescript} forFigure_withOrigSeq.txt blattedFigure_withOrigSeq ${figureparams}"
  printToLogFile
  python ${PythonHelpersPath}/${figurescript} forFigure_withOrigSeq.txt blattedFigure_withOrigSeq ${figureparams}

else

  if [ $(($( ls | grep forFigure | grep -c -v withOrigSeq ))) -gt 50 ]; then
    printThis="Too many sequences left - more than 50 output figures need to be generated. (That is approximately 20 reported sequences per well.)\n Skipping the figure generation. The text format file can be inspected in files forFigure*.txt"
    printToLogFile
    figureGenerated=0
  else
    for file in forFigure_*.txt
    do
    orderNo=$( echo ${file} | sed 's/^forFigure//' | sed 's/.txt$//' )
    printThis="${PythonHelpersPath}/${figurescript} ${file} blattedFigure${orderNo} ${figureparams}"
    printToLogFile
    python ${PythonHelpersPath}/${figurescript} ${file} blattedFigure${orderNo} ${figureparams}
    done
  fi
    
fi

# -----------------------------------------------------------

printThis="Parsing blatted.psl output file second time ( making the blatted_alsoReferenceAligned output files ) .."
printNewChapterToLogFile

# Quick fix for above steps 9-10 : multi-insertion (and possible multi-deletion) reads are parsed wrong.
# Until the bug is found, the quick fix is generated :
# (the above doesn't hold any more - but the quick fix visualisation is nice to have anyways, so it is made anyways)

quickFix

# If we have one file or more ..

if [ "${printingInBatches}" -eq 0 ]; then

  printThis="${PythonHelpersPath}/figurer.py forFigure_alsoReferenceAligned.txt blattedFigure_alsoReferenceAligned ${basesForFigure}"
  printToLogFile
  python ${PythonHelpersPath}/figurer.py forFigure_alsoReferenceAligned.txt blattedFigure_alsoReferenceAligned ${basesForFigure}

else

  for file in forFigure_alsoReferenceAligned_*.txt
  do
  orderNo=$( echo ${file} | sed 's/^forFigure//' | sed 's/.txt$//' )
  printThis="${PythonHelpersPath}/figurer.py ${file} blattedFigure${orderNo} ${basesForFigure}"
  printToLogFile
  python ${PythonHelpersPath}/figurer.py ${file} blattedFigure${orderNo} ${basesForFigure}
  done
    
fi

# -----------------------------------------------------------

# 14) Clean up output folder ..

printThis="13) Clean up output folder .."
printNewChapterToLogFile

cleanUpFolder

# -----------------------------------------------------------

# 15) Make html file ..

printThis="14) Make html file .."
printNewChapterToLogFile

# multiqc -d 1_inspectFastq 2_flashing 3_indexParsing 4_filteringParsedReads 5_blatting -o 6_comboQCreport

multiqc -d 1_inspectFastq 2_flashing 3_indexParsing -o 6_comboQCreport

# -----------------------------------------------------------
printThis="15) Finished with the sample ! "
printNewChapterToLogFile

printSampleDetails



}