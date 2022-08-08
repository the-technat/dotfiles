#!/sbin/env bash
## =============================================================================
##
## Part of Sway configuration (https://github.com/the-technat/WALL-E)
##
## Simple screen recording using default audio source
## notifies you accordingly
##
## =============================================================================

## See if we got some pids
pidWshowkeys=$(cat /tmp/wshowkeys.pid)
pidWFrecorder=$(cat /tmp/wfrecorder.pid)

if [ $pidWFrecorder != "" ] 
then
  kill -INT $pidWFrecorder 
  notify-send -t 5000 "Recording has been saved to ~/Videos/record$(date +%d%m%y)-$(date +%H%M%S).mp4"
  rm /tmp/wfrecorder.pid
  exit 0
else
  notify-send -u normal -t 2000 "No recording is running"
  exit 1
fi

if [ $pidWshowkeys != "" ]
then
  kill -SIGTERM $pidWshowkeys 
  rm /tmp/wshowkeys.pid
fi
  

