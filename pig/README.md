# Analyzing N-grams with Hadoop Pig

(UNDER CONSTRUCTION)

N-gram: http://en.wikipedia.org/wiki/N-gram

Google NGram Viewer: http://books.google.com/ngrams

Script for downloading data from Google and uploading it into HDFS:

    ./ngram.sh

The script will:

* download 10 zip files from Google (~ 1 GB of data)
* unzip and compress into bz2 (HDFS native format)
* copy data into HDFS

Now go fetch some coffee ;-)

