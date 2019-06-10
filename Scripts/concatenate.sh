#!/bin/bash
# This bash script adds the name of csv files to the beginning of each row in the csv file, creating a column with a file "ID"
# It then concatenates the files.
# It only keeps the header of the first file, and names the new column "Cell".
# Store all files to process as csv files with headers in the directory "Files_to_analyze"
# To run, type: $ sh concatenate.sh

echo "... File concatenation begun"

cp -r Files_to_analyze Processing

first=1
for cell in Processing/Files_to_analyze/*
do
        fileID=$cell
        fileID=$(echo $fileID | sed 's/Processing\/Files_to_analyze\///' | sed 's/.csv//')
        if [ $first -eq 1 ]
        then
                head -n 1 $cell | sed "s/^/Cell,/" > Concatenated_to_analyze.csv
                tail -n +2 $cell | sed "s/^/$fileID,/" >> Concatenated_to_analyze.csv
                first=2
                echo $fileID.csv processed first
        else
                tail -n +2 $cell | sed "s/^/$fileID,/" >> Concatenated_to_analyze.csv
                echo $fileID.csv processed
        fi
done

echo "... All files processed"
echo "... Outputting head of concatenated file:"
head Concatenated_to_analyze.csv

echo "... Removing temp files"
rm -r Processing/Files_to_analyze/

echo "... Concatenation complete"
