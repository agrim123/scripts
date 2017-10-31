#!/bin/bash

timestamp=$(date +"%m_%d_%Y_%H_%M_%S")

streamer -f jpeg -s 1024x768 -o /path_to_storage/img-$timestamp.jpeg

# Alternate options
#fswebcam -r 1024x768 --jpeg 85 /home/hitman/intruder/vid-$(date +\%m\%d\%k\%M).jpeg
#avconv -f video4linux2 -s vga -i /dev/video0 -vframes 1 /home/hitman/intruder/vid-$(date +\%m\%d\%k\%M).jpg

exit 0
