# Weather-Forecast
Historical Weather Forecast Comparison to Actuals

# OVERVIEW
Create a Bash script to extract, transform, and load weather data, schedule it to run daily, and write a script to measure forecast accuracy.

# OBJECTIVES
- Initialize your log file
- Write a Bash script to download, extract, and load raw data into a report
- Add some basic analytics to report
- Schedule report to update daily
- Measure and report on historical forecasting accuracy

# PROCESS
### 1. Initialize weather report log file
- Create a text file called rx_poc.log
```
    touch rx_poc.log
```
- Add a header to your weather report
```
    header=$(echo -e "year\tmonth\tday\tobs_tmp\tfc_temp")
    echo $header>rx_poc.log
```
![image](https://github.com/CodeWorld-X/Weather-Forecast/assets/129016922/01b30581-53d5-449c-9f4e-b27852570a85)

### 2. Download the raw weather data
- Create a text file called rx_poc.sh and make it an executable Bash script
```
    touch rx_poc.sh
```
Include the Bash shebang on the first line of rx_poc.sh:
```
    #!/bin/bash
```
Make your script executable by running the following in the terminal:
```
chmod u+x rx_poc.sh
```
![image](https://github.com/CodeWorld-X/Weather-Forecast/assets/129016922/a0acb8f1-43c1-4b79-a2b8-5cf0a56fac28)

### 3. Edit rx_poc.sh to download today's weather report from wttr.in

web wttr.in
![image](https://github.com/CodeWorld-X/Weather-Forecast/assets/129016922/cea60795-ba42-4a8b-b359-650bc3e636d2)

Download and save your report as a datestamped file named raw_data_<YYYYMMDD>, where <YYYYMMDD> is today's date in Year, Month, and Day format.

- Create the filename for today's wttr.in weather report
Edit rx_poc.sh to include:
```
    today=$(date +%Y%m%d)
    weather_report=raw_data_$today
```

- Download the wttr.in weather report for Casablanca and save it with the filename you created
```
    city=hanoi
    curl wttr.in/$city --output $weather_report
```
![image](https://github.com/CodeWorld-X/Weather-Forecast/assets/129016922/d8193fe5-72a7-46a0-9c38-4009fb8fef46)

### 4. Extract and load the required data
- Edit "rx_poc.sh" to extract the required data from the raw data file and assign them to variables "obs_tmp" and "fc_temp"
```
    grep °C $weather_report > temperatures.txt
```
![image](https://github.com/CodeWorld-X/Weather-Forecast/assets/129016922/02fa951d-e6da-4f54-a87c-4d06044c1b05)

- Extract the current temperature, and store it in a shell variable called "obs_tmp"
```
    # extract the current temperature
    obs_tmp=$(cat -A temperatures.txt | head -1 | cut -d "+" -f2 | cut -d "^" -f1 )
    echo "observed temperature = $obs_tmp"
```

-  Extract tomorrow's temperature forecast for noon, and store it in a shell variable called "fc_tmp"
```
    fc_temp=$(cat -A temperatures.txt | head -3 | tail -1 | cut -d "+" -f2 | cut -d "+" -f2 | cut -d "^" -f1 )
    echo "forecast temperature = $fc_temp"
```
- Store the current hour, day, month, and year in corresponding shell variables
```
    hour=$(TZ='Asia/Ho_Chi_Minh' date +%H)
    day=$(TZ='Asia/Ho_Chi_Minh' date +%d)
    month=$(TZ='Asia/Ho_Chi_Minh' date +%m)
    year=$(TZ='Asia/Ho_Chi_Minh' date +%Y)
```
- Merge the fields into a tab-delimited record, corresponding to a single row in Table
```
    record=$(echo -e "$year\t$month\t$day\t$obs_tmp\t$fc_temp")
    echo $record>>rx_poc.log
```
### 5. Schedule your Bash script rx_poc.sh to run every day at noon time
Create a cron job that runs your script
```
    crontab -e
    0 12 * * * /home/project/coursera/rx_poc.sh
```

### 6. Full solution
```
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
```

### 6. Create a script to report historical forecasting accuracy
Now that you've created an ETL shell script to gather weather data into a report, let's create another script to measure and report the accuracy of the forecasted temperatures against the actuals.
To begin, create a tab-delimited file called historical_fc_accuracy.tsv using the following code to insert a header of column names:
```
    echo -e "year\tmonth\tday\tobs_tmp\tfc_temp\taccuracy\taccuracy_range" > historical_fc_accuracy.tsv
```
Also create an executable Bash script called fc_accuracy.sh.
Rather than scheduling your new script to run periodically, think of it as a tool you can use to generate the historical forecast accuracy on demand.
* Determine the difference between today's forecasted and actual temperatures
- Extract the forecasted and observed temperatures for today and store them in variables
```
    yesterday_fc=$(tail -2 rx_poc.log | head -1 | cut -d " " -f6)
```
- Calculate the forecast accuracy
```
    today_temp=$(tail -1 rx_poc.log | cut -d " " -f5)
    accuracy=$(($yesterday_fc-$today_temp))
```
* Assign a label to each forecast based on its accuracy
Let's set the accuracy labels according to the range that the accuracy fits most tightly within, according to the following table.

![image](https://github.com/CodeWorld-X/Weather-Forecast/assets/129016922/602db071-9c39-4b5c-8b0a-7a04e29491ef)

```
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
```

* Append a record to your historical forecast accuracy file.
```
    row=$(tail -1 rx_poc.log )
    year=$(echo $row | cut -d " " -f1)
    month=$(echo $row | cut -d " " -f2)
    day=$(echo $row | cut -d " " -f3)
    hour=$(echo $row | cut -d " " -f4)
```
* Full solution for handling
```
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
    day=$(echo $row | cut -d " " -f3)
    hour=$(echo $row | cut -d " " -f4)
    
    echo -e "$year\t$month\t$day\t$hour\t$today_temp\t$yesterday_fc\t$accuracy\t$accuracy_range" >> historical_fc_accuracy.tsv
```
### 7. Accomplishments
- File raw_data_20230912

  ![image](https://github.com/CodeWorld-X/Weather-Forecast/assets/129016922/837534b1-23ab-4b19-a5e8-b420ea27ba57)

- File temperatures.txt

![image](https://github.com/CodeWorld-X/Weather-Forecast/assets/129016922/c926e4f5-5a9a-45cd-a84c-2983dfb0d4d0)

- File temperatures.txt

![image](https://github.com/CodeWorld-X/Weather-Forecast/assets/129016922/b51fa67b-bec0-4e7a-8fdd-e4bf545c097a)



















