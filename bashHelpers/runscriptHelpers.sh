#!/bin/bash

uniqingAndItsQC(){

cat FLASHextended_SLpairs.txt    | sort | uniq -c | sed 's/^\s*//' | sed 's/\s\s*/\t/' | awk '{ print $0"\t"$1 }' | cut -f 1 --complement > FLASHextended_uniqSLpairs.txt
cat FLASHnotCombined_SLpairs.txt | sort | uniq -c | sed 's/^\s*//' | sed 's/\s\s*/\t/' | awk '{ print $0"\t"$1 }' | cut -f 1 --complement > FLASHnotCombined_uniqSLpairs.txt

# HERE WE NEED :

# Drawing quality control plots (at least making the QC tables) :
# Which kind of distribution we have here - do we see all reads only "too few times" or is everything looking good ?

# cut -f 2 testiA/FLASHextended_uniqSLpairs.txt | sort | uniq -c | sed 's/\s\s*/\t/' | sed 's/^\s*//' | sort -k1,1nr | grep -v '^[123456789]\s'

echo -e "PCRcount\tSind_Lind\tFlashedOrNot\tuniqReads_i_e_alleles" > TEMPheading.txt

cat FLASHnotCombined_uniqSLpairs.txt | sed 's/.*S/S/' | awk '{print substr($1,1,2)}' > TEMP_s_indices.txt
cat FLASHnotCombined_uniqSLpairs.txt | sed 's/L.*/L/' | rev | awk '{print substr($1,1,2)}' | rev > TEMP_l_indices.txt
paste TEMP_s_indices.txt TEMP_l_indices.txt | sed 's/\s/_/' > TEMP_indicenames.txt
rm -f TEMP_s_indices.txt TEMP_l_indices.txt

cut -f 3 FLASHnotCombined_uniqSLpairs.txt | paste TEMP_indicenames.txt - > FLASHnotCombined_forQCtable.txt
rm -f TEMP_indicenames.txt

cat FLASHextended_uniqSLpairs.txt   | sed 's/[ATCGN][ATCGN]*//' | sed 's/__/_/' | sed 's/\s/-/' | sort | uniq -c | sed 's/\s\s*/\t/g' | sed 's/^\s*//' | sed 's/-/\t/' | awk '{print $3"\t"$2"\tF\t"$1}'  > TEMP_flashed.txt 
cat FLASHnotCombined_forQCtable.txt                                             | sed 's/\s/-/' | sort | uniq -c | sed 's/\s\s*/\t/g' | sed 's/^\s*//' | sed 's/-/\t/' | awk '{print $3"\t"$2"\tNF\t"$1}' > TEMP_nonflashed.txt
rm -f FLASHnotCombined_forQCtable.txt 

cat TEMP_flashed.txt TEMP_nonflashed.txt  | sort -k2,2 -k1,1nr | cat TEMPheading.txt - > QCtable_beforePCRcountFilter_FWD_REV_pairs.txt
rm -f TEMP_flashed.txt TEMP_nonflashed.txt

# Fix the names in the end :
rm -f QCtable_beforePCRcountFilter_SL_pairs.txt
cp QCtable_beforePCRcountFilter_FWD_REV_pairs.txt QCtable_beforePCRcountFilter_SL_pairs.txt
parsefile="QCtable_beforePCRcountFilter_FWD_REV_pairs.txt"
indexNamesToFullNames

# WE ALSO NEED :

# To set the cutoff into action : only go to blat, if your uniq score is high enough (have enough pcr depth to be believeable)
# This is USER INPUT FLAG : MINPCRCOUNT.

cat FLASHextended_uniqSLpairs.txt    | awk '{ c='${MINPCRCOUNT}'; if ($2>=c) print $0 }' > QCfilt_FLASHextended_uniqSLpairs.txt
cat FLASHnotCombined_uniqSLpairs.txt | awk '{ c='${MINPCRCOUNT}'; if ($3>=c) print $0 }' > QCfilt_FLASHnotCombined_uniqSLpairs.txt


# IN THE END :

# We need to repeat the quality plot (or QC table) above - to the filtered reads.

cat QCfilt_FLASHnotCombined_uniqSLpairs.txt | sed 's/.*S/S/' | awk '{print substr($1,1,2)}' > TEMP_s_indices.txt
cat QCfilt_FLASHnotCombined_uniqSLpairs.txt | sed 's/L.*/L/' | rev | awk '{print substr($1,1,2)}' | rev > TEMP_l_indices.txt
paste TEMP_s_indices.txt TEMP_l_indices.txt | sed 's/\s/_/' > TEMP_indicenames.txt
rm -f TEMP_s_indices.txt TEMP_l_indices.txt

cut -f 3 QCfilt_FLASHnotCombined_uniqSLpairs.txt | paste TEMP_indicenames.txt - > FLASHnotCombined_forQCtable.txt
rm -f TEMP_indicenames.txt

cat QCfilt_FLASHextended_uniqSLpairs.txt | sed 's/[ATCGN][ATCGN]*//' | sed 's/__/_/' | sed 's/\s/-/' | sort | uniq -c | sed 's/\s\s*/\t/g' | sed 's/^\s*//' | sed 's/-/\t/' | awk '{print $3"\t"$2"\tF\t"$1}'  > TEMP_flashed.txt 
cat FLASHnotCombined_forQCtable.txt                                                  | sed 's/\s/-/' | sort | uniq -c | sed 's/\s\s*/\t/g' | sed 's/^\s*//' | sed 's/-/\t/' | awk '{print $3"\t"$2"\tNF\t"$1}' > TEMP_nonflashed.txt 
rm -f FLASHnotCombined_forQCtable.txt 

cat TEMP_flashed.txt TEMP_nonflashed.txt  | sort -k2,2 -k1,1nr | cat TEMPheading.txt - > QCtable_afterPCRcountFilter_FWD_REV_pairs.txt
rm -f TEMP_flashed.txt TEMP_nonflashed.txt

# Fix the names in the end :
parsefile="QCtable_afterPCRcountFilter_FWD_REV_pairs.txt"
indexNamesToFullNames

rm -f TEMPheading.txt

echo
echo "Filtered the reads - to get rid of sequences seen less than ${MINPCRCOUNT} times."
echo
echo "More details in QC files : "
echo
echo "QCtable_beforePCRcountFilter_FWD_REV_pairs.txt     (before filtering)"
echo "QCtable_afterPCRcountFilter_FWD_REV_pairs.txt       (after filtering)"
echo
echo "Remaining read count (FLASHED) :"
cat QCfilt_FLASHextended_uniqSLpairs.txt | grep -c ""
echo
echo "Remaining read count (nonFLASHED) :"
cat QCfilt_FLASHnotCombined_uniqSLpairs.txt | grep -c ""
echo

# Make the figures ..

printThis="Make the QC figures .."
printToLogFile

# Before only
cut -f 2 QCtable_beforePCRcountFilter_SL_pairs.txt | grep '^S.*L$' | uniq > TEMPindicenames.txt
parsefile="TEMPindicenames.txt"
indexNamesToFullNames
rm -f QCtable_beforePCRcountFilter_SL_pairs.txt

allIndicenames=($( cat TEMPindicenames.txt ))
rm -f TEMPindicenames.txt

rm -rf FIGURES
mkdir FIGURES
cd FIGURES

# Take all reads in - as many times as they count the same pcr count .. Not printing if seen only once or twice (to avoid single hits F or NF).
tail -n +2 ../QCtable_beforePCRcountFilter_FWD_REV_pairs.txt | awk '{if ($1>2) {for(i=0;i<$4;i++) {print $0}}}' > forPCRfigure.txt

for indexpair in "${allIndicenames[@]}"
do
    echo -en "${indexpair}\t" 
    echo -en "${indexpair}\t" >> r.log
    cat forPCRfigure.txt | grep '\s'${indexpair}'\s' > ${indexpair}.txt
    
    if [ -s "${indexpair}.txt" ]; then

    echo ${indexpair} | cat - ${indexpair}.txt | cut -f 1 | cat -n | sed 's/^\s*//' | sed 's/\s\s*/\t/' > temp.txt
    R --vanilla --slave --args ${indexpair} < ${RHelpersPath}/makeOneFigure.R  >> r.log
    mv -f testi.png fig_${indexpair}.png
    
    fi

done
echo

rm -f *.txt

# Make the combined pdf
# http://stackoverflow.com/questions/4778635/merging-png-images-into-one-pdf-file
# convert *.png PCRcounts.pdf
# cluster nodes don't have convert (so converting multiple pngs to pdf is not one command only).

cd ..

}

