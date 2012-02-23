# Analyzing N-grams with Hadoop Pig


Most things related to Hadoop seem to have an animal connotation attached to it. I don't 
know the reason for calling it Pig, but I just like a real pig, Hadoop Pig can be trained to 
search for precious things buried beyond our ordinary reach. Truffels for real pig, data for Hadoop Pig.
A brute force animal who can also be delicate. Enough!

On of the most common "Hello World" Pig example is to count words in a text. Let's build on this example 
but take it to the ultimate extreme - to count every word ever written (or scanned by Google) from 1800 to 2000.




(UNDER CONSTRUCTION)

N-gram: http://en.wikipedia.org/wiki/N-gram

Google NGram Viewer: http://books.google.com/ngrams

Script for downloading data from Google and uploading it into HDFS:

    ./ngram.sh

The script will:

* download 10 zip files from Google (~ 1 GB of data)
* unzip and compress into bz2 (HDFS native format)
* copy data into HDFS

Downloading all the data will take awhile - go fetch some coffee! ;-)

 
Columns in the 1gram 1800-2000 dataset

    ngram, year, match_count, page_count, volume_count




Create a small sample from a ~200 mb (compressed) file

    A = LOAD 'hdfs://localhost.localdomain/tmp/books/ngrams/books/googlebooks-eng-all-1gram-20090715-0.csv.bz2' 
    USING PigStorage('\t') AS (ngram, year, match_count, page_count, volume_count);
    B = SAMPLE A 0.001;
    STORE B INTO 'hdfs://localhost.localdomain/tmp/ngram_sample' USING PigStorage();



Load the whole data set using wildcard (*) - this will take hours to process on a single node setup

    A = LOAD 'hdfs://localhost.localdomain/tmp/books/ngrams/books/googlebooks-eng-all-1gram-20090715-*.csv.bz2'
    USING PigStorage('\t') AS (ngram, year, match_count, page_count, volume_count);

    A = LOAD 'hdfs://localhost.localdomain/tmp/ngram_sample' USING PigStorage() AS (ngram, year, match_count, page_count, volume_count);

Find out what the 100 most popular words are 

    B = GROUP A BY ngram;
    C = FOREACH B GENERATE group AS ngram, SUM(A.match_count) AS cnt;
    D = ORDER C BY cnt DESC;
    E = LIMIT D 100;


Look at the results, the script is case sensitive:

    (",2.1396850115E10)
    (the,1.8399669358E10)
    (was,2.127747161E9)
    ...
    (The,2.111040694E9)
    (as,2.055536341E9)")")


In order to make it case insensitive, we need to do something.



