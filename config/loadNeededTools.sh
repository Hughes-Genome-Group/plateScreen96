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



setPathsForPipe(){

# #############################################################################

# This is the CONFIGURATION FILE to load in the needed toolkits ( conf/loadNeededTools.sh )

# #############################################################################

# Setting the needed programs to path.

# This can be done EITHER via module system, or via EXPORTING them to the path.
# If exporting to the path - the script does not check already existing conflicting programs (which may contain executable with same names as these)

# If neither useModuleSystem or setPathsHere : the script assumes all toolkits are already in path !

# If you are using module system
useModuleSystem=1
# useModuleSystem=1 : load via module system
# useModuleSystem=0 : don't use module system

# If you are adding to path (using the script below)
setPathsHere=0
# setPathsHere=1 : set tools to path using the bottom of this script
# setPathsHere=0 : dset tools to path using the bottom of this script

# If neither useModuleSystem or setPathsHere : the script assumes all toolkits are already in path !

# #############################################################################

# PATHS_LOADED_VIA_MODULES

if [ "${useModuleSystem}" -eq 1 ]; then

module purge
# Removing all already-loaded modules to start from clean table

module load blat/35
# Not known if would support other blat versions. Most probably will support.

module load bedtools/2.17.0
# Supports bedtools versions 2.1* . Does not support bedtools versions 2.2*

module load flash/1.2.8
# Not known if would support other flash versions. Most probably will support.

module load fastqc/0.11.4
# Will not support fastqc versions 0.10.* or older

module load multiqc/0.7
# Not known if would support other multiqc versions. Most probably will support.

# if your multiqc module does not auto-load python, you need to load python 2.x separately :

# module load python/2.7.8

module load perl/5.18.1
# Most probably will run with any perl

module load R/3.2.1
# Most probably will run with any R

module list 2>&1

perl --version | head -n 3
python --version 2>&1
R --version | head -n 3

# #############################################################################

# EXPORT_PATHS_IN_THIS_SCRIPT

elif [ "${setPathsHere}" -eq 1 ]; then

echo
echo "Adding tools to PATH .."
echo
    
# Note !!!!!
# - the script does not check already existing conflicting programs within $PATH (which may contain executable with same names as these)

export PATH=$PATH:/package/blat/35/bin
export PATH=$PATH:/package/bedtools/2.17.0/bin
export PATH=$PATH:/package/flash/1.2.8/bin
export PATH=$PATH:/package/fastqc/0.11.4/bin
export PATH=$PATH:/package/multiqc/0.7/bin
export PATH=$PATH:/package/python/2.7.8/bin
export PATH=$PATH:/package/perl/5.18.1/bin
export PATH=$PATH:/package/R/3.2.1/bin

# See notes of SUPPORTED VERSIONS above !

echo $PATH
perl --version | head -n 3
python --version 2>&1
R --version | head -n 3

# #############################################################################

# EXPORT_NOTHING_i.e._ASSUMING_USER_HAS_TOOLS_LOADED_VIA_OTHER_MEANS

else
    
echo
echo "Tools should already be available in PATH - not loading anything .."
echo

fi

# #########################################


}
