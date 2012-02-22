A = LOAD 'hdfs://localhost.localdomain/tmp/books/ngrams/books/googlebooks-eng-all-1gram-20090715-0.csv.bz2' 
USING PigStorage('\t') AS (ngram, year, match_count, page_count, volume_count);
B = SAMPLE A 0.001;
STORE B INTO 'hdfs://localhost.localdomain/tmp/ngram_sample' USING PigStorage();

export HADOOP_OPTS="$HADOOP_OPTS -Djava.io.tmpdir=/tmp"


A = LOAD 'hdfs://localhost.localdomain/tmp/ngram_sample' USING PigStorage() AS (ngram, year, match_count, page_count, volume_count);
B = GROUP A BY ngram;
C = FOREACH B GENERATE group AS ngram, SUM(A.match_count) AS cnt;
D = ORDER C BY cnt DESC;
