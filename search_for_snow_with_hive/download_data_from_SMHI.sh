#!/bin/bash

# The Swedish national weather service SMHI provides the data we need: 
# daily temperature and precipitation data from 1961 to 1997, 
# gathered at a weather station about 60 km from where I live.

clean() {
    infile=$1
    outfile=$2
    
    # Removed header information from infile
    sed -i 1,+7d $infile 

    # Replace leading and trailing spaces and replace spaces between fields with commas
    cat $infile | sed -e 's/^[ \t]*//' | sed 's/[[:space:]]\+/,/g' > $outfile
}

temperature_infile=SMHI_day_temperature_clim_9720.txt
precipitation_infile=SMHI_day_precipitation_clim_9720.txt

# Download
wget http://data.smhi.se/met/climate/time_series/day/temperature/${temperature_infile}
wget http://data.smhi.se/met/climate/time_series/day/precipitation/${precipitation_infile}

# Cleanup the files for easier import to Hive
clean $temperature_infile "temperature.txt"
clean $precipitation_infile "precipitation.txt"
