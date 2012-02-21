#!/bin/bash

server=http://commondatastorage.googleapis.com
path=/books/ngrams/books/


for i in {0..9}; do
    file=googlebooks-eng-all-1gram-20090715-${i}.csv
    wget ${server}${path}${file}.zip
    unzip ${file}.zip
    bzip2 ${file}
    hadoop dfs -copyFromLocal ${file}.bz2 ${path}${file}.bz2
    rm ${file}* 
done
