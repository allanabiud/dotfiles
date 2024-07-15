#!bin/sh
# Add a lock icon and text to the centre of an image
convert /home/abiudy/Pictures/Wallpapers/spiderman-into-the-spider-verse-2018-movie-ey-1366x768.jpg -font Liberation-Sans \
  -pointsize 26 -fill white -gravity center \
  -annotate +0+160 "Type Password to Unlock" './icons/lock.png' \
  -gravity center -composite newimage.png
