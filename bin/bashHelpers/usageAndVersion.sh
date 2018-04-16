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

usage(){

echo
echo
echo "plateScreen96.sh - to analyse 96-well plate sequencing data, where each well is one clone."
echo "Assumed to have 8+12 unique indices (in both ends of the reads) - to identify them."
echo
echo "-h/--help     Show this help "
echo
echo "This script needs 4 parameter files in the running folder (described below)"
echo "Run the script in an empty folder "
echo
echo "Run via queue system, like this :"
echo "qsub -cwd -o plateTest.out -e plateTest.err -N plateTest < ./run.sh"
echo "Minimum run.sh :"
echo "$0 -g hg38"
echo
echo "Run the script in an empty folder "
echo
echo "----------------------------------------------------------------------------------"
echo "FASTQ SETTINGS"
echo "--gz (input files are provided in file.fastq.gz compressed format )"
echo "--lanes 1 (set this to be the number of lanes, if there are more than 1 lanes in your fastq files)"
# echo "--singleEnd ( to run single end sequencing files - default behavior is paired end files)"
# THIS WAS NEVER IMPLEMENTED FULLY - AS IT DOES NOT MAKE SENSE TO USE SINGLE END SEQUENCING IN THIS SITUATION (INDICES WILL NOT BE RESOLVED VERY WELL)
# BELOW IN DETAIL, HOW LONG THE SINGLE-END SUPPORT REACHES.
# Single end support : not fully implemented. The flag exists and is fully integrated to the code.
# The fastqs can be red in (as using NGseqBasic subs to do this) and tested for integrity (as using pyramid subs to do this),
# but they will not be analysed properly (will generate a lot of errors of "missing R2 file" in the analysis part of tha code
# - the single end support for the 96-plate specific parts of the code is not built. 21Feb2017
echo ""
echo "LIBRARY : FRAGMENT LENGHT SETTINGS"
# --flashX (hidden flag) 0 (how many mismatches allowed in flash step - by default zero, and actually no reason to change this.)
echo "--sonicationSize 300 (Max expected size of a flash-combined fragment). Check the correctness of the parameter you gave here, after the run, from the fastQC report of the flashed reads."
echo
echo "--flashOverlap 40    (Only affects the visualisation - How much the reads need to overlap, before they are combined to R1-R2 flashed read. Default super stringent 40 bases. "
echo "                      The rest of the reads continue as non-flashed reads - i.e. this only affects the visualisation part of the analysis. )"
echo ""
echo "MAPPING : BLAT HITS AND REPORTING THEM"
echo "(change these carefully - as these affect your sequence mapping)"
echo "--tileSize 6    (how wide is our tile - the block which we use to find similarities between sequences)"
echo "--minMatch 1    (how many tiles have to match the reference, for the alignment to be reported)"
echo "--stepSize 1    (how often we start new tile along the sequence. Don't change this - 1 is good. )"
echo "--minIdentity 0 (how similar the sequence needs to be to the reference sequence - in percentages 0-100)"
echo "--minScore 0    (how high blat score it needs to have)"
echo "The default parameters are MOST ALLOWING - make them more stringent, if you get a lot of weird small hits due to repetitive reference sequence."

echo ""
echo "PCR : AMPLIFICATION, ARTIFACTS, REPORTING"
echo "--minPCRcount 100    (How many products a read has to have to be printed to output plots."
echo "                      note that this value is for EACH 'different-looking' sequence, i.e. all possible PCR errors will show as 'different sequences',"
echo "                      and are filtered separately by this cutoff."
echo "                      For poor-quality 96-well plate, set this lower (all the way to 10) to get some idea what's going on in the sample. )"
echo
echo "--minLen 0           (How long minimum sequence between the primers is considered worth of investigating : PCR products shorter than this between the indices "
echo "                      are considered 'incomplete PCR products'- amplifying only PCR errors - or 'amplified indexing primers' and discarded."
echo "                      Negative values are 'eating up' into the primer part - by how many bases incomplete primers we allow to be analysed )"
echo "                      Like this :                       "
echo "                    -6 -5 -4 -3 -2 -1 0 1 2 3 4 5 6 7 8   "
echo "                     P  R  I  M  E  R   s e q u e n c e   "
echo
echo "If you have different lenght primers in FWD and REV end, you can set their parameters separately :"
echo "--minLenFwd  0         If you want to set Forward primer "
echo "--minLenRev 0          If you want to set Reverse primer "
echo "The value given in --minLenFwd / --minLenRev overwrites the possible value given in --minLen"
echo
echo "--maxPerWell 20      (How many products we report per well. All these have to have minPCRcounts reads seen. "
echo "                      In default parameter value (20) it means :"
echo "                      If 18 unique PCR products were seen more-than-100-times-each, we report 18 reads."
echo "                      If 28 unique PCR products were seen more-than-100-times-each, we report 20 reads."
echo
echo "----------------------------------------------------------------------------------"
echo
echo "Parameter files :"
echo
echo "1) PIPE_fastqPaths.txt (make just like in DNase/NGseqBasic pipe - accompany with flags --lanes and --gz if needed )"
echo "2) PIPE_spacerBarcodePrimer_FWD.txt (the Forward indices of the design - assuming PLUS strand design) " 
echo "3) PIPE_spacerBarcodePrimer_REV.txt (the Reverse indices of the design - assuming PLUS strand design, i.e. reverse indices given with MINUS strand sequences) "
echo "4) PIPE_targetLocus_mm9.bed (the target locus coordinates - which region was PCR amplified - including the PRIMER sequences. "
echo "                             change genome within the file name, to state in which build your locus is. The data will be also ANALYSED in that build.) "
echo
echo "-----------------------------------------"
echo
echo "1) PIPE_fastqPaths.txt"
echo
echo "make just like in DNase/NGseqBasic pipe - accompany with flags --lanes and --gz if needed"
echo "Instructions here : http://sara.molbiol.ox.ac.uk/public/telenius/NGseqBasicManual/intraWIMM/DnaseCHIPpipeSymbolic_TUTORIAL_intraWIMM.pdf"
echo
echo "-----------------------------------------"
echo
echo "2),3) PIPE_spacerBarcodePrimer_FWD.txt "
echo "      PIPE_spacerBarcodePrimer_REV.txt "
echo
echo "Give these files in <whitespace> delimited format like this :"
echo
echo "PIPE_spacerBarcodePrimer_FWD.txt  ( name platecoordinate spacer index primer )"
echo "PIPE_spacerBarcodePrimer_REV.txt  ( name platecoordinate spacer index primer )"
echo
echo "Example (first 3 lines) :"
echo
echo "HS40SGP2F_i501	A1*     GAT	TATAGCCT	TGATGACTGGGTCAAAGGACAGTGC"	
echo "HS40SGP2F_i502	A2      GAT	TGCCTAGT	TGATGACTGGGTCAAAGGACAGTGC"	
echo "HS40SGP2F_i503	A3      GAT	GTGTGTCA	TGATGACTGGGTCAAAGGACAGTGC"
echo
echo "(*) - col2 is NOT allowed to contain capital letters 'L' or 'S'"
echo
echo "Or - spacer and primer only in first line "
echo
echo "HS40SGP2F_i501	A1*     GAT	TATAGCCT	TGATGACTGGGTCAAAGGACAGTGC"	
echo "HS40SGP2F_i502	A2      -	TGCCTAGT	-                         "	
echo "HS40SGP2F_i503	A3      -	GTGTGTCA	-                         "
echo
echo "(*) - col2 is NOT allowed to contain capital letters 'L' or 'S'"
echo
echo "NOTE ! the hyphen (-) marks your empty spots "
echo
echo "Example (if you have ADAPTOR sequence between INDEX and PRIMER) :"
echo
echo "(1)"
echo "HS40SGP2F_i501	A1*     GAT	TATAGCCTAAAGAAA	TGATGACTGGGTCAAAGGACAGTGC"	
echo "HS40SGP2F_i502	A2      GAT	TGCCTAGTAAAGAAA	TGATGACTGGGTCAAAGGACAGTGC"	
echo "HS40SGP2F_i503	A3      GAT	GTGTGTCAAAAGAAA	TGATGACTGGGTCAAAGGACAGTGC"
echo
echo "OR"
echo
echo "(2)"
echo "HS40SGP2F_i501	A1*     GAT	TATAGCCT	AAAGAAATGATGACTGGGTCAAAGGACAGTGC"	
echo "HS40SGP2F_i502	A2      GAT	TGCCTAGT	AAAGAAATGATGACTGGGTCAAAGGACAGTGC"	
echo "HS40SGP2F_i503	A3      GAT	GTGTGTCA	AAAGAAATGATGACTGGGTCAAAGGACAGTGC"
echo
echo "Both (1) and (2) are supported, but (1) - writing the ADAPTOR into the index, is recommended."
echo
echo "(*) - col2 is NOT allowed to contain capital letters 'L' or 'S'"
echo
echo "-----------------------------------------"
echo
echo "4) PIPE_targetLocus_mm9.bed"
echo "                           chr   start  stop"
echo "PIPE_targetLocus_mm9.bed : chr15 1235   3009 - coordinates of the locus : region where the sequences supposedly originate from "
echo "- including the primer sequence, like this :"
echo 
echo "  chr  start                  stop         "
echo "   FROM HERE                  TO HERE      "
echo "           |                  |            "
echo "           |------------------|            "		
echo "           PRIMERsequencePRIMER            "
echo "SpacerIndexPRIMER        PRIMERIndexSpacer "
echo
echo "(See files 2,3 above for nomenclature of 'spacer' 'index' 'primer' )"
echo
echo "The more exact the region, the better, but rough ballpark is fine as well."
echo "If you have to guess - guess a little larger region, to not to exclude data."
echo 
echo "Bed format is 0-based - subtract 1 from the START coordinate of your UCSC browser region (END coordinate is always fine)."
echo
echo "Notice that the file name ends with the genome build."
echo "This is how you tell the code, which build these coordinates correspond to !"
echo
echo "To highlight a feature of interest (CRISPR cut site, SNP site of interest, etc),"
echo "you can give these coordinates in 'highlight' columns 4-5 :"
echo "Example :"
echo "chr11   12357    15248   14901   14902"
echo
exit 0

}




