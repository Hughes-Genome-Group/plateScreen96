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

curateParsed(){
    
# -----------------------------------------
# We want to do this :
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

# 0) Save the qual-included files as "for troubleshooting" files
#


# 1) Take out only the sequences

printThis="1) Take out only the sequences"
printNewChapterToLogFile

cat FLASHextended_resolved.txt    | grep -v "^QUAL_" > FLASHextended_resolved_onlySeq.txt
cat FLASHnotCombined_forSanityChecks.txt | grep -v "^QUAL_" >  FLASHnotCombined_forSanityChecks_onlySeq.txt

ls -lht | grep _resolved

# 2) Turn all of them so, that indices are in order S L

printThis="2) Turn all of them so, that indices are in order FWD REV"
printNewChapterToLogFile

echo "Total count of flashed reads ( before turning them over ) :"
cat FLASHextended_resolved_onlySeq.txt | grep -c ""

cat FLASHextended_resolved_onlySeq.txt | grep '^S' > FLASHextended_resolved_onlySeq_turned.txt
cat FLASHextended_resolved_onlySeq.txt | grep '^L' | rev | tr A a | tr T t | tr C c | tr G g | tr a T | tr t A | tr c G | tr g C >> FLASHextended_resolved_onlySeq_turned.txt
rm -f FLASHextended_resolved_onlySeq.txt
mv -f FLASHextended_resolved_onlySeq_turned.txt FLASHextended_resolved_onlySeq.txt

echo "Total count of flashed reads ( after turning them over ) :"
cat FLASHextended_resolved_onlySeq.txt | grep -c ""

cut -f 1 FLASHnotCombined_forSanityChecks_onlySeq.txt > TEMP_R1.txt
echo "Total count of NON-flashed R1 reads ( before turning them over ) :"
cat TEMP_R1.txt | grep -c ""
cat TEMP_R1.txt | rev | tr A a | tr T t | tr C c | tr G g | tr a T | tr t A | tr c G | tr g C > TEMPrev_R1.txt
paste TEMP_R1.txt TEMPrev_R1.txt | awk '{if (substr($1,1,1)=="L" || substr($1,length($1),1)=="S") print $2; else print $1}'  > TEMPturned_R1.txt
echo "Total count of NON-flashed R1 reads ( after turning them over ) :"
cat TEMPturned_R1.txt | grep -c ""
rm -f TEMP_R1.txt TEMPrev_R1.txt

cut -f 2 FLASHnotCombined_forSanityChecks_onlySeq.txt > TEMP_R2.txt
echo "Total count of NON-flashed R2 reads ( before turning them over ) :"
cat TEMP_R2.txt | grep -c ""
cat TEMP_R2.txt | rev | tr A a | tr T t | tr C c | tr G g | tr a T | tr t A | tr c G | tr g C > TEMPrev_R2.txt
paste TEMP_R2.txt TEMPrev_R2.txt | awk '{if (substr($1,1,1)=="L" || substr($1,length($1),1)=="S") print $2; else print $1}'  > TEMPturned_R2.txt
echo "Total count of NON-flashed R2 reads ( after turning them over ) :"
cat TEMPturned_R2.txt | grep -c ""
rm -f TEMP_R2.txt TEMPrev_R2.txt

rm -f FLASHnotCombined_forSanityChecks_onlySeq.txt
paste TEMPturned_R1.txt TEMPturned_R2.txt > FLASHnotCombined_forSanityChecks_onlySeq.txt
rm -f TEMPturned_R1.txt TEMPturned_R2.txt

# 3) Check that all of them have both S and L indices available

printThis="3) Check that all of them have both FWD and REV indices available"
printNewChapterToLogFile

echo
echo "Counts of resolved reads :"
echo
echo "Flashed reads - found FWD+FWD or REV+REV indices - and DISCARDED :"
cat FLASHextended_resolved_onlySeq.txt | grep -vc "^S.*L$"
echo
echo "Flashed reads - both FWD and REV indices found :"
cat FLASHextended_resolved_onlySeq.txt | grep -c "^S.*L$"
echo

cat FLASHextended_resolved_onlySeq.txt | grep "^S.*L$" > FLASHextended_SLpairs.txt
rm -f FLASHextended_resolved_onlySeq.txt

echo "Unflashed reads - not found both FWD and REV indices - and DISCARDED :"
cat FLASHnotCombined_forSanityChecks_onlySeq.txt | grep -v "S.*L" | grep -vc "L.*S"
echo
echo "Unflashed reads - both FWD and REV indices found ( continue to further evaluation ) :"
cat FLASHnotCombined_forSanityChecks_onlySeq.txt | grep S | grep -c L
echo

# Parsing the non-flashed to resolved ones ..
# Forbidden combinations will be :
# S.\s (first part ends with S)
# S$ (second part ends with S)
# \tL (second part starts with L)
# ^L (first part starts with L)

cat FLASHnotCombined_forSanityChecks_onlySeq.txt | grep S | grep L | sed 's/^/\t/' | sed 's/$/\t/' > TEMP.txt
rm -f FLASHnotCombined_forSanityChecks_onlySeq.txt
echo "Unflashed reads - REV index in wrong orientation - and DISCARDED :"
cat TEMP.txt | grep -c '\sL'
echo "Unflashed reads - FWD index in wrong orientation - and DISCARDED :"
cat TEMP.txt | grep -c 'S\s'
echo
echo "Unflashed reads - FWD and REV indices in correct orientation :"
cat TEMP.txt | grep -v '\sL' | grep -cv 'S\s'
echo

cat TEMP.txt | grep -v '\sL' | grep -v 'S\s' | sed 's/^\s*//' | sed 's/\s*$//' > FLASHnotCombined_SLpossiblePairs.txt
rm -f TEMP.txt

# 4) Check that the non-flashed reads have the SAME index in both (R1-R2) S and both (R1-R2) L (if they were resolved twice)

printThis="4) Check that the non-flashed reads have the SAME index in both (R1-R2) FWD and both (R1-R2) REV (if they were resolved twice)"
printNewChapterToLogFile

# First, checking S :

cat FLASHnotCombined_SLpossiblePairs.txt | awk '{if (substr($1,1,1)=="S" && substr($1,1,1)==substr($2,1,1)) { if (substr($1,2,1)==substr($2,2,1)) print $0 } else print $0}' > FLASHnotCombined_Svalidated.txt
echo
echo "Unflashed reads - found two different FWD indices ( different index in R1 and R2 )- and DISCARDED :"
cat FLASHnotCombined_SLpossiblePairs.txt | awk '{if (substr($1,1,1)=="S" && substr($1,1,1)==substr($2,1,1)) { if (substr($1,2,1)!=substr($2,2,1)) print $0 } }' | grep -c "" 
echo
rm -f FLASHnotCombined_SLpossiblePairs.txt

# Second, checking L :

cat FLASHnotCombined_Svalidated.txt | awk '{if (substr($1,length($1),1)=="L" && substr($1,length($1),1)==substr($2,length($2),1)) { if (substr($1,length($1)-1,1)==substr($2,length($2)-1,1)) print $0 } else print $0}' > FLASHnotCombined_SLpairs.txt
echo
echo "Unflashed reads - found two different REV indices ( different index in R1 and R2 )- and DISCARDED :"
cat FLASHnotCombined_Svalidated.txt | awk '{if (substr($1,length($1),1)=="L" && substr($1,length($1),1)==substr($2,length($2),1)) { if (substr($1,length($1)-1,1)!=substr($2,length($2)-1,1)) print $0 } }' | grep -c "" 
echo
rm -f FLASHnotCombined_Svalidated.txt


# 5) Provide counts statistics for filter steps (2) and (3) above
#
printThis="5) Provide counts statistics for filter steps (2) (3) (4) above"
printNewChapterToLogFile


echo
echo "Counts of resolved, sanity-checked reads :"
echo
echo "Flashed reads :"
flashTotalSLpairs=$(($( cat FLASHextended_SLpairs.txt | grep -c "" )))
echo ${flashTotalSLpairs}
echo
echo "Unflashed reads - R1, R2 :"
nonFlashTotalSLpairs=$(($( cat FLASHnotCombined_SLpairs.txt | grep -c "" )))
echo ${nonFlashTotalSLpairs}
echo

echo >> ${SUMMARYFILE}
echo "Counts of resolved, sanity-checked reads :" >> ${SUMMARYFILE}
echo >> ${SUMMARYFILE}
echo "Flashed reads :" >> ${SUMMARYFILE}
echo ${flashTotalSLpairs} >> ${SUMMARYFILE}
echo >> ${SUMMARYFILE}
echo "Unflashed reads - R1, R2 :" >> ${SUMMARYFILE}
echo ${nonFlashTotalSLpairs} >> ${SUMMARYFILE}
echo >> ${SUMMARYFILE}


# Printing to user, how much and what we now have (how many resolved pairs for each index)

# Helper files :

cat FLASHextended_SLpairs.txt | sed 's/_.*//' > TEMPflashedSnumber.txt
cat FLASHextended_SLpairs.txt | sed 's/.*_//' | sed 's/e/10/' | sed 's/f/11/' > TEMPflashedLnumber.txt

cat FLASHnotCombined_SLpairs.txt | sed 's/.*S/S/' | sed 's/_.*//' > TEMPnonflashedSnumber.txt
cat FLASHnotCombined_SLpairs.txt | sed 's/L.*/L/' | sed 's/.*_//' | sed 's/e/10/' | sed 's/f/11/' > TEMPnonflashedLnumber.txt


echo
echo "Counts of each FWD and REV index :"
echo
echo >> ${SUMMARYFILE}
echo "Counts of each FWD and REV index :" >> ${SUMMARYFILE}
echo >> ${SUMMARYFILE}

echo "Flashed reads :" 
echo "Flashed reads :" >> ${SUMMARYFILE}

echo
TEMPtotal=0
echo "FWD indices :"
    for k in $( seq 0 $((${#indexNames8[@]} - 1)) ); do
        echo -n "${indexShortNames8[$k]} , ${indexNames8[$k]} , ${indexSeqs8[$k]}  :    "
        echo -n "${indexShortNames8[$k]} , ${indexNames8[$k]} , ${indexSeqs8[$k]}  :    " >> ${SUMMARYFILE}
        TEMPthis=$(($( cat TEMPflashedSnumber.txt | grep -c '^S'"${k}" )))
        TEMPtotal=$((${TEMPtotal}+${TEMPthis}))
        echo ${TEMPthis}
        echo ${TEMPthis} >> ${SUMMARYFILE}   
    done

echo
echo >> ${SUMMARYFILE}

echo
echo "CHECKSUM : total (resolved) , total (index-wise counted)"
echo ${flashTotalSLpairs}
echo ${TEMPtotal}
echo

echo >> ${SUMMARYFILE}
echo "CHECKSUM : total (resolved) , total (index-wise counted)" >> ${SUMMARYFILE}
echo ${flashTotalSLpairs} >> ${SUMMARYFILE}
echo ${TEMPtotal} >> ${SUMMARYFILE}
echo >> ${SUMMARYFILE}

TEMPtotal=0
echo "REV indices :"
echo "REV indices :" >> ${SUMMARYFILE}
    for k in $( seq 0 $((${#indexNames12[@]} - 1)) ); do
        echo -n "${indexShortNames12[$k]} , ${indexNames12[$k]} , ${indexSeqs12[$k]}  :    "
        echo -n "${indexShortNames12[$k]} , ${indexNames12[$k]} , ${indexSeqs12[$k]}  :    " >> ${SUMMARYFILE}
        TEMPthis=$(($( cat TEMPflashedLnumber.txt | grep -c '^'"${k}"'L$' )))
        TEMPtotal=$((${TEMPtotal}+${TEMPthis}))
        echo ${TEMPthis}
        echo ${TEMPthis} >> ${SUMMARYFILE}
    done

echo
echo "CHECKSUM : total (resolved) , total (index-wise counted)"
echo ${flashTotalSLpairs}
echo ${TEMPtotal}
echo

echo >> ${SUMMARYFILE}
echo "CHECKSUM : total (resolved) , total (index-wise counted)" >> ${SUMMARYFILE}
echo ${flashTotalSLpairs} >> ${SUMMARYFILE}
echo ${TEMPtotal} >> ${SUMMARYFILE}
echo >> ${SUMMARYFILE}

rm -f TEMPflashedSnumber.txt TEMPflashedLnumber.txt
    
echo
echo "Unflashed reads :"
echo >> ${SUMMARYFILE}
echo "Unflashed reads :" >> ${SUMMARYFILE}


TEMPtotal=0
echo
echo "FWD indices :"
echo
echo  >> ${SUMMARYFILE}
echo "FWD indices :" >> ${SUMMARYFILE}
echo >> ${SUMMARYFILE}
    for k in $( seq 0 $((${#indexNames8[@]} - 1)) ); do
        echo -n "${indexShortNames8[$k]} , ${indexNames8[$k]} , ${indexSeqs8[$k]}  :    "
        echo -n "${indexShortNames8[$k]} , ${indexNames8[$k]} , ${indexSeqs8[$k]}  :    " >> ${SUMMARYFILE}
        TEMPthis=$(($( cat TEMPnonflashedSnumber.txt | grep -c '^S'"${k}" )))
        TEMPtotal=$((${TEMPtotal}+${TEMPthis}))
        echo ${TEMPthis}
        echo ${TEMPthis} >> ${SUMMARYFILE}        
    done

echo
echo "CHECKSUM : total (resolved) , total (index-wise counted)"
echo ${nonFlashTotalSLpairs}
echo ${TEMPtotal}
echo

echo >> ${SUMMARYFILE}
echo "CHECKSUM : total (resolved) , total (index-wise counted)" >> ${SUMMARYFILE}
echo ${nonFlashTotalSLpairs} >> ${SUMMARYFILE}
echo ${TEMPtotal} >> ${SUMMARYFILE}
echo >> ${SUMMARYFILE}
    

TEMPtotal=0
echo
echo "REV indices :"
echo
echo >> ${SUMMARYFILE}
echo "REV indices :" >> ${SUMMARYFILE}
echo >> ${SUMMARYFILE}
    for k in $( seq 0 $((${#indexNames12[@]} - 1)) ); do
        echo -n "${indexShortNames12[$k]} , ${indexNames12[$k]} , ${indexSeqs12[$k]}  :    "
        echo -n "${indexShortNames12[$k]} , ${indexNames12[$k]} , ${indexSeqs12[$k]}  :    " >> ${SUMMARYFILE}
        TEMPthis=$(($( cat TEMPnonflashedLnumber.txt | grep -c '^'"${k}"'L$' )))
        TEMPtotal=$((${TEMPtotal}+${TEMPthis}))
        echo ${TEMPthis}
        echo ${TEMPthis} >> ${SUMMARYFILE}
    done
    
echo
echo "CHECKSUM : total (resolved) , total (index-wise counted)"
echo ${nonFlashTotalSLpairs}
echo ${TEMPtotal}
echo

echo >> ${SUMMARYFILE}
echo "CHECKSUM : total (resolved) , total (index-wise counted)" >> ${SUMMARYFILE}
echo ${nonFlashTotalSLpairs} >> ${SUMMARYFILE}
echo ${TEMPtotal} >> ${SUMMARYFILE}
echo >> ${SUMMARYFILE}

rm -f TEMPnonflashedSnumber.txt TEMPnonflashedLnumber.txt

    
}