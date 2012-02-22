# 1gram 1800-2000 :  ngram, year, match_count, page_count, volume_count

# Create a small sample from a ~200 mb (compressed) file

    A = LOAD 'hdfs://localhost.localdomain/tmp/books/ngrams/books/googlebooks-eng-all-1gram-20090715-0.csv.bz2' 
    USING PigStorage('\t') AS (ngram, year, match_count, page_count, volume_count);
    B = SAMPLE A 0.001;
    STORE B INTO 'hdfs://localhost.localdomain/tmp/ngram_sample' USING PigStorage();



# Load the whole data set using wildcard (*) - this will take hours to process on a single node setup

    A = LOAD 'hdfs://localhost.localdomain/tmp/books/ngrams/books/googlebooks-eng-all-1gram-20090715-*.csv.bz2'
    USING PigStorage('\t') AS (ngram, year, match_count, page_count, volume_count);

    A = LOAD 'hdfs://localhost.localdomain/tmp/ngram_sample' USING PigStorage() AS (ngram, year, match_count, page_count, volume_count);

# Find out what the 100 most popular words are 

    B = GROUP A BY ngram;
    C = FOREACH B GENERATE group AS ngram, SUM(A.match_count) AS cnt;
    D = ORDER C BY cnt DESC;
    E = LIMIT D 100;


Look at the results, our script is case sensitive:

    (",2.1396850115E10)
    (the,1.8399669358E10)
    (was,2.127747161E9)
    ...
    (The,2.111040694E9)
    (as,2.055536341E9)")")


In order to make it case insensitive, we need to do something.