parseablePreCounts(){

printThis="Peeking into the files : how many reads AT MOST can be resolved (have both INDICES somewhere within the read ).."
printNewChapterToLogFile
echo "The true counts (later on) depend on the --minLen* parameter values !"
echo "Also, these preliminary counts do not check whether the index is 'dirty' - i.e. if it has MORE than the spacer before it."
echo "This preliminary count assumes FULL INDEX SEQUENCE - so some indices may even resolve better than this,"
echo "if library contains a lot of truncated (but still resolve-able) indices !"

mkdir TEMPindexParse
cd TEMPindexParse

spacer8=${SPACER8}
spacer12=${SPACER12}

echo
echo "TOTAL amount of reads in the FLASHED file : "
cat ../FLASHextendedFrags.fastq | awk '{ if (NR%4==2) print $0}' | grep -c ""

echo
echo "MAX amount of reads resolvable from the FLASHED file : "

cat ../FLASHextendedFrags.fastq | awk '{ if (NR%4==2) print $0}' > TESTI.txt
parsefile="TESTI.txt"
maxParseS
mv -f TESTI.txt S.txt

cat ../FLASHextendedFrags.fastq | awk '{ if (NR%4==2) print $0}' > TESTI.txt
parsefile="TESTI.txt"
maxParseL
mv -f TESTI.txt L.txt

paste S.txt L.txt | grep S | grep -c L
rm -f S.txt L.txt

echo
echo "TOTAL amount of reads in the NON-flashed file : "
cat ../FLASHnotCombined_1.fastq | awk '{ if (NR%4==2) print $0}' | grep -c ""

echo
echo "MAX amount of reads resolvable from the NON-flashed file : "

cat ../FLASHnotCombined_1.fastq | awk '{ if (NR%4==2) print $0}' > TESTI.txt
parsefile="TESTI.txt"
maxParseS
mv -f TESTI.txt S1.txt
cat ../FLASHnotCombined_1.fastq | awk '{ if (NR%4==2) print $0}' > TESTI.txt
parsefile="TESTI.txt"
maxParseL
mv -f TESTI.txt L1.txt

cat ../FLASHnotCombined_2.fastq | awk '{ if (NR%4==2) print $0}' > TESTI.txt
parsefile="TESTI.txt"
maxParseS
mv -f TESTI.txt S2.txt
cat ../FLASHnotCombined_2.fastq | awk '{ if (NR%4==2) print $0}' > TESTI.txt
parsefile="TESTI.txt"
maxParseL
mv -f TESTI.txt L2.txt

paste S1.txt L1.txt S2.txt L2.txt | grep S | grep -c L

cd ..
rm -rf TEMPindexParse

}

