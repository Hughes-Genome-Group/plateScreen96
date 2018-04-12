#!/bin/bash

maxLinesPerFile=500

blatQC(){

echo "Read count in the psl file (output from BLAT) : "
outputBlatCount=$(($( tail -n +6 blatted.psl | grep -c "" )))
echo ${outputBlatCount}


# If we have reads which didn't blat ..
if [ "${inputBlatCount}" != ${outputBlatCount} ]; then

printThis="8b) Run blat QC-steps (what didn't map in BLAT ..)"
printNewChapterToLogFile

cut -f 10 blatted.psl | sort -k1,1 > TEMPcol10.txt
cat ALLreads.fasta | grep 'E$' | sed 's/^>//' | sort -k1,1 > TEMPinput.txt

join -v 1 TEMPinput.txt TEMPcol10.txt > TEMPinversejoin.txt
rm -f TEMPinput.txt TEMPcol10.txt


cat TEMPinversejoin.txt | sed 's/^S_//' | sed 's/_E$//' | rev | sed 's/_/\t/' | rev | awk '{ print length($2) "\t" $0 }' | sort -k1,1nr | cut -f 1 --complement > TEMPparsed.txt
rm -f TEMPinversejoin.txt

# printThis="11) Set index names to plate coordinate names (instead of abbreviations) .."
# printNewChapterToLogFile

parsefile="TEMPparsed.txt"
indexNamesToFullNames

echo "DSpacer Primer (fwd) :" > unblattedForInspection.txt
head -n 1 ../PIPE_spacerBarcodePrimer_FWD.txt | cut -f 2,4 | sed 's/\s/ - /' | sed 's/^/S/'  >> unblattedForInspection.txt
echo "D-------------------------" >> unblattedForInspection.txt
echo "DSpacer Primer (fwd) ReverseComplement :" >> unblattedForInspection.txt
head -n 1 ../PIPE_spacerBarcodePrimer_FWD.txt | cut -f 2,4 | sed 's/\s/ - /' | rev | tr A a | tr T t | tr C c | tr G g | tr a T | tr t A | tr c G | tr g C | sed 's/^/S/' >> unblattedForInspection.txt
echo "D-------------------------" >> unblattedForInspection.txt

echo "DSpacer Primer (rev) :" >> unblattedForInspection.txt
head -n 1 ../PIPE_spacerBarcodePrimer_REV.txt | cut -f 2,4 | sed 's/\s/ - /' | sed 's/^/S/'  >> unblattedForInspection.txt
echo "D-------------------------" >> unblattedForInspection.txt
echo "DSpacer Primer (rev) ReverseComplement :" >> unblattedForInspection.txt
head -n 1 ../PIPE_spacerBarcodePrimer_REV.txt | cut -f 2,4 | sed 's/\s/ - /' | rev | tr A a | tr T t | tr C c | tr G g | tr a T | tr t A | tr c G | tr g C | sed 's/^/S/' >> unblattedForInspection.txt
echo "D-------------------------" >> unblattedForInspection.txt

echo "DTarget locus :" >> unblattedForInspection.txt
echo "DTarget locus :" >> spacerPrimerRefLocus_forFigure.txt
head -n 1 ../targetLocus.fa | sed 's/^>/D/' >> unblattedForInspection.txt
tail -n 1 ../targetLocus.fa | sed 's/^/S/' >> unblattedForInspection.txt
echo "D-------------------------" >> unblattedForInspection.txt
echo "DTarget locus ReverseComplement :" >> unblattedForInspection.txt
tail -n 1 ../targetLocus.fa | rev | tr A a | tr T t | tr C c | tr G g | tr a T | tr t A | tr c G | tr g C | sed 's/^/S/' >> unblattedForInspection.txt
echo "D-------------------------" >> unblattedForInspection.txt

echo "DUnblatted reads : " >> unblattedForInspection.txt
cat TEMPparsed.txt | sed 's/_/\t/g' | awk '{ print "DIndices [ " $2 " - " $3 " ] " $1 ", PCRcount " $4 "\nS" $5 "\nD" $0  }' >>  unblattedForInspection.txt
rm -f TEMPparsed.txt

basesForFigure=$( cat unblattedForInspection.txt | awk 'BEGIN {m=0} { if (length($0)>m) m=length($0)} END {print int(m/100)+1}')

# If we have less than ${maxLinesPerFile} : we want just all of them - otherwise, we print the ${maxLinesPerFile} first ..
if [ $(($( cat unblattedForInspection.txt | grep -c "" ))) -gt ${maxLinesPerFile} ]; then

    head -n ${maxLinesPerFile} unblattedForInspection.txt > unblattedfirst${maxLinesPerFile}ForFigure.txt
    printThis="More than ~ 200 reads didn't blat. Full list of them available in file unblattedForInspection.txt. \nPrinting the first ~200 of them into a troubleshooting figure now :"
    printToLogFile
    printThis="${PythonHelpersPath}/figurer.py unblattedfirst${maxLinesPerFile}ForFigure.txt unblattedInspection ${basesForFigure}"
    printToLogFile
    python ${PythonHelpersPath}/figurer.py unblattedfirst${maxLinesPerFile}ForFigure.txt unblattedInspection ${basesForFigure}

else

    printThis="${PythonHelpersPath}/figurer.py unblattedForInspection.txt unblattedInspection ${basesForFigure}"
    printToLogFile
    python ${PythonHelpersPath}/figurer.py unblattedForInspection.txt unblattedInspection ${basesForFigure}

fi

fi

}

