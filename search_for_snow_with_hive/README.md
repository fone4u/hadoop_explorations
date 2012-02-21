http://magnusljadas.wordpress.com/2012/01/29/search-for-snow-with-hadoop-hive/



# Download temperature and precipitation data sets by executing the download script:

´$ ./download_data_from_SMHI.sh´

... or alternatively use the temperature.txt and precipitation.txt found in the data folder.



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

´CREATE TABLE precipitation (
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
STORED AS TEXTFILE;´


# Load temperature and precipitation data into Hive tables

LOAD DATA LOCAL INPATH 'temperature.txt'
OVERWRITE INTO TABLE temperature;

LOAD DATA LOCAL INPATH 'precipitation.txt'
OVERWRITE INTO TABLE precipitation;

# Let's search for snow!


´SELECT year(from_unixtime(unix_timestamp(precipitation.datum, 'yyyyMMdd'))), count(*)
FROM precipitation join temperature on (precipitation.datum = temperature.datum)
AND temperature.TTTM < 0
AND precipitation.PRR > 3
GROUP BY year(from_unixtime(unix_timestamp(precipitation.datum, 'yyyyMMdd')));´


SELECT AVG(sum)
FROM (
SELECT year(from_unixtime(unix_timestamp(precipitation.datum, 'yyyyMMdd'))), count(*) as sum
FROM precipitation join temperature on (precipitation.datum = temperature.datum)
AND temperature.TTTM < 0
AND precipitation.PRR > 3
GROUP BY year(from_unixtime(unix_timestamp(precipitation.datum, 'yyyyMMdd')))
) t;
