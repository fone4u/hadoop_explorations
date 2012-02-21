# Search for Snow with Hadoop  Hive

*Here's the original blog post:* http://magnusljadas.wordpress.com/2012/01/29/search-for-snow-with-hadoop-hive/

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

## Let's get some raw data!

Open the terminal and execute the prepared download script:

    $ ./download_data_from_SMHI.sh

*... or alternatively use the temperature.txt and precipitation.txt found in the problem_solving_with_hadoop/search_for_snow_with_hive/data folder.*


The columns in the temperature and precipitation data sets looks like this:

    DATUM YearMonthDay YYYYMMDD
    TT1 temperature at 06 UTC
    TT2 temperature at 12 UTC
    TT3 temperature at 18 UTC
    TTX(1) daily max-temperature
    TTN(1) daily min-temperature
    TTTM(2) daily mean temperature
    -999.0 missing value

    DATUM YearMonthDay YYYYMMDD
    PES(1) ground snow/ice code
    PRR(2) precipitation mm
    PQRR(3) quality code
    PRRC1(4) precipitation type
    PRRC2(4) precipitation type
    PRRC3(4) precipitation type
    PSSS(5) total snow depth cm
    PWS(3) thunder, fog or aurora borealis code
    -999.0 missing value

## Create temperature and precipitation Hive tables

Now we have properly formatted raw data ready to import into Hive. Let's boot up hive and create some tables!

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


## Load temperature and precipitation data into Hive tables

Assuming you started hive in the same directory as the temperature.txt and precipitation.txt files exist:

    LOAD DATA LOCAL INPATH 'temperature.txt'
    OVERWRITE INTO TABLE temperature;

    LOAD DATA LOCAL INPATH 'precipitation.txt'
    OVERWRITE INTO TABLE precipitation;

## Let's search for snow!

With our raw data loaded into hive, we're ready to search. Let’s define a snowy day as a day that has a temperature below 0 degrees Celsius (freezing) with a precipitation of more than 3 mm (approximately 30 mm snow).

- Number of snow days grouped by year
* TTTM Temperature < 0 degrees Celsius
* PRR Percipitation > 3 mm (approximately 3 cm snow)


    SELECT year(from_unixtime(unix_timestamp(precipitation.datum, 'yyyyMMdd'))), count(*)
    FROM precipitation join temperature on (precipitation.datum = temperature.datum)
    AND temperature.TTTM < 0
    AND precipitation.PRR > 3
    GROUP BY year(from_unixtime(unix_timestamp(precipitation.datum, 'yyyyMMdd')));

Hive supports subqueries, let’s calculate the average number of snow days:


    SELECT AVG(sum)
    FROM (
    SELECT year(from_unixtime(unix_timestamp(precipitation.datum, 'yyyyMMdd'))), count(*) as sum
    FROM precipitation join temperature on (precipitation.datum = temperature.datum)
    AND temperature.TTTM < 0
    AND precipitation.PRR > 3
    GROUP BY year(from_unixtime(unix_timestamp(precipitation.datum, 'yyyyMMdd')))
    ) t;

