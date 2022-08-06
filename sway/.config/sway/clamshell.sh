#!/sbin/env sh
## =============================================================================
##
## Part of Sway configuration (https://code.immerda.ch/technat/wall-e)
##
## Used to make sure the laptop screen is still disabled when reloading sway 
## in clamshell mode
##
## =============================================================================
if grep -q open /proc/acpi/button/lid/LID0/state; then
  swaymsg output eDP-1 enable
else
  swaymsg output eDP-1 disable
fi
