#!/bin/sh

# Emits last modified datestamps from update site db.xml.gz headers.
# Output format is seconds since the epoch, one update site per line.

for repo in \
  update.imagej.net       \
  update.fiji.sc          \
  sites.imagej.net/Java-8
do
  result=$(curl -Ifs "https://$repo/db.xml.gz" | grep '^Last-Modified:')
  datestamp=${result#*, }
  echo "$repo = $datestamp"
done