finalFastQC(){

printThis="Reconstructing fastq file format .."
printToLogFile

# Reconstructing fastq file format ..

# FLASHextended_resolved.txt
# FLASHnotCombined_resolved.txt

# FLASHextended_nonResolved.txt
# FLASHnotCombined_nonResolved_1.txt
# FLASHnotCombined_nonResolved_2.txt

parsefile="FLASHextended_resolved"
resolveFastq

# It should be rather improbable we actually have "resolved" here, as this is so stringent..
if [ -s FLASHnotCombined_resolved.txt ] ; then

cut -f 1 FLASHnotCombined_resolved.txt > FLASHnotCombined_resolved_1.txt
parsefile="FLASHnotCombined_resolved_1"
resolveFastq
rm -f FLASHnotCombined_resolved_1.txt
cut -f 2 FLASHnotCombined_resolved.txt > FLASHnotCombined_resolved_2.txt
parsefile="FLASHnotCombined_resolved_2"
resolveFastq
rm -f FLASHnotCombined_resolved_2.txt

fi

parsefile="FLASHextended_nonResolved"
resolveFastq
parsefile="FLASHnotCombined_nonResolved_1"
resolveFastq
parsefile="FLASHnotCombined_nonResolved_2"
resolveFastq

# FLASHextended_resolved.fastq
# FLASHnotCombined_resolved_1.fastq # Possibly (rare cases as very stringent)
# FLASHnotCombined_resolved_2.fastq # Possibly (rare cases as very stringent)

# FLASHextended_nonResolved.fastq
# FLASHnotCombined_nonResolved_1.fastq
# FLASHnotCombined_nonResolved_2.fastq

printThis="Running fastQC for the PARSED flash-combined files ."
printToLogFile

printThis="( RESOLVED READS )"
printToLogFile

if [ -s FLASHextended_resolved.fastq ];then
${BashHelpersPath}/QC_and_Trimming.sh --fastqc --basenameR1 FLASHextended_resolved --single 1
fi

printThis="( UNRESOLVED READS ..)"
printToLogFile

if [ -s FLASHextended_nonResolved.fastq ];then
${BashHelpersPath}/QC_and_Trimming.sh --fastqc --basenameR1 FLASHextended_nonResolved --single 1 
fi

printThis="Running fastQC for the PARSED non-flash-combined files .."
printToLogFile

if [ -s FLASHnotCombined_resolved_1.fastq ] && [ -s FLASHnotCombined_resolved_2.fastq ]; then

printThis="( RESOLVED READS )"
printToLogFile

${BashHelpersPath}/QC_and_Trimming.sh --fastqc --basenameR1 FLASHnotCombined_resolved_1 --basenameR2 FLASHnotCombined_resolved_2

printThis="( UNRESOLVED READS ..)"
printToLogFile

fi

if [ -s FLASHnotCombined_nonResolved_1.fastq ];then
${BashHelpersPath}/QC_and_Trimming.sh --fastqc --basenameR1 FLASHnotCombined_nonResolved_1 --basenameR2 FLASHnotCombined_nonResolved_2
fi

}

