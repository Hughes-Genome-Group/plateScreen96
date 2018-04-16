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

cleanUpFolder(){

rm -rf 1_inspectFastq
mkdir 1_inspectFastq

# 18:11   READ2_fastqc.html
# 18:11   READ2_fastqc.zip
# 18:11   READ1_fastqc.html
# 18:11   READ1_fastqc.zip

mv -f READ* 1_inspectFastq/.

rm -rf 2_flashing
mkdir 2_flashing

# 18:11   FLASHnotCombined_2_fastqc.html
# 18:11   FLASHnotCombined_2_fastqc.zip
# 18:11   FLASHnotCombined_1_fastqc.html
# 18:11   FLASHnotCombined_1_fastqc.zip
# 18:11   FLASHextendedFrags_fastqc.html
# 18:11   FLASHextendedFrags_fastqc.zip
# 18:11   FLASHextendedFrags.fastq
# 18:11   FLASHnotCombined_1.fastq
# 18:11   FLASHnotCombined_2.fastq
# 18:11   out.hist
# 18:11   out.histogram

mv -f FLASHnotCombined_[12][._]fastq* 2_flashing/.
mv -f FLASHextendedFrags[._]fastq* 2_flashing/.
mv -f out.hist 2_flashing/flash_out.hist
mv -f out.histogram 2_flashing/flash_out.histogram
mv -f flashing.log 2_flashing/.


rm -rf 3_indexParsing
mkdir 3_indexParsing

# 18:34   FLASHnotCombined_nonResolved_2_fastqc.html
# 18:34   FLASHnotCombined_nonResolved_2_fastqc.zip
# 18:34   FLASHnotCombined_nonResolved_1_fastqc.html
# 18:34   FLASHnotCombined_nonResolved_1_fastqc.zip
# 18:34   FLASHnotCombined_nonResolved_1.fastq
# 18:34   FLASHnotCombined_nonResolved_2.fastq
# 18:31   FLASHnotCombined_nonResolved_2.txt
# 18:31   FLASHnotCombined_nonResolved_1.txt
# 18:34   FLASHnotCombined_resolved.fastq
# 18:31   FLASHnotCombined_resolved.txt
# 18:34   FLASHextended_nonResolved_fastqc.html
# 18:34   FLASHextended_nonResolved_fastqc.zip
# 18:34   FLASHextended_nonResolved.fastq
# 18:34   FLASHextended_resolved_fastqc.html
# 18:34   FLASHextended_resolved_fastqc.zip
# 18:34   FLASHextended_resolved_2.fastq
# 18:34   FLASHextended_resolved_1.fastq
# 18:34   FLASHextended_resolved.fastq
# 18:31   FLASHextended_resolved.txt
# 18:27   FLASHextended_nonResolved.txt

mv -f FLASH*[Rr]esolved* 3_indexParsing/.

rm -rf 4_filteringParsedReads
mkdir 4_filteringParsedReads

# 18:34   QCfilt_FLASHextended_uniqSLpairs.txt
# 18:34   QCfilt_FLASHnotCombined_uniqSLpairs.txt
# 18:34   QCtable_filtFLASHextended_SLpairs.txt
# 18:34   QCtable_filtFLASHnotCombined_SLpairs.txt
# 18:34   QCtable_FLASHnotCombined_SLpairs.txt
# 18:34   FLASHnotCombined_uniqSLpairs.txt
# 18:34   QCtable_FLASHextended_SLpairs.txt
# 18:34   FLASHextended_uniqSLpairs.txt
# 18:34   FLASHnotCombined_SLpairs.txt
# 18:34   FLASHextended_SLpairs.txt

mv -f *SLpairs* 4_filteringParsedReads/.
mv -f FIGURES 4_filteringParsedReads/.
mv -f QCtable_* 4_filteringParsedReads/.
mv -f FLASHnotCombined_forSanityChecks.txt 4_filteringParsedReads/.
# mv -f PCRcounts.pdf 4_filteringParsedReads/.

rm -rf 5_blatting
mkdir 5_blatting

# 18:34   blatted_parsedForShiny.txt
# 18:34   blatted_parsed.txt
# 18:34   ALLreads.fasta
# 18:34   blatted_noIns_parsed.txt
# 18:34   blatted_noIns.txt
# 18:34   blatted.psl
# 18:34   blatted_sorted.txt
# 18:34   blatted.txt
# 18:34   blatted_withIns.txt

mv -f *blatted* 5_blatting/.
mv -f *forFigure* 5_blatting/.
mv -f ALLreads.fasta 5_blatting/.
cp ../targetLocus.fa 5_blatting/.
mv -f pretty.out 5_blatting/.
mv -f minus.txt 5_blatting/.
mv -f plus.txt 5_blatting/.

mkdir 7_figures
cp [123456]*/*.png 7_figures/.
cp [123456]*/*.pdf 7_figures/.

}
