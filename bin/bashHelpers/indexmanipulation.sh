#!/bin/bash

##########################################################################
# Copyright 2018, Jelena Telenius (jelena.telenius@ndcls.ox.ac.uk)       #
#                                                                        #
# This file is part of plateScreen96 .                                   #
#                                                                        #
# plateScreen96 is free software: you can redistribute it and/or modify  #
# it under the terms of the MIT license.
#
#
#                                                                        #
# plateScreen96 is distributed in the hope that it will be useful,       #
# but WITHOUT ANY WARRANTY; without even the implied warranty of         #
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the          #
# MIT license for more details.
#                                                                        #
# You should have received a copy of the MIT license
# along with plateScreen96.  
##########################################################################

resolveFastq(){

# Resolve fastq format - after index parsing ..

# parsefile="FLASHnotCombined_nonResolved_1"

printThis="Generating fastq file ${parsefile}.fastq .."
printToLogFile

cat ${parsefile}.txt | sed 's/^.._//' | sed 's/_..$//' | sed 's/_LAUQ$//' | sed 's/^QUAL_//' | awk '{if (NR%2==1) print "@" $0 "\n" $0 "\n+" ; else print $0}' > ${parsefile}.fastq


}

indexNamesToFullNames(){

# After-blat parse to full index names.

# parsefile="blatted_noIns_parsed.txt"

# The indexShortName lists are not allowed to contain capital letters 'S' or 'L'


sed -i 's/e/10/' ${parsefile}
sed -i 's/f/11/' ${parsefile}

for k in $( seq 0 $((${#indexShortNames12[@]} - 1)) ); do
    
    sed -i 's/L'$k'_/'${indexShortNames12[$k]}'_/' ${parsefile}
    sed -i 's/_'$k'L/_'${indexShortNames12[$k]}'/' ${parsefile}

done

for k in $( seq 0 $((${#indexShortNames8[@]} - 1)) ); do
    
    sed -i 's/S'$k'_/'${indexShortNames8[$k]}'_/' ${parsefile}
    sed -i 's/_'$k'S/_'${indexShortNames8[$k]}'/' ${parsefile}

done

}

countAndSplitParsedFlashed(){

echo >> ${SUMMARYFILE}
echo "Counting the (previously unresolved) FLASH-combined fragments, when SPACERS lenghts are : ${spacerLenghtInfo} :" >> ${SUMMARYFILE}
echo >> ${SUMMARYFILE}

echo
echo "Counting the (previously unresolved) FLASH-combined fragments, when SPACERS lenghts are : ${spacerLenghtInfo} :"
echo
echo "Total reads (in the whole run) :"
echo ${totalFlashedCount}

echo "Total reads (entered this round as 'unresolved so far') :"
cat FLASHextendedFrags_seqAndQual.txt | grep -v '^QUAL_' | grep -c ""

# The above resolves most. So, taking out the non-resolved separately, and running the following loop only for them..

cat FLASHextendedFrags_seqAndQual.txt  | awk '{ if (NR%2==0) print pre "\t" $0 ; else pre=$0 }' | grep    '^[SL].*[SL]\s' | sed 's/\sQUAL/\nQUAL/' > FLASHextended_resolved.txt
cat FLASHextendedFrags_seqAndQual.txt  | awk '{ if (NR%2==0) print pre "\t" $0 ; else pre=$0 }' | grep -v '^[SL].*[SL]\s' | sed 's/\sQUAL/\nQUAL/' > FLASHextended_nonResolved.txt

rm -f FLASHextendedFrags_seqAndQual.txt

thisRoundResolvedCount=0
thisRoundResolvedCount=$(($( cat FLASHextended_resolved.txt | grep -v '^QUAL_' | grep -c "" )))
totalFlashedResolvedCount=$((${totalFlashedResolvedCount}+${thisRoundResolvedCount}))

thisRoundNonResolvedCount=$(($( cat FLASHextended_nonResolved.txt | grep -v '^QUAL_' | grep -c "" )))

echo "Resolved ( this round ) : "
echo ${thisRoundResolvedCount}

echo "Resolved ( in total - so far ) : "
echo ${totalFlashedResolvedCount}

echo "Not yet resolved : "
echo ${thisRoundNonResolvedCount}


echo >> ${SUMMARYFILE}
echo "Resolved / all    - FLASHED so far " >> ${SUMMARYFILE}
echo "${totalFlashedResolvedCount} / ${totalFlashedCount}" >> ${SUMMARYFILE}

echo 
echo "Resolved / all    - FLASHED so far "
echo "${totalFlashedResolvedCount} / ${totalFlashedCount}"
echo

echo "Non-resolved / all    - FLASHED so far "
echo "${thisRoundNonResolvedCount} / ${totalFlashedCount}"

echo
echo "(Non-resolved + Resolved) / all    - CHECKSUM "
echo $((${thisRoundNonResolvedCount}+${totalFlashedResolvedCount})) "/ ${totalFlashedCount}"

echo "(Non-resolved + Resolved) / all    - CHECKSUM " >> ${SUMMARYFILE}
echo $((${thisRoundNonResolvedCount}+${totalFlashedResolvedCount})) "/ ${totalFlashedCount}" >> ${SUMMARYFILE}

  
}

countAndSplitNonflashedParsed(){

echo >> ${SUMMARYFILE}
echo "Counting the (previously unresolved) nonFLASH-combined fragments, when SPACERS lenghts are : ${spacerLenghtInfo} :" >> ${SUMMARYFILE}
echo >> ${SUMMARYFILE}
 
echo
echo "Counting the (previously unresolved) nonFLASH-combined fragments, when SPACERS lenghts are : ${spacerLenghtInfo} :"
echo

echo "Total reads (in the whole run) - read 1 and 2 the same amount :"
echo ${totalNonFlashedCount}

echo "Total (entered this round) - read 1 and 2 the same amount :"
cat FLASHnotCombined_1_seqAndQual.txt | grep -v '^QUAL_' | grep -c ""

# The above resolves most. So, taking out the non-resolved separately, and running the following loop only for them..

# Take out the oneliner-version of it (and add tab to beginning, to separate all with \s not ^ or $ ), to parse..
paste FLASHnotCombined_1_seqAndQual.txt FLASHnotCombined_2_seqAndQual.txt | awk '{ if (NR%2==0) print pre "\tLINESTART" $0 ; else pre=$0 }' > TEMP_forParse.txt

# Remove originals
rm -f FLASHnotCombined_1_seqAndQual.txt FLASHnotCombined_2_seqAndQual.txt

# Being very conservative - counting as "resolved" only if on BOTH ends we have S or L

cat TEMP_forParse.txt | grep    '^[SL].*[SL]\s[SL].*[SL]\sLINESTART' | sed 's/\sLINESTART/\n/' > FLASHnotCombined_resolved.txt
cat TEMP_forParse.txt | grep -v '^[SL].*[SL]\s[SL].*[SL]\sLINESTART' | sed 's/\sLINESTART/\n/' > TEMP_notresolved.txt

# Remove temp file
rm -f TEMP_forParse.txt

# To separate R1 and R2 to the nonresolved files
cut -f 1 TEMP_notresolved.txt > FLASHnotCombined_nonResolved_1.txt

cut -f 2 TEMP_notresolved.txt > FLASHnotCombined_nonResolved_2.txt

# Remove temp file
rm -f TEMP_notresolved.txt

# Counts

thisRoundResolvedCount=0
thisRoundResolvedCount=$(($( cat FLASHnotCombined_resolved.txt | grep -v '^QUAL_' | grep -c "" )))
totalNonFlashedResolvedCount=$((${totalNonFlashedResolvedCount}+${thisRoundResolvedCount}))

 thisRoundNonResolvedCount=$(($( cat FLASHnotCombined_nonResolved_1.txt | grep -v '^QUAL_' | grep -c "" )))
thisRoundNonResolvedCount2=$(($( cat FLASHnotCombined_nonResolved_2.txt | grep -v '^QUAL_' | grep -c "" )))

echo "Resolved ( this round ) : "
echo ${thisRoundResolvedCount}

echo "Resolved ( in total - so far ) - R1, R2: "
echo ${totalNonFlashedResolvedCount}
echo ${totalNonFlashedResolvedCount2}

echo "Not yet resolved : "
echo ${thisRoundNonResolvedCount}

echo
echo "Resolved / all    - nonFLASHED so far "
echo "${totalNonFlashedResolvedCount} / ${totalNonFlashedCount}"
echo "Resolved / all    - nonFLASHED so far " >> ${SUMMARYFILE}
echo "${totalNonFlashedResolvedCount} / ${totalNonFlashedCount}" >> ${SUMMARYFILE}
echo
echo "Non-resolved / all    - nonFLASHED so far "
echo "${thisRoundNonResolvedCount} /${totalNonFlashedCount}"
echo
echo "(Non-resolved + Resolved) / all    - CHECKSUM "
echo $((${thisRoundNonResolvedCount}+${totalNonFlashedResolvedCount})) "/ ${totalNonFlashedCount}"

echo "(Non-resolved + Resolved) / all    - CHECKSUM " >> ${SUMMARYFILE}
echo $((${thisRoundNonResolvedCount}+${totalNonFlashedResolvedCount})) "/ ${totalNonFlashedCount}" >> ${SUMMARYFILE}
 
}


maxParseBothS(){

# How much at most can be resolved. - Pri and ind

# i8 indices (S - index of short side)

    effPriRev8=$( echo ${effPrimer8} | rev | tr A a | tr T t | tr C c | tr G g | tr a T | tr t A | tr c G | tr g C )

for k in $( seq 0 $((${#indexNames8[@]} - 1)) ); do

    thisRoundParse="${indexSeqs8[k]}${effPrimer8}"
    thisRoundRvrse="${effPriRev8}${indRevSqs8[k]}"
    
    
    rm -f TEMP.txt
    cat ${parsefile} | sed 's/'${thisRoundParse}'/S_/' > TEMP.txt
    mv -f TEMP.txt ${parsefile}

#    if [ "${flashed}" -eq 1 ]; then
    rm -f TEMP.txt
    cat ${parsefile} | sed 's/'${thisRoundRvrse}'/_S/' > TEMP.txt
    mv -f TEMP.txt ${parsefile}    
#    fi

done
    
}

maxParseBothL(){
    
# How much at most can be resolved. - Pri and ind
    
# i12 indices ( L - index of long side)

effPriRev12=$( echo ${effPrimer12} | rev | tr A a | tr T t | tr C c | tr G g | tr a T | tr t A | tr c G | tr g C )

for k in $( seq 0 $((${#indexNames12[@]} - 1)) ); do

    thisRoundParse="${indexSeqs12[k]}${effPrimer12}"
    thisRoundRvrse="${effPriRev12}${indRevSqs12[k]}"
    
    rm -f TEMP.txt
    cat ${parsefile} | sed 's/'${thisRoundParse}'/L_/' > TEMP.txt
    mv -f TEMP.txt ${parsefile}
    
#    if [ "${flashed}" -eq 1 ]; then
    rm -f TEMP.txt
    cat ${parsefile} | sed 's/'${thisRoundRvrse}'/_L/' > TEMP.txt
    mv -f TEMP.txt ${parsefile}
#    fi
    
done    

}

maxParseS(){

# How much at most can be resolved. - having the index.

# parsefile="FLASHextendedFrags_seqAndQual.txt"
# parsefile="FLASHnotCombined_1_seqAndQual.txt"
# parsefile="FLASHnotCombined_2_seqAndQual.txt"

# i8 indices (S - index of short side)

# i8 indices (S - index of short side)

for k in $( seq 0 $((${#indexNames8[@]} - 1)) ); do

    thisRoundParse="${indexSeqs8[k]}"
    thisRoundRvrse="${indRevSqs8[k]}"
    
    
    rm -f TEMP.txt
    cat ${parsefile} | sed 's/'${thisRoundParse}'/S'$k'_/' > TEMP.txt
    mv -f TEMP.txt ${parsefile}

#    if [ "${flashed}" -eq 1 ]; then
    rm -f TEMP.txt
    cat ${parsefile} | sed 's/'${thisRoundRvrse}'/_'$k'S/' > TEMP.txt
    mv -f TEMP.txt ${parsefile}    
#    fi

done
    
}
maxParseL(){
    
# How much at most can be resolved. - having the index.
    
# i12 indices ( L - index of long side)

for k in $( seq 0 $((${#indexNames12[@]} - 1)) ); do

    thisRoundParse="${indexSeqs12[k]}"
    thisRoundRvrse="${indRevSqs12[k]}"
    
    rm -f TEMP.txt
    cat ${parsefile} | sed 's/'${thisRoundParse}'/L'$k'_/' > TEMP.txt
    mv -f TEMP.txt ${parsefile}
    
#    if [ "${flashed}" -eq 1 ]; then
    rm -f TEMP.txt
    cat ${parsefile} | sed 's/'${thisRoundRvrse}'/_'$k'L/' > TEMP.txt
    mv -f TEMP.txt ${parsefile}
#    fi
    
done    

}

maxPrimParseS(){
    
    # How many have the primer still ?
    
    effPriRev8=$( echo ${effPrimer8} | rev | tr A a | tr T t | tr C c | tr G g | tr a T | tr t A | tr c G | tr g C )

    thisRoundParse="${effPrimer8}"
    thisRoundRvrse="${effPriRev8}"
    
    
    rm -f TEMP.txt
    cat ${parsefile} | sed 's/'${thisRoundParse}'/S_/' > TEMP.txt
    mv -f TEMP.txt ${parsefile}

    rm -f TEMP.txt
    cat ${parsefile} | sed 's/'${thisRoundRvrse}'/_S/' > TEMP.txt
    mv -f TEMP.txt ${parsefile}    
    
}

maxPrimParseL(){
    
    # How many have the primer still ?
 
 # i12 indices ( L - index of long side)
 
    effPriRev12=$( echo ${effPrimer12} | rev | tr A a | tr T t | tr C c | tr G g | tr a T | tr t A | tr c G | tr g C )

    thisRoundParse="${effPrimer12}"
    thisRoundRvrse="${effPriRev12}"
    
    rm -f TEMP.txt
    cat ${parsefile} | sed 's/'${thisRoundParse}'/L_/' > TEMP.txt
    mv -f TEMP.txt ${parsefile}
    
    rm -f TEMP.txt
    cat ${parsefile} | sed 's/'${thisRoundRvrse}'/_L/' > TEMP.txt
    mv -f TEMP.txt ${parsefile}
    

}

firstRoundParse8(){

# Flashed and nonflashed actually go through this exactly the same.
# flashed=1
# flashed=0

# parsefile="FLASHextendedFrags_seqAndQual.txt"
# parsefile="FLASHnotCombined_1_seqAndQual.txt"
# parsefile="FLASHnotCombined_2_seqAndQual.txt"

# i8 indices (S - index of short side)

echo
# echo "flashed ${flashed}"
echo "FWD indices  - parsefile ${parsefile}"
echo

for k in $( seq 0 $((${#indexNames8[@]} - 1)) ); do

    thisRoundParse="${spacer8}${indexSeqs8[k]}${effPrimer8}"
    thisRoundRvrse="${effPriRev8}${indRevSqs8[k]}${spacRV8}"
    
    echo -e "${indexShortNames8[$k]} ${indexNames8[$k]}\tFORWARD = ${thisRoundParse}\tREVERSE = ${thisRoundRvrse} "

    sed -i 's/^'${thisRoundParse}'/S'$k'_'${effPrimer8}'/' ${parsefile}
    sed -i 's/'${thisRoundRvrse}'$/'${effPriRev8}'_'$k'S/' ${parsefile}

    # If nonflashed - also allowing non-exact 3' end. 
    if [ "${flashed}" -eq 0 ]; then
      sed -i 's/'${thisRoundRvrse}'.*/'${effPriRev8}'_'$k'S/' ${parsefile}
    fi    
    
done

}

firstRoundParse12(){

# i12 indices ( L - index of long side)

echo
# echo "flashed ${flashed}"
echo "REV indices - parsefile ${parsefile}"
echo

for k in $( seq 0 $((${#indexNames12[@]} - 1)) ); do

    thisRoundParse="${spacer12}${indexSeqs12[k]}${effPrimer12}"
    thisRoundRvrse="${effPriRev12}${indRevSqs12[k]}${spacRV12}"
    
    echo -e "${indexShortNames12[$k]} ${indexNames12[$k]}\tFORWARD = ${thisRoundParse}\tREVERSE = ${thisRoundRvrse} "

    sed -i 's/^'${thisRoundParse}'/L'$k'_'${effPrimer12}'/' ${parsefile}
    sed -i 's/'${thisRoundRvrse}'$/'${effPriRev12}'_'$k'L/' ${parsefile}
    
    # If nonflashed - also allowing non-exact 3' end. 
    if [ "${flashed}" -eq 0 ]; then
      sed -i 's/'${thisRoundRvrse}'.*/'${effPriRev12}'_'$k'L/' ${parsefile}
    fi
    
done    

# Fixing the index12 numbers 10,11 to be e,f (those are "reasonably front" in alphabet, and not amongst [atcg] )

rm -f TEMP.txt
cat ${parsefile} | sed 's/^L10_/Le_/' | sed 's/_10L$/_eL/' > TEMP.txt
mv -f TEMP.txt ${parsefile}

rm -f TEMP.txt
cat ${parsefile} | sed 's/^L11_/Lf_/' | sed 's/_11L$/_fL/' > TEMP.txt
mv -f TEMP.txt ${parsefile}

}

shortestResolvingIndex(){
    
# First, solving how many index bases we have to solve to know this is the index.
# Finding the common nominator.
# Using the index lenght as the start value.
# Then checking, how short it can go, until 2 of the sequences become the same.
# 
# Like this :
# 
# [telenius@deva playingWithIndices_130217]$ cat testi2.txt | rev | sort | awk '{print substr($1,1,6)}' | uniq -c 
#       1 5AGTCT
#       1 5ATTCT
#       1 5CAGTC
#       1 7CGCGT
#       1 7GATAG
#       1 7GCTCA
# [telenius@deva playingWithIndices_130217]$ cat testi2.txt | rev | sort | awk '{print substr($1,1,5)}' | uniq -c 
#       1 5AGTC
#       1 5ATTC
#       1 5CAGT
#       2 7CGCG
#       1 7GATA
#       1 7GCTC
# [telenius@deva playingWithIndices_130217]$ 
# 
# In this case the smallest lenght of index would be 5 ( i.e. 6-1) .
# We will save these sequences with the IDENTIFIER of the index (print these in the awks below, instead of the true sequences)    

# #################################

# This is what we can read in (these have just been filled in the main script : )

# indexNames12=()
# indexSeqs12=()
    
# indexNames8=()
# indexSeqs8=()

indexSeqTempFileMaker
# The above takes the seqs into temp files (it is in parameterFileReaders.sh)
# TEMP_IndexSeq12.txt
# TEMP_IndexSeq8.txt

# Start with counts of full lenght (+1 to start the loop properly).
last8uniq=$((${#indexSeqs8[1]}+1))
last12uniq=$((${#indexSeqs12[1]}+1))

# If all are uniq, we see 8 different.
seenAmount8=8
while [ "${seenAmount8}" -eq 8 ]
do
last8uniq=$((${last8uniq}-1))
seenAmount8=$(($( cat TEMP_IndexSeq8.txt | rev | sort | awk '{print substr($1,1,'${last8uniq}')}' | uniq | grep -c "" )))
done

# If all are uniq, we see 12 different.
seenAmount12=12
while [ "${seenAmount12}" -eq 12 ]
do
last12uniq=$((${last12uniq}-1))
seenAmount12=$(($( cat TEMP_IndexSeq12.txt | rev | sort | awk '{print substr($1,1,'${last12uniq}')}' | uniq | grep -c "" )))
done

rm -f TEMP_IndexSeq12.txt TEMP_IndexSeq8.txt
unset seenAmount8
unset seenAmount12

# Setting the minIndexSeqs (which we don't actually need in the run. But in case we some point in future need them ..)
minIndexSeqs12=()
minIndexSeqs8=()
minIndexSeqSetter

echo
echo "FWD indices can still be resolved, if ${last8uniq} PRIMER-end bases of index are resolved."
echo
echo "The minimal sequences become :"
echo

echo >> ${SUMMARYFILE}
echo "FWD indices can still be resolved, if ${last8uniq} PRIMER-end bases of index are resolved." >> ${SUMMARYFILE}
echo >> ${SUMMARYFILE}
echo "The minimal sequences become :" >> ${SUMMARYFILE}
echo >> ${SUMMARYFILE}

    for k in $( seq 0 $((${#minIndexSeqs8[@]} - 1)) ); do
        echo "${indexShortNames8[$k]} ${indexNames8[$k]}  ${minIndexSeqs8[$k]}"
        echo "${indexShortNames8[$k]} ${indexNames8[$k]}  ${minIndexSeqs8[$k]}" >> ${SUMMARYFILE}
    done
    
echo
echo "REV indices can still be resolved, if ${last12uniq} PRIMER-end bases of index are resolved."
echo
echo "The minimal sequences become :"
echo

echo >> ${SUMMARYFILE}
echo "REV indices can still be resolved, if ${last12uniq} PRIMER-end bases of index are resolved." >> ${SUMMARYFILE}
echo >> ${SUMMARYFILE}
echo "The minimal sequences become :" >> ${SUMMARYFILE}
echo >> ${SUMMARYFILE}

    for k in $( seq 0 $((${#minIndexSeqs12[@]} - 1)) ); do
        echo "${indexShortNames12[$k]} ${indexNames12[$k]}  ${minIndexSeqs12[$k]}"
        echo "${indexShortNames12[$k]} ${indexNames12[$k]}  ${minIndexSeqs12[$k]}" >> ${SUMMARYFILE}
    done

echo


}

setEffectivePrimer(){
    
# Sanity check of MINLEN8,MINLEN12 : if it is longer than either of the PRIMER lenghts, setting to be the shortest primer lenght.

if [ "${MINLEN8}" -lt 0 ]; then
    if [ $((${MINLEN8}*(-1))) -gt "${#PRIMER8}" ] ; then
            MINLEN8=${#PRIMER8}
    fi
fi

if [ "${MINLEN12}" -lt 0 ]; then
    if [ $((${MINLEN12}*(-1))) -gt "${#PRIMER12}" ] ; then
            MINLEN12=${#PRIMER12}
    fi
fi

echo
echo "Minimum allowed value of MINLENfwd/MINLENrev parameter is (-PrimerLenght)"
echo "After checking that the value is not smaller than that, the MINLEN8/12 parameters are now set to values :"
echo "MINLENfwd ${MINLEN8}"
echo "MINLENrev ${MINLEN12}"

echo
echo "The effective primer sequences (used in index parsing) now become :"    
echo

 effPrimer8=$( echo ${PRIMER8}  | awk '{print substr($1,1,'$((${#PRIMER8}+${MINLEN8}))')}'  )
effPrimer12=$( echo ${PRIMER12} | awk '{print substr($1,1,'$((${#PRIMER12}+${MINLEN12}))')}' )

echo "effPrimerFWD  ${effPrimer8}"
echo "effPrimerREV ${effPrimer12}"

echo
echo "(compare to the full primers : )"    
echo "fullPrimerFWD  ${PRIMER8}"
echo "fullPrimerREV ${PRIMER12}"
echo

echo  >> ${SUMMARYFILE}
echo "Set effective primer sequences :" >> ${SUMMARYFILE}
echo >> ${SUMMARYFILE}

echo "effPrimerFWD  ${effPrimer8}" >> ${SUMMARYFILE}
echo "effPrimerREV ${effPrimer12}" >> ${SUMMARYFILE}

echo >> ${SUMMARYFILE}
echo "(compare to the full primers : )"   >> ${SUMMARYFILE}  
echo "fullPrimerFWD  ${PRIMER8}" >> ${SUMMARYFILE}
echo "fullPrimerREV ${PRIMER12}" >> ${SUMMARYFILE}
echo >> ${SUMMARYFILE}

}

parseIndices(){

# The one below 4 times :
# 8 index forward
# 8 index reverse
# 12 index forward
# 12 index reverse

# Using the EFFECTIVE primer here.

# FLASHextendedFrags.fastq
# FLASHnotCombined_1.fastq
# FLASHnotCombined_2.fastq

# #######################################

# Making the reduced size files, and shielding QUAL scores from parsing ..

cat FLASHextendedFrags.fastq | awk '{ if (NR%2==0) print $0}' | awk '{ if (NR%2==0) print "QUAL_"$0"_LAUQ" ; else print $0}' > FLASHextendedFrags_seqAndQual.txt
cat FLASHnotCombined_1.fastq | awk '{ if (NR%2==0) print $0}' | awk '{ if (NR%2==0) print "QUAL_"$0"_LAUQ" ; else print $0}' > FLASHnotCombined_1_seqAndQual.txt
cat FLASHnotCombined_2.fastq | awk '{ if (NR%2==0) print $0}' | awk '{ if (NR%2==0) print "QUAL_"$0"_LAUQ" ; else print $0}' > FLASHnotCombined_2_seqAndQual.txt

# Total counts ..

totalFlashedCount=$(($( cat FLASHextendedFrags_seqAndQual.txt | grep -v '^QUAL' | grep -c "" )))
totalNonFlashedCount=$(($( cat FLASHnotCombined_1_seqAndQual.txt | grep -v '^QUAL' | grep -c "" )))

totalFlashedResolvedCount=0
totalNonFlashedResolvedCount=0

# #######################################

printThis="Parsing indices for the FLASH-combined file .."
printNewChapterToLogFile

# Flashed needs both forward and reverse..

effPriRev8=$( echo ${effPrimer8} | rev | tr A a | tr T t | tr C c | tr G g | tr a T | tr t A | tr c G | tr g C )
effPriRev12=$( echo ${effPrimer12} | rev | tr A a | tr T t | tr C c | tr G g | tr a T | tr t A | tr c G | tr g C )

spacRV8=$( echo ${spacer8} | rev | tr A a | tr T t | tr C c | tr G g | tr a T | tr t A | tr c G | tr g C )
spacRV12=$( echo ${spacer12} | rev | tr A a | tr T t | tr C c | tr G g | tr a T | tr t A | tr c G | tr g C )

parsefile="FLASHextendedFrags_seqAndQual.txt"
flashed=1
firstRoundParse8
firstRoundParse12
# Updates the above file - to parse the above indices in.
# If the full SPACERindexPRIMER is seen either in front^ or end$ of the read
# Here primer is the effective primer - so can be shorter than the actual primer, if so requested by the user.

# ----------------------------------------

# Count them. split to resolved and non-resolved.

spacerLenghtInfo="FULL lenght"
countAndSplitParsedFlashed
# Basically extension around these commands :
# cat FLASHextendedFrags_seqAndQual.txt | grep    '^i.*i$' > FLASHextended_resolved.txt
# cat FLASHextendedFrags_seqAndQual.txt | grep -v '^i.*i$' > FLASHextended_nonResolved.txt

# -------------------------------------------
# THE SAME FOR NONFLASHED READS

printThis="Parsing indices for the non-FLASH-combined file .."
printNewChapterToLogFile

parsefile="FLASHnotCombined_1_seqAndQual.txt"
flashed=0
firstRoundParse8
firstRoundParse12

parsefile="FLASHnotCombined_2_seqAndQual.txt"
flashed=0
firstRoundParse8
firstRoundParse12

# ----------------------------------------

# Count them. split to resolved and non-resolved (resolved as 2-column file) .
countAndSplitNonflashedParsed
# Basically extension around these commands :
# paste FLASHnotCombined_1_seqAndQual.txt FLASHnotCombined_2_seqAndQual.txt
#   --> FLASHnotCombined_resolved.txt ( 2 column file : R1\tR2 )
#   --> FLASHnotCombined_nonResolved_1.txt (R1)
#   --> FLASHnotCombined_nonResolved_2.txt (R2)

# ----------------------------------------

# The next rounds, shorter and shorter spacer ..

printThis="Parsing indices - searching for incomplete SPACERs + full length INDEX .."
printNewChapterToLogFile

# First round done above :
# ^GATindexPRIMER -> finding these in AWK. If found, fine, if not, continue to next step.

# These rounds now :
#  ^ATindexPRIMER -> finding these in AWK. If found, fine, if not, continue to next step.
#   ^TindexPRIMER -> finding these in AWK. If found, fine, if not, continue to next step.

spacer8=$(  echo ${spacer8}  | awk '{print substr($1,2)}' )
spacer12=$( echo ${spacer12} | awk '{print substr($1,2)}' )
spacRV8=$( echo ${spacer8} | rev | tr A a | tr T t | tr C c | tr G g | tr a T | tr t A | tr c G | tr g C )
spacRV12=$( echo ${spacer12} | rev | tr A a | tr T t | tr C c | tr G g | tr a T | tr t A | tr c G | tr g C )

# Enabling different lenght spacers here.
while [ "${spacer8}" != "" ] || [ "${spacer12}" != "" ]
do

    spacerLenght8=$(($( echo ${spacer8}   | awk '{print length($1)}' )))
    spacerLenght12=$(($( echo ${spacer12}  | awk '{print length($1)}' )))
    prevSpacerLenght8=$(($(  echo ${spacer8}   | awk '{print length($1)}' )+1))
    prevSpacerLenght12=$(($( echo ${spacer12}  | awk '{print length($1)}' )+1))
    
    # Rename previous output - to not to overwrite
    mv -f FLASHextended_resolved.txt FLASHextended_resolved_${prevSpacerLenght8}_${prevSpacerLenght12}.txt
    mv -f FLASHnotCombined_resolved.txt FLASHnotCombined_resolved_${prevSpacerLenght8}_${prevSpacerLenght12}.txt
    
    # Rename input - to roll with same names 
    mv -f FLASHextended_nonResolved.txt FLASHextendedFrags_seqAndQual.txt
    mv -f FLASHnotCombined_nonResolved_1.txt FLASHnotCombined_1_seqAndQual.txt
    mv -f FLASHnotCombined_nonResolved_2.txt FLASHnotCombined_2_seqAndQual.txt
    
    # Only running for a spacer, if its lenght is not yet zero
    if [ "${spacer8}" != "" ];then
        parsefile="FLASHextendedFrags_seqAndQual.txt"
        flashed=1
        firstRoundParse8

        parsefile="FLASHnotCombined_1_seqAndQual.txt"
        flashed=0
        firstRoundParse8

        parsefile="FLASHnotCombined_2_seqAndQual.txt"
        flashed=0
        firstRoundParse8
    fi
    
    if [ "${spacer12}" != "" ];then
        parsefile="FLASHextendedFrags_seqAndQual.txt"
        flashed=1
        firstRoundParse12

        parsefile="FLASHnotCombined_1_seqAndQual.txt"
        flashed=0
        firstRoundParse12

        parsefile="FLASHnotCombined_2_seqAndQual.txt"
        flashed=0
        firstRoundParse12
    fi

    spacerLenghtInfo="${spacerLenght8}b (fwd indices), and ${spacerLenght12}b (rev indices)"
    countAndSplitParsedFlashed
    countAndSplitNonflashedParsed
    
    # Here setting up next round :
    spacer8=$(  echo ${spacer8}  | awk '{print substr($1,2)}' )
    spacer12=$( echo ${spacer12} | awk '{print substr($1,2)}' )
    spacRV8=$( echo ${spacer8} | rev | tr A a | tr T t | tr C c | tr G g | tr a T | tr t A | tr c G | tr g C )
    spacRV12=$( echo ${spacer12} | rev | tr A a | tr T t | tr C c | tr G g | tr a T | tr t A | tr c G | tr g C )
    
done

# ------------------------------------------
# Last round - when spacer lenght is zero ..

#   ^indexPRIMER -> finding these in AWK. If found, fine, if not, continue to next step.


printThis="Parsing indices - searching for full length INDEX ( and non-existent SPACER ) .."
printNewChapterToLogFile

spacer8=""
spacRV8=""
spacer12=""
spacRV12=""

    prevSpacerLenght8=$(($(  echo ${spacer8}   | awk '{print length($1)}' )+1))
    prevSpacerLenght12=$(($( echo ${spacer12}  | awk '{print length($1)}' )+1))
    
    # Rename previous output - to not to overwrite
    mv -f FLASHextended_resolved.txt FLASHextended_resolved_${spacerLenght8}_${spacerLenght12}.txt
    mv -f FLASHnotCombined_resolved.txt FLASHnotCombined_resolved_${spacerLenght8}_${spacerLenght12}.txt
    
    # Rename input - to roll with same names 
    mv -f FLASHextended_nonResolved.txt FLASHextendedFrags_seqAndQual.txt
    mv -f FLASHnotCombined_nonResolved_1.txt FLASHnotCombined_1_seqAndQual.txt
    mv -f FLASHnotCombined_nonResolved_2.txt FLASHnotCombined_2_seqAndQual.txt

parsefile="FLASHextendedFrags_seqAndQual.txt"
flashed=1
firstRoundParse8
firstRoundParse12

# ----------------------------------------

# Count them. split to resolved and non-resolved.

spacerLenghtInfo="NO SPACER"
countAndSplitParsedFlashed

# -------------------------------------------

parsefile="FLASHnotCombined_1_seqAndQual.txt"
flashed=0
firstRoundParse8
firstRoundParse12

parsefile="FLASHnotCombined_2_seqAndQual.txt"
flashed=0
firstRoundParse8
firstRoundParse12

# ----------------------------------------

# Count them. split to resolved and non-resolved (resolved as 2-column file) .
countAndSplitNonflashedParsed

# ------------------------------------------

# Combine the resolved output files ..

printThis="Listing the output files .."
printNewChapterToLogFile

printThis="(resolved)"
printToLogFile

echo
ls -lht | grep _resolved
echo

printThis="(non-resolved)"
printToLogFile

echo
ls -lht | grep nonResolved
echo

cat FLASHextended_resolved*txt > TEMP.txt
rm -f FLASHextended_resolved*txt
mv -f TEMP.txt FLASHextended_resolved.txt

cat FLASHnotCombined_resolved*.txt > TEMP.txt
rm -f FLASHnotCombined_resolved*.txt
mv -f TEMP.txt FLASHnotCombined_resolved.txt

# -----------------------------------------

# Now we have :

printThis="Listing the COMBINED (resolved) output files .."
printNewChapterToLogFile

echo
ls -lht | grep _resolved
echo

# FLASHextended_resolved.txt
# FLASHnotCombined_resolved.txt

# FLASHextended_nonResolved.txt
# FLASHnotCombined_nonResolved_1.txt
# FLASHnotCombined_nonResolved_2.txt

# -----------------------------------------


# Then, resolving the indices (as deep as we can go when still resolving)
# 
# Round 0 :
# 
# 0a) Taking out only the SEQUENCE of the fastqs
# 
# Round 1 ( this is a for-loop, possibly a script ):
#
# Last round was this :
#    ^indexPRIMER -> finding these in AWK. If found, fine, if not, continue to next step.
#
# So, these remain :
#     ^ndexPRIMER -> finding these in AWK. If found, fine, if not, continue to next step.
#      ^dexPRIMER -> finding these in AWK. If found, fine, if not, continue to next step.
# 
# Until the indices cannot be differentiated from each others any more.
# Discarding rest.
# After each round counting statistics : how many were resolved right away, and how many needed some fiddling,
# and in the end, how many were unresolveable.
# 
# Combining these to single file during each awk (awk would know if it is already resolved from previous)
# 
# This for both indices (i5,i7), both in reverse and forward orientation.

printThis="Parsing indices - searching for incomplete length INDICES .."
printNewChapterToLogFile

printThis="( the incomplete length INDICES search is not yet implemented - skipping this part of the analysis )"
printToLogFile

    
}
