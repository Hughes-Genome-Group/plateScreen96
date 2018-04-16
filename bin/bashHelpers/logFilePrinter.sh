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

printToLogFile(){
   
# Needs this to be set :
# printThis="" 

echo ""
echo -e "${printThis}"
echo ""

echo "" >&2
echo -e "${printThis}" >&2
echo "" >&2
    
}

printNewChapterToLogFile(){

# Needs this to be set :
# printThis=""
    
echo ""
echo "---------------------------------------------------------------------"
echo -e "${printThis}"
echo "---------------------------------------------------------------------"
echo ""

echo "" >&2
echo "----------------------------------------------------------------------" >&2
echo -e "${printThis}" >&2
echo "----------------------------------------------------------------------" >&2
echo "" >&2
    
}
