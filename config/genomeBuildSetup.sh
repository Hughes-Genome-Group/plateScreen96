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

setGenomeLocations(){

# #############################################################################

# This is the CONFIGURATION FILE to set up your BOWTIE GENOME INDICES ( conf/genomeBuildSetup.sh )

# Fill the locations of :

# - bowtie indices (bowtie 1/2 )
# - ucsc chromosome size files (genomes mm9,mm10,hg18,hg19,hg38,danRer7,danRer10,galGal4,dm3 already supported)
# - blacklisted regions bed files (genomes mm9,mm10,hg18,hg19 already provided)

# As given in below examples

# #############################################################################
# SUPPORTED GENOMES 
# #############################################################################

# Add and remove genomes via this list.
# If user tries to use another genome (not listed here), the run is aborted with "genome not supported" message.

supportedGenomes[0]="mm9"
supportedGenomes[1]="mm10"
supportedGenomes[2]="hg18"
supportedGenomes[3]="hg19"
supportedGenomes[4]="hg38"
supportedGenomes[5]="danRer7"
supportedGenomes[6]="danRer10"
supportedGenomes[7]="galGal4"
supportedGenomes[8]="ce10"
supportedGenomes[9]="ce6"
supportedGenomes[10]="panTro3"
supportedGenomes[11]="rn4"
supportedGenomes[12]="rn5"
supportedGenomes[13]="susScr3"

# #############################################################################
# GENOME FASTA FILE PATHS
# #############################################################################

# Update the file paths of the above genomes here ..

    GenomeFastaList[0]="/databank/igenomes/Mus_musculus/UCSC/mm9/Sequence/WholeGenomeFasta/genome.fa"
    GenomeFastaList[1]="/databank/igenomes/Mus_musculus/UCSC/mm10/Sequence/WholeGenomeFasta/genome.fa"
    GenomeFastaList[2]="/databank/igenomes/Homo_sapiens/UCSC/hg18/Sequence/WholeGenomeFasta/genome.fa"
    GenomeFastaList[3]="/databank/igenomes/Homo_sapiens/UCSC/hg19/Sequence/WholeGenomeFasta/genome.fa"
    GenomeFastaList[4]="/databank/igenomes/Homo_sapiens/UCSC/hg38/Sequence/WholeGenomeFasta/genome.fa"
    GenomeFastaList[5]="/databank/igenomes/Danio_rerio/UCSC/danRer7/Sequence/WholeGenomeFasta/genome.fa"
    GenomeFastaList[6]="/databank/igenomes/Danio_rerio/UCSC/danRer10/Sequence/WholeGenomeFasta/genome.fa"
    GenomeFastaList[7]="/databank/igenomes/Gallus_gallus/UCSC/galGal4/Sequence/WholeGenomeFasta/genome.fa"
    GenomeFastaList[8]="/databank/igenomes/Caenorhabditis_elegans/UCSC/ce10/Sequence/WholeGenomeFasta/genome.fa"
    GenomeFastaList[9]="/databank/igenomes/Caenorhabditis_elegans/UCSC/ce6/Sequence/WholeGenomeFasta/genome.fa"
    GenomeFastaList[10]="/databank/igenomes/Pan_troglodytes/UCSC/panTro3/Sequence/WholeGenomeFasta/genome.fa"
    GenomeFastaList[11]="/databank/igenomes/Rattus_norvegicus/UCSC/rn4/Sequence/WholeGenomeFasta/genome.fa"
    GenomeFastaList[12]="/databank/igenomes/Rattus_norvegicus/UCSC/rn5/Sequence/WholeGenomeFasta/genome.fa"
    GenomeFastaList[13]="/databank/igenomes/Sus_scrofa/UCSC/susScr3/Sequence/WholeGenomeFasta/genome.fa"

}

