#!/bin/bash

echo Starting Redis

redis-server --daemonize yes

DOWNLOADED_FILE=/opt/ade/data.txt
#FILE_TO_DOWNLOAD=http://deepyeti.ucsd.edu/jianmo/amazon/categoryFilesSmall/Grocery_and_Gourmet_Food_5.json.gz
FILE_TO_DOWNLOAD=http://deepyeti.ucsd.edu/jianmo/amazon/categoryFilesSmall/Gift_Cards_5.json.gz

echo Downloading Data Set $FILE_TO_DOWNLOAD to $DOWNLOADED_FILE.gz

# FROM https://nijianmo.github.io/amazon/index.html
wget -q -O $DOWNLOADED_FILE.gz $FILE_TO_DOWNLOAD
gzip -d $DOWNLOADED_FILE.gz

echo Sanitizing Downloaded Set


# Sanitize Quotes
sed -i 's/\"/\\\"/g' $DOWNLOADED_FILE

# Add Redis Protocol Wrapper to Each Line for Mass Insertion
# sed -i 's/\(.*\)/*3\r\n$3\r\nLPUSH\r\n$3\r\DATA\r\n$5\r\n\1\r\n/' $DOWNLOADED_FILE
sed -i 's/\(.*\)/LPUSH DATA "\1"/' $DOWNLOADED_FILE

# Ensure line endings are set
dos2unix $DOWNLOADED_FILE

echo Importing data into redis

cat $DOWNLOADED_FILE | redis-cli

echo Showing Redis Logs

redis-cli monitor
