#!/system/bin/sh
### FeraDroid Engine v0.21 | By FeraVolt. 2016 ###
B=/system/engine/bin/busybox
SDK=$(getprop ro.build.version.sdk)
LOG=/sdcard/Android/FDE_log.txt
if [ -e $LOG ]; then
 $B echo "LOG - OK"
else
 LOG=/data/media/0/Android/FDE_log.txt
fi;
if [ "$SDK" -le "19" ] ; then
 FS=false
 TR=true
 GR="mScreenOn"
else
 FS=FF
 TR=N
 GR="state=O"
fi;
sync;
ON=$($B cat /system/engine/assets/FDE_config.txt | $B grep -e 'sleeper=1')
if [ "sleeper=1" = "$ON" ]; then
 $B echo "Sleeper daemon is active." >> $LOG
 while true; do
   until [ "$FS" = "$(dumpsys power | $B grep $GR | $B grep -o "$FS")" ]; do
    $B sleep 21
   done;
  if [ "$FS" = "$(dumpsys power | $B grep -E $GR | $B grep -o "$FS")" ]; then
   sync;
   sleep 9
   service call activity 51 i32 0
   sleep 1
   RAMfree=$($B free -m | $B awk '{ print $4 }' | $B sed -n 2p)
   if [ "$RAMfree" -le "32" ]; then
    if [ -e /proc/sys/vm/drop_caches ]; then
     sync;
     $B sleep 1
     $B echo 3 > /proc/sys/vm/drop_caches
     $B sleep 1
     sync;
    fi;
   fi;
   BA=$($B cat /system/engine/assets/FDE_config.txt | $B grep -e 'battery=' | $B sed -e "s|battery=|""|")
   if [ "$($B cat /sys/class/power_supply/battery/capacity)" -le "$BA" ]; then
    svc wifi disable
    svc nfc disable
    svc data disable
    setprop ro.com.google.networklocation 0
    am broadcast -a android.intent.action.BATTERY_LOW
   fi;
   H=$($B pgrep -l '' | $B grep -E "launcher" | $B awk '{print $1}')
   L=$($B pgrep -l '' | $B grep -E "home" | $B awk '{print $1}')
   P=$($B pgrep -l '' | $B grep -E "phone" | $B awk '{print $1}')
   D=$($B pgrep -l '' | $B grep -E "dialer" | $B awk '{print $1}')
   S=$($B pgrep -l '' | $B grep -E "swap" | $B awk '{print $1}')
   T=$($B pgrep -l '' | $B grep -E "trebuchet" | $B awk '{print $1}')
   M=$($B pgrep -l '' | $B grep -E "service" | $B awk '{print $1}')
   renice [-18] "$H"
   renice [-18] "$L"
   renice [-18] "$P"
   renice 1 "$S"
   renice [-18] "$T"
   renice [-18] "$D"
   renice 1 "$M"
   until [ "$TR" = "$(dumpsys power | $B grep $GR | $B grep -o "$TR")" ]; do
    $B sleep 210
   done;
   if [ "$TR" = "$(dumpsys power | $B grep $GR | $B grep -o "$TR")" ]; then
    service call activity 51 i32 -1
   fi;
  fi;
 done;
else
 $B echo "Sleeper daemon is not active." >> $LOG
fi;
