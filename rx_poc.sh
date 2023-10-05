#!/bin/bash

today=$(date +%Y%m%d)
weather_report=raw_data_$today

city=hanoi
curl wttr.in/$city --output $weather_report

grep °C $weather_report > temperatures.txt

obs_tmp=$(cat -A temperatures.txt | head -1 | cut -d "+" -f2 | cut -d "^" -f1 )
echo "observed temperature = $obs_tmp"

fc_temp=$(cat -A temperatures.txt | head -3 | tail -1 | cut -d "+" -f2 | cut -d "+" -f2 | cut -d "^" -f1 )
echo "forecast temperature = $fc_temp"

hour=$(TZ='Asia/Ho_Chi_Minh' date +%H)
day=$(TZ='Asia/Ho_Chi_Minh' date +%d)
month=$(TZ='Asia/Ho_Chi_Minh' date +%m)
year=$(TZ='Asia/Ho_Chi_Minh' date +%Y)

report=$(echo -e "$year\t$month\t$day\t$hour\t$obs_tmp\t$fc_temp")
echo $report >> rx_poc.log