# Analyzing Every Word Ever Written With Hadoop Pig

Most things related to Hadoop seem to have an animal connotation. I can see that just like a real pig, 
Hadoop Pig can be trained to search for precious things buried beneath - truffels in the case of a real pig, BIG DATA 
in the case of Hadoop Pig. The pig is a brute force animal who can also be delicate and precise. 

One of the most common "Hello World" Pig example is the count words of a text. Let's build on this example, 
and take it to an extreme: to count every word ever written in books between 1800 and 2000!

With the Google N-gram Viewer you can see how common a word has been over the last 200 years. 
In our case we're going to use Google's 1-gram (i.e., individual words or the "unigram") dataset: the occurance of 
single words in books written (and scanned by Google) between 1800 and 2000, grouped by year.

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



If you're running on a single node, or like me, running on a virtual machine on one kernel on an old Mac, you may want to create a reduced dataset in order to get feedback faster and speed up development in general.
Create a small sample from a ~200 mb (compressed) file


Most pig scrips start with a LOAD statement. A set of files can be loaded by using wildcards or glob notation. Pig can load bz2 compressed files automatically.

    A = LOAD 'hdfs://localhost.localdomain/tmp/books/ngrams/books/googlebooks-eng-all-1gram-20090715-0.csv.bz2' 
    USING PigStorage('\t') AS (ngram:chararray, year:int, match_count:int, page_count:int, volume_count:int);


Sample:

    B = SAMPLE A 0.001;

Or

    B = LIMIT A 10000;
Or

    B = FILTER A BY year == '1984';

The STORE command stores the output in a file:

    STORE B INTO 'hdfs://localhost.localdomain/tmp/1gram_sample' USING PigStorage();



Load the whole data set using wildcard (*) - this will take hours to process on a single node setup

    A = LOAD 'hdfs://localhost.localdomain/tmp/books/ngrams/books/googlebooks-eng-all-1gram-20090715-*.csv.bz2'
    USING PigStorage('\t') AS (ngram:chararray, year:int, match_count:int, page_count:int, volume_count:int);

Load the sample

    A = LOAD 'hdfs://localhost.localdomain/tmp/1gram_sample_10000' 
    USING PigStorage() AS (ngram, year, match_count, page_count, volume_count);

Let's find out what the 100 most popular words are: 

    B = GROUP A BY ngram;
    C = FOREACH B GENERATE group AS ngram, SUM(A.match_count) AS cnt;
    D = ORDER C BY cnt DESC;
    E = LIMIT D 100;


Look at the results, the query is case sensitive:

    (",2.1396850115E10)
    (the,1.8399669358E10)
    (was,2.127747161E9)
    ...
    (The,2.111040694E9)
    (as,2.055536341E9)")")


In order to make it case insensitive, we can use a FOREACH filter with the built in function LOWER.

    A = LOAD 'hdfs://localhost.localdomain/tmp/books/ngrams/books/googlebooks-eng-all-1gram-20090715-*.csv.bz2'
    USING PigStorage('\t') AS (ngram:chararray, year:int, match_count:int, page_count:int, volume_count:int);
    B = FOREACH B GENERATE LOWER(ngram) AS ngram, year, match_count, page_count, volume_count;
    C = GROUP B BY ngram;
    D = FOREACH C GENERATE group AS ngram, SUM(B.match_count) AS cnt;
    E = ORDER C BY cnt DESC;
    F = LIMIT E 100;


Something's not quite right here 1.8399669358E10 + 2.111040694E9 = 20510710052.0 and not 2.0606096351E10. How come?

    ...
    (the,2.0606096351E10)
    ...


Instead of dumping the result to the terminal we could store the output in a compressed file. By appending ".bz2" to a file, Pig will automatically store compressed output.

 F = FOREACH E GENERATE LOWER(ngram) AS ngram, year, match_count, page_count, volume_count;
     STORE C INTO 'hdfs://localhost.localdomain/tmp/<my output file>.bz2' USING PigStorage();
