#!/bin/bash

yesterday_fc=$(tail -2 rx_poc.log | head -1 | cut -d " " -f6)
today_temp=$(tail -1 rx_poc.log | cut -d " " -f5)
accuracy=$(($yesterday_fc-$today_temp))

echo "Accuracy is $accuracy"

if [ -1 -le $accuracy ] && [ $accuracy -le 1 ]
then
   accuracy_range=excellent
elif [ 2 -le $accuracy ] && [ $accuracy -le 2 ]
then
   accuracy_range=good
elif [ 3 -le $accuracy ] && [ $accuracy -le 3 ]
then
   accuracy_range=fair
else
   accuracy_range=poor
fi

echo "Forecast accuracy is $accuracy_range"

row=$(tail -1 rx_poc.log )
year=$(echo $row | cut -d " " -f1)
month=$(echo $row | cut -d " " -f2)