parseBlatPsl(){

# Blat-related columns
tail -n +6 blatted.psl | cut -f 5,18-21  > blatted_output.txt
# Input name related columns
tail -n +6 blatted.psl | cut -f 9,10      | sed 's/_/\t/g' > blatted_input.txt


# Testing Input-name-related-columns-integrity - have to start with (S) and end with (E) :
# (as we have no idea how wide is the text field in blat, into which this is stored)

# FROM_INPUT_FASTA_FILE___ 
# (0) (1) (2)        (3)         (4)    (5)    (6)  
# +/- S   flash/not  Sind_Lind   count  seq     E 

echo
echo "Count of lines in output file :"
TEMPcount1=$(($( cat blatted_input.txt | grep -c "" )))
echo ${TEMPcount1}
echo


# Only print this (below) - if something goes wonky ..
TEMPcount2=$(($( cat blatted_input.txt | cut -f 2,8 | sed 's/\s/_/' | grep -c "S_E" )))


if [ "${TEMPcount1}" -ne "${TEMPcount2}" ];then
  
  echo "Count of INTACT lines in output file :"
  echo ${TEMPcount2}
  echo
  printThis="Blat corrupted the read name ! - ask Jelena to modify the code (as it is now, it does not support as long sequences as you have in your fastq input! )"  
  printToLogFile
  printThis="This is a FATAL ERROR - EXITING NOW !"  
  printToLogFile
  
  exit 1 
    
fi

# Combining the files :

cut -f 2,8 --complement blatted_input.txt | paste - blatted_output.txt > blatted.txt
rm -f blatted_input.txt blatted_output.txt

# blatted.txt has columns :

# FROM_INPUT_FASTA_FILE___         GENERATED_INSIDE_BLAT____________________________________
# (0)  (1)       (2)   (3)   (4)    (5)    (6)     (7)      (8)          (9)      (10)
# str  flash/not Sind  Lind  count  seq    Qgap#   blocks#  blockSizes   qStarts  tStarts
# +/-  F         S0    1L    127    ACTA   0       1        13,          86,      229,

# First, rev compl for the ones which have (-) as strand ..

cat blatted.txt | grep '^+' > plus.txt
cat blatted.txt | grep '^-' > minus.txt
rm -f blatted.txt

cut -f 6 minus.txt | rev | tr A a | tr T t | tr C c | tr G g | tr a T | tr t A | tr c G | tr g C > reverse.txt
cut -f 1-5 minus.txt > col1to5.txt
cut -f 1-6 --complement minus.txt > col7toEnd.txt
rm -f minus.txt
paste col1to5.txt reverse.txt col7toEnd.txt | cut -f 1 --complement | sed 's/^/BLATTEDtoMINUSstrand/' > minus.txt
rm -f col1to5.txt reverse.txt col7toEnd.txt

cut -f 1 --complement plus.txt | cat - minus.txt > blatted.txt

# now blatted.txt has columns :

# FROM_INPUT_FASTA_FILE___         GENERATED_INSIDE_BLAT____________________________________
# (1)       (2)   (3)   (4)    (5)    (6)     (7)      (8)          (9)      (10)
# flash/not Sind  Lind  count  seq    Qgap#   blocks#  blockSizes   qStarts  tStarts
# F         S0    1L    127    ACTA   0       1        13,          86,      229,

# Preparing for sorting :

cat blatted.txt | sed 's/\s/_/'  | sed 's/\s/_/' | sed 's/_/\t/' > blatted_prep.txt

# Now the new columns are :

# (1)            (2)         (3)    (4)    (5)     (6)      (7)          (8)      (9)        
# flash/not  Sind_Lind   count  seq    Qgap#   blocks#  blockSizes   qStarts  tStarts 

# Sorting (1) along the index-pair, then (2) along the count.

sort -k2,2 -k3,3nr blatted_prep.txt > blatted_all_sorted.txt

# Filtering : only "this many" per index are reported.

echo "Filtering - maximum ${MAXPERWELL} blat results are reported per well (if some reads blatted multiple times, this counts towards the max count here)!"
echo
echo "Before filtering, we have this many unique reads ('alleles') in the whole 96-well plate :"
cat blatted_all_sorted.txt | grep -c ""


echo "Filtering - maximum ${MAXPERWELL} blat results are reported per well (if some reads blatted multiple times, this counts towards the max count here) !" >> ${SUMMARYFILE}
echo >> ${SUMMARYFILE}
echo "Before filtering, we have this many blat results in the whole 96-well plate :" >> ${SUMMARYFILE}
cat blatted_all_sorted.txt | grep -c "" >> ${SUMMARYFILE}

cat blatted_all_sorted.txt | awk 'BEGIN{pre="UNDETERMINED";c=0}{if (pre!=$2){pre=$2;c=0; print$0} else { if (c<'${MAXPERWELL}') c=c+1;print $0 } }' > blatted_filtered_sorted.txt

echo
echo "After filtering, we have this many blat results in the whole 96-well plate :"
cat blatted_filtered_sorted.txt | grep -c ""

echo >> ${SUMMARYFILE}
echo "After filtering, we have this many blat results in the whole 96-well plate :" >> ${SUMMARYFILE}
cat blatted_filtered_sorted.txt | grep -c "" >> ${SUMMARYFILE}

echo
echo "Same - index-wise "

echo >> ${SUMMARYFILE}
echo "Same - index-wise " >> ${SUMMARYFILE}

printKeyToReadIndices
# indiceKey.txt
cat indiceKey.txt
cat indiceKey.txt >> ${SUMMARYFILE}

echo
echo "Before filtering, we have this many blat results :"
echo >> ${SUMMARYFILE}
echo "Before filtering, we have this many blat results :" >> ${SUMMARYFILE}

cut -f 2 blatted_all_sorted.txt | uniq -c > TEMP.txt
echo -e "             \n             \n             \n             \n             \n             \n             \n             \n             \n             \n             \n             \n" > empty.txt ; 

cat TEMP.txt | grep S0 | cat - empty.txt > S0.tmp
cat TEMP.txt | grep S1 | cat - empty.txt > S1.tmp
cat TEMP.txt | grep S2 | cat - empty.txt > S2.tmp
cat TEMP.txt | grep S3 | cat - empty.txt > S3.tmp
cat TEMP.txt | grep S4 | cat - empty.txt > S4.tmp
cat TEMP.txt | grep S5 | cat - empty.txt > S5.tmp
cat TEMP.txt | grep S6 | cat - empty.txt > S6.tmp
cat TEMP.txt | grep S7 | cat - empty.txt > S7.tmp

paste S0.tmp S1.tmp S2.tmp S3.tmp S4.tmp S5.tmp S6.tmp S7.tmp | grep -v '^\s*$'
paste S0.tmp S1.tmp S2.tmp S3.tmp S4.tmp S5.tmp S6.tmp S7.tmp | grep -v '^\s*$' >> ${SUMMARYFILE}

rm -f TEMP.txt S0.tmp S1.tmp S2.tmp S3.tmp S4.tmp S5.tmp S6.tmp S7.tmp

echo
echo "After filtering, we have this many blat results :"
echo >> ${SUMMARYFILE}
echo "After filtering, we have this many blat results :" >> ${SUMMARYFILE}

cut -f 2 blatted_filtered_sorted.txt | uniq -c > TEMP.txt
cat TEMP.txt | grep S0 | cat - empty.txt > S0.tmp
cat TEMP.txt | grep S1 | cat - empty.txt > S1.tmp
cat TEMP.txt | grep S2 | cat - empty.txt > S2.tmp
cat TEMP.txt | grep S3 | cat - empty.txt > S3.tmp
cat TEMP.txt | grep S4 | cat - empty.txt > S4.tmp
cat TEMP.txt | grep S5 | cat - empty.txt > S5.tmp
cat TEMP.txt | grep S6 | cat - empty.txt > S6.tmp
cat TEMP.txt | grep S7 | cat - empty.txt > S7.tmp

paste S0.tmp S1.tmp S2.tmp S3.tmp S4.tmp S5.tmp S6.tmp S7.tmp | grep -v '^\s*$'
paste S0.tmp S1.tmp S2.tmp S3.tmp S4.tmp S5.tmp S6.tmp S7.tmp | grep -v '^\s*$' >> ${SUMMARYFILE}
rm -f TEMP.txt S0.tmp S1.tmp S2.tmp S3.tmp S4.tmp S5.tmp S6.tmp S7.tmp empty.txt

# Adding order number, combining the name part.

cat blatted_filtered_sorted.txt | cat -n | sed 's/^\s*//' | sed 's/\s/_/' | sed 's/\s/_/' | sed 's/\s/_/' > blatted_final_sorted.txt
rm -f blatted_filtered_sorted.txt

# Now the new columns are :

# (1)                                (2)    (3)     (4)      (5)          (6)      (7)              
# orderNo_flash/not_Sind_Lind_count  seq    Qgap#   blocks#  blockSizes   qStarts  tStarts
# 1_F_S0_1L_132   TGATGACTGGGTCAAAGGACAG    0       1        328,         0,       0,



# Adding (for shiny) - the min length of first/last block !
# By definition these HAVE to contain the primer.


# Separating non-insertion-containing and insertion-containing :

cat blatted_final_sorted.txt | awk '{if($3==0) print $0}' | cut -f 3 --complement > blatted_noIns.txt
cat blatted_final_sorted.txt | awk '{if($3!=0) print $0}' | cut -f 3 --complement > blatted_withIns.txt

# Now the new columns are :

# (1)                                (2)    (3)      (4)          (5)      (6)      
# orderNo_flash/not_Sind_Lind_count  seq    blocks#  blockSizes   qStarts  tStarts
# (desc)                            (seq)   (n)      (w)          (s)      (l)      

# new

# Non-insertion containing are easier to parse, making them first :
cat blatted_noIns.txt | sed 's/,/\t/g' | \
awk '{ desc=$1;seq=$2;n=$3;L=0; printf desc; printf "\t";                \
for (i=0; i<n; i++){ \
  w=$(i+4);s=$(i+4+n);l=$(i+4+n+n); \
  if (i==0){ for(c=0;c<(l-L);c++) {printf "i"; }}; \
  if (i!=0){ for(c=0;c<(l-L);c++) {printf "-"; }};\
  printf substr(seq,s+1,w); \
  L=l+w; \
  }; \
print ""}' \
> blatted_noIns_parsed.txt

# The insertion-containing start the same way, naturally :
# ( However, we keep us in 1-line format, to be able to join the files seamlessly, later )

cat blatted_withIns.txt | sed 's/,/\t/g' | \
awk '{ desc=$1;seq=$2;n=$3;L=0;                \
for (i=0; i<n; i++){ \
  w=$(i+4);s=$(i+4+n);l=$(i+4+n+n); \
  if (i==0){ for(c=0;c<(l-L);c++) {printf "i";} } \
  if (i!=0){ for(c=0;c<(l-L);c++) {printf "-"; }}\
  printf substr(seq,s+1,w); \
  L=l+w; \
  }; \
print ""}' \
> blatted_withIns_parsed_a.txt

# Then, we make a separate file for the insertions themselves ..

# (1)                                (2)    (3)      (4)          (5)      (6)      
# orderNo_flash/not_Sind_Lind_count  seq    blocks#  blockSizes   qStarts  tStarts
# (desc)                            (seq)   (n)      (w)          (s)      (l)      

# Q gap   Q gap   block   blockSizes      qStarts  tStarts
# count   bases   count
# 1       12      2       25,25,          0,37,   0,303,
# 1       1       2       194,134,        0,195,  0,194,


# We do 4 things in 3 different coordinate sets (in file b and c), like this :
#
# 1) deletion or read-start (in L coordinates)
# 
# 2) insertion special code (in S coordinates)
#
# 3) fragment "fake print out" (in W coordinates)
#
# 4) last base print (if last part of the sequence is insertion) - after for loop - in S coordinates
#

cat blatted_withIns.txt | sed 's/,/\t/g' | \
awk '{ desc=$1;seq=$2;n=$3;L=0;S=0;\
for (i=0; i<n; i++){ \
w=$(i+4);s=$(i+4+n);l=$(i+4+n+n);\
if (l>L) { for(c=L;c<l;c++) printf "i"; }; \
if (s<=S) { printf "i"; }; \
if (s>S) { printf "/";}; \
for(c=0;c<w-1;c++) {printf "i";};\
L=l+w;S=s+w;\
}; \
if (S<length(seq)){print "/";};\
if (S>=length(seq)){print "";};\
}'\
> blatted_withIns_parsed_c.txt

# File b is more complicated version of c - the (c) file marks just the location of insertion with '/'
# file b prints the whole sequence, which adds a lot of "backtracking" lines, as we need to "restore" the position based on the printed seq length (as soon as we can).
# M is used to hold this "memory" of backlag - if M is not 0, we have printed "too many letters", and want to refrain from printing as much as we can.

cat blatted_withIns.txt | sed 's/,/\t/g' | \
awk '{ desc=$1;seq=$2;n=$3;L=0;S=0;M=0; printf desc; printf "\t";\
for (i=0; i<n; i++){ \
w=$(i+4);s=$(i+4+n);l=$(i+4+n+n);\
if (l>L && M==0 )  { for(c=L;c<l;c++)   {printf "i";} }; \
if (l>L && M!=0 && M<=l-L ){ for(c=L;c<l-M;c++) {printf "i";} }; \
if (l>L && M!=0 && M>l-L ) { M=M-(l-L) ;}; \
if (s>S) { \
  insLen=s-S;M=M+insLen; \
  printf substr(seq,S+1,insLen); \
}; \
if ( M==0 )  { for(c=0;c<w;c++)   {printf "i";} }; \
if ( M!=0 && M<=w )  { for(c=0;c<w-M;c++) {printf "i";};M=0; }; \
if ( M!=0 && M>w )  { M=M-w }; \
L=l+w;S=s+w;\
}; \
if (S<length(seq)){print substr(seq,S+1,length(seq)-S+1);};\
if (S>=length(seq)){print "";};\
}'\
> blatted_withIns_parsed_b.txt




# -----------------------------------------------------------

}

