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

import sys
import re
import matplotlib
print mpl.__version__
# To allow using cluster "non-interactive plotting" - so not to complain when X-windows is not present.
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import matplotlib.patches as patches
from math import ceil

# Text printing and font effects :
# http://matplotlib.org/examples/pylab_examples/usetex_fonteffects.html

colFG = {
    'A': '#5050FF',
    'C': '#E00000',
    'G': '#00C000',
    'T': 'darkorange',
    'N': '#000000',
    'a': '#5050FF',
    'c': '#E00000',
    'g': '#00C000',
    't': 'darkorange',
    'n': '#000000',
    ' ': '#000000',
    '-': '#000000',
    '\\': '#000000',
    '/': '#000000',
    '|': '#000000',
}

colBG = {
    'A': '#5050FF',
    'C': '#E00000',
    'G': '#00C000',
    'T': '#E6e600',
    'N': '#000000',
    'a': '#5050FF',
    'c': '#E00000',
    'g': '#00C000',
    't': '#E6e600',
    'n': '#000000',
    ' ': 'white',
    '-': 'white',
    '/': 'white',
    '\\': 'white',
    '|': '#000000',
}

def printseqLine(seq,y) :
  # Print the colors
  # base_colors[base]
  x=0
  for base in seq:
    # Put the text in there, set its coordinates
    # Invisible base is marked as 'i' or ' ' - so the ones marked 'i' are parsed here.
    if base == 'i' :
      base=' '
    # Now parsed, so plotting !
    if base in colFG:
      outTextThingie = plt.text(x, y, base)
      # Put it into a box - so we can say backgroundcolor
      outTextThingie.set_bbox(dict(facecolor=colBG[base], alpha=0.2, edgecolor=colBG[base]))
      outTextThingie.set_backgroundcolor(colBG[base])
      # Color the font
      outTextThingie.set_color(colFG[base])
      # Set monospace
      outTextThingie.set_family('monospace')
      
      # bb = outTextThingie.get_extents()
      #bb:
      #Bbox(array([[  0.759375 ,   0.8915625],
      #            [ 30.4425   ,   5.6109375]]))
      # w = bb.width   #29.683125
      # h = bb.height  #4.7193749
      # print w
      # print h
    
    x+=0.2
    
    
def printnewIndexLine(y) :
  # class matplotlib.patches.Rectangle(xy, width, height, angle=0.0, **kwargs)
  # Draw a rectangle with lower left at xy = (x, y) with specified width, height and rotation angle.
  axes.add_patch(patches.Rectangle((0, y-0.05), basesNeedSpaceX, 0.03, alpha=1, facecolor="plum", edgecolor="plum"))
    

def printRegularLine(text,y) :
  # Print the line
  x=0
  # Put the text in there, set its coordinates
  outTextThingie = plt.text(x, y, text)
  # Set monospace
  outTextThingie.set_family('monospace')
  
  # set_bbox()
  # set_backgroundcolor(color)
  # set_color(color)
  # set_family(fontname)
  # ACCEPTS: [FONTNAME | 'serif' | 'sans-serif' | 'cursive' | 'fantasy' | 'monospace' ]
  # set_fontsize(fontsize)
  # set_fontstretch(stretch)
  # ACCEPTS: [a numeric value in range 0-1000 | 'ultra-condensed' |
  # 'extra-condensed' | 'condensed' | 'semi-condensed' | 'normal' | 'semi-expanded' | 'expanded' | 'extra-expanded' | 'ultra-expanded' ]
  # set_position(xy)
  # ACCEPTS: (x,y)
  # set_fontstyle(fontstyle)
  # ACCEPTS: [ 'normal' | 'italic' | 'oblique']
  # set_text(s)
  # Set the text string s
  # It may contain newlines (\n) or math in LaTeX syntax.
  # ACCEPTS: string or anything printable with '%s' conversion.

arrayA=[80,80,255]
arrayC=[244,0,0]
arrayG=[0,192,0]
arrayT=[230,230,0]
arrayN=[0,0,0] 

# first parameter is the input file ,
# second parameter is the output file basename
# third parameter is how many hundreds of bases we make space into the figure.


inputFile=sys.argv[1]
outputBasename=sys.argv[2]
hundredsOfBases=int(sys.argv[3])

# fourth, fifth parameter is how many S and D lines we read in (to scale the y-axis)
# Here we generate that :

seqLinesInInput=0
newIndexLinesInInput=0
textLinesInInput=0

with open (inputFile,mode='r') as f:
  for rawline in f:
    line=rawline.strip()
    if (len(line)!=0):
      linetype=line[0]
      text=line[1:]
      if (linetype=="S"):
        seqLinesInInput+=1
      elif (linetype=="N"):
        newIndexLinesInInput+=1
      else:
        textLinesInInput+=1
    else:
      textLinesInInput+=1

print "inputFile"
print inputFile
print "outputBasename"
print outputBasename
print "hundredsOfBases"
print hundredsOfBases
print "seqLinesInInput"
print seqLinesInInput
print "newIndexLinesInInput"
print newIndexLinesInInput
print "textLinesInInput"
print textLinesInInput

# We make the coordinate maxima (X,Y) from the above :

basesNeedSpaceX=hundredsOfBases*20
linesNeedSpaceY=int(ceil((0.4*seqLinesInInput)+(0.4*newIndexLinesInInput)+(0.2*textLinesInInput)))

print "basesNeedSpaceX"
print basesNeedSpaceX
print "linesNeedSpaceY"
print linesNeedSpaceY

# Here max size possible via the renderer :
# ValueError: width and height must each be below 32768
#
# This essentially leads to these max values (not checked runtime - higher dimensions will crash the script ) :
#
# hundredsOfBases=(5/20)*32768 = 8192 (this we will never reach :D )
# 
# linesNeedSpaceY=(0.4*seqLinesInInput)+(0.2*textLinesInInput)-0.6
# seqLinesInInput=(linesMaxY+0.6)/0.6 = (32768+0.6)/0.6 = 54614
#


# First the plot area and highlights ..

plt.ylim(0, linesNeedSpaceY)
plt.xlim(0, basesNeedSpaceX)
plt.setp(plt.gca(), frame_on=False, xticks=(), yticks=())

fig = plt.gcf()
fig.set_size_inches(basesNeedSpaceX, linesNeedSpaceY)

axes = plt.gca()


# Then the actual lines ..
# ( we need to have axes defined before entering the below one - to be able to print "new index" whole line highlights)

# 0.0 (origo) is BOTTOM left - so we need to start from top :
currentYcoordinate=linesNeedSpaceY

with open (inputFile,mode='r') as f:
  for rawline in f:
    line=rawline.strip()
    if (len(line)!=0):
      linetype=line[0]
      text=line[1:]
      if (linetype=="S"):
        currentYcoordinate-=0.2
        printseqLine(text,currentYcoordinate)
        currentYcoordinate-=0.2
      elif (linetype=="N"):
        currentYcoordinate-=0.2
        printnewIndexLine(currentYcoordinate)
        currentYcoordinate-=0.2
      else:
        currentYcoordinate-=0.1
        printRegularLine(text,currentYcoordinate)
        currentYcoordinate-=0.1
        


fig.set_tight_layout(True)
fig.savefig(outputBasename +'.png', dpi=100)


plt.savefig(outputBasename + '.pdf', dpi=100) 