countFinalUnresolved(){

echo
echo "Counts of UNRESOLVED reads, where we can find the EFFECTIVE PRIMERS in them (both end primers)  :"
echo
echo "Flashed reads : PrimerFound / allUnresolved"

cp FLASHextended_nonResolved.txt TESTI.txt
parsefile="TESTI.txt"
maxPrimParseS
mv -f TESTI.txt S.txt

cp FLASHextended_nonResolved.txt TESTI.txt
parsefile="TESTI.txt"
maxPrimParseL
mv -f TESTI.txt L.txt

tempcount=$( paste S.txt L.txt | grep S | grep -c L )
rm -f S.txt L.txt
echo "${tempcount} / ${unresolvedFlashedCount}"

# echo
# echo "Unflashed reads - R1, R2 : PrimerFound / allUnresolved"
# 
# cp FLASHnotCombined_nonResolved_1.txt TESTI.txt
# parsefile="TESTI.txt"
# maxPrimParseS
# mv -f TESTI.txt S1.txt
# cp FLASHnotCombined_nonResolved_2.txt TESTI.txt
# parsefile="TESTI.txt"
# maxPrimParseS
# mv -f TESTI.txt S2.txt
# 
# cp FLASHnotCombined_nonResolved_1.txt TESTI.txt
# parsefile="TESTI.txt"
# maxPrimParseL
# mv -f TESTI.txt L1.txt
# cp FLASHnotCombined_nonResolved_2.txt TESTI.txt
# parsefile="TESTI.txt"
# maxPrimParseL
# mv -f TESTI.txt L2.txt
# 
# tempcount=$( paste S1.txt L1.txt S2.txt L2.txt | grep S | grep -c L )
# rm -f S1.txt L1.txt S2.txt L2.txt
# echo "${tempcount} / ${unresolvedNonFlashedCount}"



echo
echo "Counts of UNRESOLVED reads, which still have the INTACT INDICES (both L and S side) in them :"
echo "(these are the reads which were filtered out as the PRIMER part was too short)"
echo
echo "Flashed reads : unparsedIndexFound / allUnresolved"

cp FLASHextended_nonResolved.txt TESTI.txt
parsefile="TESTI.txt"
maxParseS
mv -f TESTI.txt S.txt

cp FLASHextended_nonResolved.txt TESTI.txt
parsefile="TESTI.txt"
maxParseL
mv -f TESTI.txt L.txt

tempcount=$( paste S.txt L.txt | grep S | grep -c L )
rm -f S.txt L.txt
echo "${tempcount} / ${unresolvedFlashedCount}"

echo
echo "Unflashed reads - R1, R2 : unparsedIndexFound / allUnresolved"

cp FLASHnotCombined_nonResolved_1.txt TESTI.txt
parsefile="TESTI.txt"
maxParseS
mv -f TESTI.txt S1.txt
cp FLASHnotCombined_nonResolved_2.txt TESTI.txt
parsefile="TESTI.txt"
maxParseS
mv -f TESTI.txt S2.txt

cp FLASHnotCombined_nonResolved_1.txt TESTI.txt
parsefile="TESTI.txt"
maxParseL
mv -f TESTI.txt L1.txt
cp FLASHnotCombined_nonResolved_2.txt TESTI.txt
parsefile="TESTI.txt"
maxParseL
mv -f TESTI.txt L2.txt

tempcount=$( paste S1.txt L1.txt S2.txt L2.txt | grep S | grep -c L )
rm -f S1.txt L1.txt S2.txt L2.txt
echo "${tempcount} / ${unresolvedNonFlashedCount}"

echo
echo "Counts of UNRESOLVED reads, which still have the EFFECTIVE PRIMER and INTACT INDICES (both L and S side) in them :"
echo "(these are the 'potentially unresolved reads' which reveal potential improvement needs in the code)"
echo
echo "Flashed reads : PrimerAndIndexFound / allUnresolved"

cp FLASHextended_nonResolved.txt TESTI.txt
parsefile="TESTI.txt"
maxParseBothS
mv -f TESTI.txt S.txt

cp FLASHextended_nonResolved.txt TESTI.txt
parsefile="TESTI.txt"
maxParseBothL
mv -f TESTI.txt L.txt

tempcount=$( paste S.txt L.txt | grep S | grep -c L )
rm -f S.txt L.txt
echo "${tempcount} / ${unresolvedFlashedCount}"

echo
echo "Unflashed reads - R1, R2 : PrimerAndIndexFound / allUnresolved"

cp FLASHnotCombined_nonResolved_1.txt TESTI.txt
parsefile="TESTI.txt"
maxParseBothS
mv -f TESTI.txt S1.txt
cp FLASHnotCombined_nonResolved_2.txt TESTI.txt
parsefile="TESTI.txt"
maxParseBothS
mv -f TESTI.txt S2.txt

cp FLASHnotCombined_nonResolved_1.txt TESTI.txt
parsefile="TESTI.txt"
maxParseBothL
mv -f TESTI.txt L1.txt
cp FLASHnotCombined_nonResolved_2.txt TESTI.txt
parsefile="TESTI.txt"
maxParseBothL
mv -f TESTI.txt L2.txt

tempcount=$( paste S1.txt L1.txt S2.txt L2.txt | grep S | grep -c L )
rm -f S1.txt L1.txt S2.txt L2.txt
echo "${tempcount} / ${unresolvedNonFlashedCount}"

}