parseTextForPythonFigure(){

printThis="10) Prepare files, and combine them into one file, for image generation .."
printNewChapterToLogFile

# Combining them to a single file ..


# First combining the files, to one line, adding tab for sorting, sorting, taking tab out afterwards ..

# TEST COMMAND (when works, comment out, and use the proper one below !)
# cat blatted_noIns.txt blatted_withIns.txt | cut -f 1,2 > blatted_TEST.txt
# paste blatted_withIns_parsed_b.txt blatted_withIns_parsed_c.txt blatted_withIns_parsed_a.txt \
#  | cat - blatted_TEST.txt blatted_noIns_parsed.txt | sed 's/_/\t/' | sort -k1,1n | sed 's/\s/_/' > TEMPcombined.txt

cat blatted_noIns.txt blatted_withIns.txt | cut -f 1,2 > blatted_TEST.txt
paste blatted_withIns_parsed_b.txt blatted_withIns_parsed_c.txt blatted_withIns_parsed_a.txt \
 | cat - blatted_TEST.txt blatted_noIns_parsed.txt | sed 's/_/\t/' | sort -k1,1n | sed 's/\s/_/' > TEMPwithOrigSeqCombined.txt

# Only the ins-containing TEST-command :
# paste blatted_withIns_parsed_b.txt blatted_withIns_parsed_c.txt blatted_withIns_parsed_a.txt \
#  | cat - blatted_withIns_TEST.txt | sed 's/_/\t/' | sort -k1,1n | sed 's/\s/_/' > TEMPcombined.txt
 

# PROPER COMMAND

paste blatted_withIns_parsed_b.txt blatted_withIns_parsed_c.txt blatted_withIns_parsed_a.txt > blatted_withIns_parsed.txt
rm -f blatted_withIns_parsed_b.txt blatted_withIns_parsed_c.txt blatted_withIns_parsed_a.txt

cat blatted_withIns_parsed.txt blatted_noIns_parsed.txt | sed 's/_/\t/' | sort -k1,1n | sed 's/\s/_/' > TEMPcombined.txt

# -----------------------------------------------------------

# 11) Set index names to full names (instead of abbreviations) ..

# printThis="11) Set index names to plate coordinate names (instead of abbreviations) .."
# printNewChapterToLogFile

parsefile="TEMPcombined.txt"
indexNamesToFullNames

parsefile="TEMPwithOrigSeqCombined.txt"
indexNamesToFullNames


# Then, putting all columns into correct order ..

# (1)     (2)       (3)  (4)  (5) 
# orderNo flash/not Sind Lind count

# orderNo [ index1 - index2 ] F/NF1/NF2
# readCount ${count}

cut -f 1 TEMPcombined.txt | sed 's/_/\t/g' | awk '{print $1"\t"$3"\t"$4"\t"$2"\t"$5 }' > TEMPforShiny.txt 

# Finally, marking the lines for printing ..

# D = description (general text - no colors)
# S = sequence (ATCGN-' ' only) - colors basewise
# N = new index starting - will be highlighted in the python code

 cat TEMPcombined.txt | sed 's/_/\t/g' | \
  awk 'BEGIN{a="start";b="start"}\
      { \
        if (a!=$3 || b!=$4){print "N";a=$3;b=$4};\
        print "DOrderNo " $1 " , Indices [ " $3 " - " $4 " ] " $2 ", PCRcount " $5 "\nS" $6;\
        if (length($7)!=0) print "S" $7 ; if (length($8)!=0) print "S" $8 \
      }' > blatted_parsed.txt
 
 cat TEMPwithOrigSeqCombined.txt | sed 's/_/\t/g' | \
  awk 'BEGIN{a="start";b="start"}\
      { \
        if (a!=$3 || b!=$4){print "N";a=$3;b=$4};\
        print "DOrderNo " $1 " , Indices [ " $3 " - " $4 " ] " $2 ", PCRcount " $5 "\nS" $6;\
        if (length($7)!=0) print "S" $7 ; if (length($8)!=0) print "S" $8 \
      }' > blatted_withOrigSeq_parsed.txt

rm -f TEMPcombined.txt TEMPwithOrigSeqCombined.txt



printFigureKeyToReadIndices
# indiceKey.txt

echo "D-------------------------" >> spacerPrimerRefLocus_forFigure.txt
echo "DIf primers were FWD-indices 5prime , REV-indices 3prime :" >> spacerPrimerRefLocus_forFigure.txt
echo "D-------------------------" >> spacerPrimerRefLocus_forFigure.txt
echo "DSpacer Primer (FWD) :" > spacerPrimerRefLocus_forFigure.txt
head -n 1 ../PIPE_spacerBarcodePrimer_FWD.txt | cut -f 2,4 | sed 's/\s/ - /' | sed 's/^/S/' >> spacerPrimerRefLocus_forFigure.txt
echo "D-------------------------" >> spacerPrimerRefLocus_forFigure.txt
echo "DSpacer Primer (REV) ReverseComplement :" >> spacerPrimerRefLocus_forFigure.txt
head -n 1 ../PIPE_spacerBarcodePrimer_REV.txt | cut -f 2,4 | sed 's/\s/ - /' | rev | tr A a | tr T t | tr C c | tr G g | tr a T | tr t A | tr c G | tr g C | sed 's/^/S/' >> spacerPrimerRefLocus_forFigure.txt
echo "D-------------------------" >> spacerPrimerRefLocus_forFigure.txt
echo "DIf primers were REV-indices 5prime , FWD-indices 3prime :" >> spacerPrimerRefLocus_forFigure.txt
echo "D-------------------------" >> spacerPrimerRefLocus_forFigure.txt
echo "DSpacer Primer (FWD) in reverse orientation :" >> spacerPrimerRefLocus_forFigure.txt
head -n 1 ../PIPE_spacerBarcodePrimer_REV.txt | cut -f 2,4 | sed 's/\s/ - /' | sed 's/^/S/'  >> spacerPrimerRefLocus_forFigure.txt
echo "D-------------------------"  >> spacerPrimerRefLocus_forFigure.txt
echo "DSpacer Primer (REV) in forward orientation :"  >> spacerPrimerRefLocus_forFigure.txt
head -n 1 ../PIPE_spacerBarcodePrimer_FWD.txt | cut -f 2,4 | sed 's/\s/ - /' | rev | tr A a | tr T t | tr C c | tr G g | tr a T | tr t A | tr c G | tr g C | sed 's/^/S/' >> spacerPrimerRefLocus_forFigure.txt
echo "D-------------------------"  >> spacerPrimerRefLocus_forFigure.txt
echo "DTarget locus :" >> spacerPrimerRefLocus_forFigure.txt
head -n 1 ../targetLocus.fa | sed 's/^>/D/' >> spacerPrimerRefLocus_forFigure.txt
tail -n 1 ../targetLocus.fa | sed 's/^/S/' >> spacerPrimerRefLocus_forFigure.txt
echo "D-------------------------" >> spacerPrimerRefLocus_forFigure.txt
echo "DNomenclature : " >> spacerPrimerRefLocus_forFigure.txt
echo "DNF = non-flashed , F = flashed. " >> spacerPrimerRefLocus_forFigure.txt
echo "Did = running uniqueness id number for the read (reads with multiple blat results, will share the id number)" >> spacerPrimerRefLocus_forFigure.txt
echo "DOrderNO = running ordinal number for the read (to sort reads so, that reads from same well come one after another)" >> spacerPrimerRefLocus_forFigure.txt
echo "D-------------------------" >> spacerPrimerRefLocus_forFigure.txt

# Here, checking we don't have too many lines - if we do, printing in batches ..

printingInBatches=0
if [ $(($( cat blatted_parsed.txt | grep -c "" ))) -lt ${maxLinesPerFile} ]; then

  # Normal printing
  echo "DSample Name : ${nameList[$i]}"  > forFigure.txt
  cat indiceKey.txt | sed 's/^/D/' | cat -  spacerPrimerRefLocus_forFigure.txt blatted_parsed.txt >> forFigure.txt
  echo "DSample Name : ${nameList[$i]}"  > forFigure_withOrigSeq.txt
  cat indiceKey.txt | sed 's/^/D/' | cat -  spacerPrimerRefLocus_forFigure.txt blatted_withOrigSeq_parsed.txt >> forFigure_withOrigSeq.txt
   
else

  # Printing in batches
  printingInBatches=1
  
  rm -f blatted_parsed_remainder.txt
  cp blatted_parsed.txt blatted_parsed_remainder.txt
  
  # Printing the expexcted rounds count :
  
  tempcount=$( cat blatted_parsed_remainder.txt | grep -c "" | awk '{ print int((($1/'${maxLinesPerFile}')+1))} ' )
  
  echo
  echo "Expecting to result in ${tempcount} separate visualisation files (each file printing ~200 sequences)"
  echo
  
  round=0
  while [ $(($( cat blatted_parsed_remainder.txt | grep -c "" ))) -gt 0 ] && [ ${round} -lt 50 ]
  do
    round=$((${round}+1))

    # Finding a proper place to put the cut.
    lastLine=$(($(head -n ${maxLinesPerFile} blatted_parsed_remainder.txt | cat -n | grep '\sDOrderNo' | tail -n 1 | sed 's/^\s*//' | sed 's/\s.*//')-1))
    
    # If we have less than ${maxLinesPerFile} : we want just all of them - last round.
    if [ $(($( cat blatted_parsed_remainder.txt | grep -c "" ))) -lt ${maxLinesPerFile} ]; then
       lastLine=$(($( cat blatted_parsed_remainder.txt | grep -c "" )))
    fi
    
    head -n ${lastLine} blatted_parsed_remainder.txt > blatted_parsed_${round}.txt
    tail -n +$((${lastLine}+1)) blatted_parsed_remainder.txt > TEMP.txt
    mv -f TEMP.txt blatted_parsed_remainder.txt
    
    echo "DSample Name : ${nameList[$i]}_${round}" > forFigure_${round}.txt
    cat indiceKey.txt | sed 's/^/D/' | cat -  spacerPrimerRefLocus_forFigure.txt blatted_parsed_${round}.txt >> forFigure_${round}.txt
  
  done
  
  rm -f blatted_parsed_remainder.txt
  cp blatted_withOrigSeq_parsed.txt blatted_parsed_remainder.txt
  
  round=0
  while [ $(($( cat blatted_parsed_remainder.txt | grep -c "" ))) -gt 0 ]
  do
    round=$((${round}+1))

    # Finding a proper place to put the cut.
    lastLine=$(($(head -n ${maxLinesPerFile} blatted_parsed_remainder.txt | cat -n | grep '\sDOrderNo' | tail -n 1 | sed 's/^\s*//' | sed 's/\s.*//')-1))
    
    # If we have less than ${maxLinesPerFile} : we want just all of them - last round.
    if [ $(($( cat blatted_parsed_remainder.txt | grep -c "" ))) -lt ${maxLinesPerFile} ]; then
       lastLine=$(($( cat blatted_parsed_remainder.txt | grep -c "" )))
    fi
    
    head -n ${lastLine} blatted_parsed_remainder.txt > blatted_parsed_withOrigSeq_${round}.txt
    tail -n +$((${lastLine}+1)) blatted_parsed_remainder.txt > TEMP.txt
    mv -f TEMP.txt blatted_parsed_remainder.txt
    
   echo "DSample Name : ${nameList[$i]}_${round}" > forFigure_withOrigSeq_${round}.txt
   cat indiceKey.txt | sed 's/^/D/' | cat -  spacerPrimerRefLocus_forFigure.txt blatted_parsed_withOrigSeq_${round}.txt >> forFigure_withOrigSeq_${round}.txt
  
  done
  rm -f blatted_parsed_remainder.txt
  
fi

rm -f indiceKey.txt spacerPrimerRefLocus_forFigure.txt

}

