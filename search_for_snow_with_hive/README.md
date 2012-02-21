http://magnusljadas.wordpress.com/2012/01/29/search-for-snow-with-hadoop-hive/

I don’t know how I ended up becoming the head of our local community 
association. Anyhow, I’m now responsible for laying out next year’s 
budget. Most of our expenses seem to be fixed from one year to another, 
but then there’s the expense for the snow removal service. This year, 
no snow. Last year, most snow on record in 30 years! How do you budget 
for something as volatile as snow? I need more data!

Instead of just googling the answer, we’re going to fetch some raw 
data and feed it into Hadoop Hive.

The Swedish national weather service SMHI provides the data we need: 
daily temperature and precipitation data from 1961 to 1997, gathered 
at a weather station about 60 km from where I live.

# Let's get some raw data

Open the terminal and execute the prepared download script:

    $ ./download_data_from_SMHI.sh

... or alternatively use the *temperature.txt* and *precipitation.txt* found in the *problem_solving_with_hadoop/search_for_snow_with_hive/data* folder.



# Create temperature and precipitation Hive tables

    $ hive

    CREATE TABLE temperature (
    DATUM STRING,
    TT1 DOUBLE,
    TT2 DOUBLE,
    TT3 DOUBLE,
    TTN DOUBLE,
    TTTM DOUBLE,
    TTX DOUBLE)
    ROW FORMAT DELIMITED
    FIELDS TERMINATED BY ','
    STORED AS TEXTFILE;

    CREATE TABLE precipitation (
    DATUM STRING,
    PES DOUBLE,
    QRR DOUBLE,
    PRR DOUBLE,
    PRRC1 DOUBLE,
    PRRC2 DOUBLE,
    PRRC3 DOUBLE,
    PSSS DOUBLE,
    PWS DOUBLE)
    ROW FORMAT DELIMITED
    FIELDS TERMINATED BY ','
    STORED AS TEXTFILE;


# Load temperature and precipitation data into Hive tables

    LOAD DATA LOCAL INPATH 'temperature.txt'
    OVERWRITE INTO TABLE temperature;

    LOAD DATA LOCAL INPATH 'precipitation.txt'
    OVERWRITE INTO TABLE precipitation;

# Let's search for snow!


    SELECT year(from_unixtime(unix_timestamp(precipitation.datum, 'yyyyMMdd'))), count(*)
    FROM precipitation join temperature on (precipitation.datum = temperature.datum)
    AND temperature.TTTM < 0
    AND precipitation.PRR > 3
    GROUP BY year(from_unixtime(unix_timestamp(precipitation.datum, 'yyyyMMdd')));


    SELECT AVG(sum)
    FROM (
    SELECT year(from_unixtime(unix_timestamp(precipitation.datum, 'yyyyMMdd'))), count(*) as sum
    FROM precipitation join temperature on (precipitation.datum = temperature.datum)
    AND temperature.TTTM < 0
    AND precipitation.PRR > 3
    GROUP BY year(from_unixtime(unix_timestamp(precipitation.datum, 'yyyyMMdd')))
    ) t;

