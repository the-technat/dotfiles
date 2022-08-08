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
# if --no-keys is passed in, skip wshowkeys
if [ $1 != "--no-keys" ]
then
  wshowkeys -F 'Rubik 30' -b '#073642' -f '#839496' -s '#859900' -a bottom -m 10 -t 2 &
  pidWshowkeys=$(echo $!)
  echo $pidWshowkeys > /tmp/wshowkeys.pid
fi

## Find default audio source
defaultSource=$(pactl get-default-source)

## Start wf-recorder
currentFocusedMonitor=$(swaymsg -t get_outputs --raw | jq '. | map(select(.focused == true)) | .[0].name' -r)
wf-recorder -a $defaultSource -o $currentFocusedMonitor -f ~/Videos/record$(date +%d%m%y)-$(date +%H%M%S).mp4 &
pidWFrecorder=$(echo $!)
echo $pidWFrecorder > /tmp/wfrecorder.pid
notify-send -t 5000 "Started recording on $currentFocusedMonitor using Audio from $defaultSource"

exit 0
