#!/bin/sh
# Source: https://bash.cyberciti.biz/guide/A_progress_bar_(gauge_box))

# Create OUTPUT file
OUTPUT="$PWD/results.csv"

if [[ ! -f $OUTPUT ]]; then
  touch $OUTPUT
fi

msg='
Im folgenden wirst du zwei Ladebalken sehen, versuche zu schätzen wie Lange es dauert bis der Ladebalken 100% erreicht, gib danach deine Schätzung ab.
'
dialog --title "Webner-Fechner-Gesetz Experiment" --msgbox  'Im folgenden wirst du zwei Ladebalken sehen, versuche zu schätzen wie Lange es dauert bis der Ladebalken 100% erreicht, gib danach deine Schätzung ab.
' 10 70

################ Vars
# Start by counter
counter=0
# increase by intervall
intervall=10
# intervall=`shut -i 1-100 -n 1`
# end by end
end=100
# wait delay seconds before increasing the next time
delay=`shuf -i 2-4 -n 1`
multiplier=`shuf -i 2-4 -n 1`
secondDelay=$(( delay*multiplier ))

echo $counter | dialog --title "Forschrittsbalken 1" --gauge "Fortschritt1" 7 70 0
while [[ ! $counter -eq $end ]]; do
    (( counter+=intervall ))
    sleep $delay
    echo $counter | dialog --title "Forschrittsbalken 1" --gauge "Fortschritt1" 7 70 0
done

sleep 2

erste=$(dialog --clear --title "Schätzung Ladebalken1" --inputbox "Gib deine Schätzung in Sekunden an" 10 70 3>&1 1>&2 2>&3 3>&-) 
if [[ ! $? -eq 0 ]]; then
  ~/workspace/simplescripts/scripts/weber-fechner-gesetz.sh
fi

counter=0

echo $counter | dialog --title "Forschrittsbalken 2" --gauge "Schätze wie lange der Balken hat um 100% zu erreichen" 10 70 0
while [[ ! $counter -eq $end ]]; do
    (( counter+=intervall )) 
    sleep $secondDelay
    echo $counter | dialog --title "Forschrittsbalken 2" --gauge "Schätze wie lange der Balken hat um 100% zu erreichen" 10 70 0

done

sleep 2

zweite=$(dialog --clear --title "Schätzung Fortschrittsbalken 2" --inputbox "Gib deine Schätzung in Sekunden an" 10 70 3>&1 1>&2 2>&3 3>&-)
if [[ ! $? -eq 0 ]]; then
    ~/workspace/simplescripts/scripts/weber-fechner-gesetz.sh
fi

delay=$(( delay*10 ))
secondDelay=$(( secondDelay*10 ))

## Schreibe Messung in CSV File
echo "$delay;$secondDelay;$erste;$zweite" >> $OUTPUT

dialog --title "Webner-Fechner-Gesetz Experiment" --msgbox 'Vielen Dank fürs ausfüllen, wenn du das Experiment erneut durchführen willst drücke OK' 10 70

~/workspace/simplescripts/scripts/weber-fechner-gesetz.sh

