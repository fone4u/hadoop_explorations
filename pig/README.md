# Analyzing Every Word Ever Written With Hadoop Pig

(UNDER CONSTRUCTION)

Most things related to Hadoop seem to have an animal connotation attached to it. I can see that just like a real pig, 
Hadoop Pig can be trained to search for precious things buried beneath. Truffels in the case of real pig, BIG DATA 
in the case of Hadoop Pig. A brute force savage animal who can also be delicate and precise. 

One of the most common "Hello World" Pig example is to count words in a text. Let's build on this example, 
and take it to an extreme: to count every word ever written in books between 1800 and 2000.

With the Google N-gram Viewer you can see how common a word has been over the last 200 years. 
In our case we're going to use Google's 1-gram (i.e., individual words or the "unigram") dataset: the occurance of 
1 single word in every book written (scanned by Google) between 1800 and 2000 grouped by year.

* Google NGram Viewer: http://books.google.com/ngrams
* About the datasets: http://books.google.com/ngrams/datasets
* N-gram: http://en.wikipedia.org/wiki/N-gram

Script for downloading data from Google and uploading it into HDFS:

    ./ngram.sh

The script will:

* download 10 zip files from Google (~ 1 GB of data)
* unzip and compress into bz2 (HDFS native format)
* copy data into HDFS

Downloading all the data will take a while - go fetch some coffee! ;-)

 
These are the columns in the 1gram 1800-2000 dataset:

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



