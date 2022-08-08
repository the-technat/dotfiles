#!/sbin/env bash
## =============================================================================
##
## Part of Sway configuration (https://github.com/the-technat/WALL-E)
##
## Simple screen recording using default audio source
## notifies you accordingly
##
## =============================================================================

## Checks
if ! command -v wf-recorder &> /dev/null
then
  notify-send -u critical -t 2000 "wf-recorder not installed"
  exit 1
fi
if ! command -v wshowkeys &> /dev/null
then
  notify-send -u critical -t 2000 "wshowkeys not installed"
  exit 1
fi

## Start wshowkeys
wshowkeys -F 'Rubik 30' -b '#073642' -f '#839496' -s '#859900' -a bottom -m 10 -t 2 &
pidWshowkeys=$(echo $!)

## Find default audio source
defaultSource=$(pactl get-default-source)

## Start wf-recorder
currentFocusedMonitor=$(swaymsg -t get_outputs --raw | jq '. | map(select(.focused == true)) | .[0].name' -r)
wf-recorder -a $defaultSource -o $currentFocusedMonitor -f ~/Videos/record$(date +%d%m%y)-$(date +%H%M%S).mp4 &
pidWFrecorder=$(echo $!)

notify-send -t 5000 "Started recording on $currentFocusedMonitor using Audio from $defaultSource"

## Save both pids in file
echo $pidWshowkeys > /tmp/wshowkeys.pid
echo $pidWFrecorder > /tmp/wfrecorder.pid

exit 0