quickFix(){
    
echo "/package/blat/35/bin/pslPretty -long blatted.psl ../targetLocus.fa ALLreads.fasta pretty.out"
/package/blat/35/bin/pslPretty -long blatted.psl ../targetLocus.fa ALLreads.fasta pretty.out

cat pretty.out | \
awk '{if (substr($1,1,1) == ">" ) { if(NR>1) {print s[1]; print s[2] ; print s[3] } ; print $0 ; s[1]="";s[2]="";s[3]="";s[4]="";c=0} \
else {c=c+1;s[c%4]=s[c%4]""$0;} } \
END {print s[1]; print s[2]; print s[3]; print s[4]}' \
| awk '{if(NR%4==1)print "D"$0; else print "S"$0}' > blatted_parsed_alsoReferenceAligned.txt

basesForFigure=$( cat blatted_parsed_alsoReferenceAligned.txt | awk 'BEGIN {m=0} { if (length($0)>m) m=length($0)} END {print int(m/100)+1}')

printingInBatches=0
# maxLinesPerAlsoRefFile=$((${maxLinesPerFile}/2))
maxLinesPerAlsoRefFile=${maxLinesPerFile}
if [ $(($( cat blatted_parsed_alsoReferenceAligned.txt | grep -c "" ))) -lt $((${maxLinesPerAlsoRefFile})) ]; then

  cat blatted_parsed_alsoReferenceAligned.txt > forFigure_alsoReferenceAligned.txt

else

  # Printing in batches
  printingInBatches=1
  
  rm -f blatted_parsed_remainder_alsoReferenceAligned.txt
  cp blatted_parsed_alsoReferenceAligned.txt blatted_parsed_remainder_alsoReferenceAligned.txt
  
  # Printing the expexcted rounds count :
  
  tempcount=$( cat blatted_parsed_remainder_alsoReferenceAligned.txt | grep -c "" | awk '{ print int((($1/'${maxLinesPerAlsoRefFile}')+1))} ' )
  
  echo
#  echo "Expecting to result in ${tempcount} separate visualisation files (each file printing ~100 sequences)"
  echo "Expecting to result in ${tempcount} separate visualisation files (each file printing ~200 sequences)"
  echo "Printing max 50 first of these."
  echo
  
  round=0
  while [ $(($( cat blatted_parsed_remainder_alsoReferenceAligned.txt | grep -c "" ))) -gt 0 ] && [ ${round} -lt 50 ]
  do
    round=$((${round}+1))

    # Finding a proper place to put the cut.
    lastLine=$(($(head -n ${maxLinesPerAlsoRefFile} blatted_parsed_remainder_alsoReferenceAligned.txt | cat -n | grep '\sD>S' | tail -n 1 | sed 's/^\s*//' | sed 's/\s.*//')-1))
    
    # If we have less than ${maxLinesPerFile} : we want just all of them - last round.
    if [ $(($( cat blatted_parsed_remainder_alsoReferenceAligned.txt | grep -c "" ))) -lt ${maxLinesPerAlsoRefFile} ]; then
       lastLine=$(($( cat blatted_parsed_remainder_alsoReferenceAligned.txt | grep -c "" )))
    fi
    
    head -n ${lastLine} blatted_parsed_remainder_alsoReferenceAligned.txt > forFigure_alsoReferenceAligned_${round}.txt
    tail -n +$((${lastLine}+1)) blatted_parsed_remainder_alsoReferenceAligned.txt > TEMP.txt
    mv -f TEMP.txt blatted_parsed_remainder_alsoReferenceAligned.txt
  
  done
    
fi
    
    
}
