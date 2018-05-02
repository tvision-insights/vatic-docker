#!/bin/bash

ID=$1
TODOVIDEOPATH=/root/vatic/data/videos_in/$ID
DONEVIDEOPATH=/root/vatic/data/videos_out/$ID
FRAMEPATH="/root/vatic/data/"$ID"_frames_in"

mkdir -p $FRAMEPATH
mkdir -p $DONEVIDEOPATH

cd /root/vatic
for i in $( ls $TODOVIDEOPATH); do
    turkic extract $TODOVIDEOPATH/$i $FRAMEPATH --width 720 --height 480
    mv $TODOVIDEOPATH/$i $DONEVIDEOPATH/
done