printSampleDetails(){

echo > templog
echo "---------------------------------------------------" >> templog
echo "Step-to-step analysis in folders :" >> templog
echo "---------------------------------------------------" >> templog
echo >> templog
pwd >> templog
echo >> templog
ls | grep ^[1234567890] >> templog
echo >> templog
echo "---------------------------------------------------" >> templog
echo "And quality control reports in folders  (4) (6) (7) :" >> templog
echo "---------------------------------------------------" >> templog
echo >> templog
echo "FastQC reports :" >> templog
echo firefox $( pwd )/6_comboQCreport/multiqc_report.html >> templog

if [ -s $( pwd )/7_figures/unblattedInspection.pdf ];then
echo >> templog
echo "Unblatted reads :" >> templog
echo $( pwd )/7_figures/unblattedInspection.pdf >> templog
fi
echo >> templog
echo "And the PCR counts in table format :" >> templog
ls -1 4_filteringParsedReads/QCtable_* >> templog
echo >> templog
echo "---------------------------------------------------" >> templog
echo "Make your combined PCR count pdf with this command :" >> templog
echo "---------------------------------------------------" >> templog
# echo >> templog
# echo "convert $( pwd )/4_filteringParsedReads/FIGURES/*.png PCRcounts_${temphere}.pdf"  >> templog
# echo >> templog
# echo "Or simply : " >> templog
echo >> templog
temphere=$( echo $( pwd ) | sed 's/.*\///' )
echo "convert ${temphere}/4_filteringParsedReads/FIGURES/*.png PCRcounts_${temphere}.pdf"  >> templog
echo >> templog
echo "---------------------------------------------------" >> templog
echo "You find your results in folder '7_figures' :" >> templog
echo "---------------------------------------------------" >> templog
echo >> templog
echo "PDF format :" >> templog
echo >> templog
echo "NOTE !! - this is a big pdf file : if it looks empty in Adobe reader, look at it via a web browser (open in Google Chrome etc)" >> templog
echo "Max 50 of these files were printed (corresponding to amount of sequences approximately 20 per each well)" >> templog
echo >> templog
echo "NOTE !! - the FIX files are quick-fix for the visualisation : NOT NEEDED any  more, but were used to spot tool parse errors in multiple-insertions" >> templog
echo >> templog
for file in 7_figures/blattedFigure*.pdf
do
echo $( pwd )/${file} >> templog
done
echo >> templog
echo "PNG format (image) :" >> templog
for file in 7_figures/blattedFigure*.png
do
echo $( pwd )/${file} >> templog
done

if [ "${figureGenerated}" -eq 0 ]; then
echo "" >> templog
echo "WARNING !! - The main figures were not generated, as there were too many sequences left in the output files (approximately 20 per each well). " >> templog
echo 'The text files called forFigure*.txt are browseable in folder 5_blatting ' >> templog
fi

echo >> templog

cat templog
cat templog >> ${SUMMARYFILE}
rm -f templog

}

printKeyToReadIndices(){
    
    echo "Key of indices :" > indiceKey.txt
    echo "-----------------------------------"   >> indiceKey.txt
    echo "S indices (FORWARD) :" >> indiceKey.txt
    echo -e "Sid\tplateCoord indexName\tsequence" >> indiceKey.txt
    for k in $( seq 0 $((${#indexNames8[@]} - 1)) ); do 
        echo -e "S${k}\t${indexShortNames8[$k]} ${indexNames8[$k]}\t${indexSeqs8[$k]}"  >> indiceKey.txt
    done
    echo "----------------------------------"  >> indiceKey.txt
    echo "L indices (REVERSE) :"  >> indiceKey.txt
    echo -e "Lid\tplateCoord indexName\tsequence"  >> indiceKey.txt
    for k in $( seq 0 $((${#indexNames12[@]} - 1)) ); do  
        echo -e "L${k}\t${indexShortNames12[$k]} ${indexNames12[$k]}\t${indexSeqs12[$k]}"  >> indiceKey.txt
    done
    echo "----------------------------------"  >> indiceKey.txt
    
}

printFigureKeyToReadIndices(){
    
    echo "Key of indices :" > indiceKey.txt
    echo "-----------------------------------"   >> indiceKey.txt
    echo "FORWARD indices :" >> indiceKey.txt
    echo "plateCoord   indexName  sequence" >> indiceKey.txt
    for k in $( seq 0 $((${#indexNames8[@]} - 1)) ); do 
        echo "${indexShortNames8[$k]}      ${indexNames8[$k]}      ${indexSeqs8[$k]}"  >> indiceKey.txt
    done
    echo "----------------------------------"  >> indiceKey.txt
    echo "REVERSE indices :"  >> indiceKey.txt
    echo "plateCoord   indexName  sequence"  >> indiceKey.txt
    for k in $( seq 0 $((${#indexNames12[@]} - 1)) ); do  
        echo "${indexShortNames12[$k]}      ${indexNames12[$k]}  ${indexSeqs12[$k]}"  >> indiceKey.txt
    done
    echo "----------------------------------"  >> indiceKey.txt
    
}

