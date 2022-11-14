#! /bin/bash

# [readme](https://github.com/cedar-ave/verint-get-content-data/blob/main/get-files.sh)

communityUrl="" #Example: community.site.com
verintToken=""
galleryId=""

jq -r '.[] | "\(.filename)|\(.title)"' key.json |
    while IFS="|" read -r filename title; do

# This generates a random UUID
uuid=$(od -x /dev/urandom | head -1 | awk '{OFS="-"; print $2$3,$4,$5,$6,$7$8$9}')

for file in $filename; do

echo $file
split -b10M -a3 --numeric-suffixes=100 $file part.
partlist=( part.* )
numparts=${#partlist[@]}
for part in ${partlist[@]}; do
 i=$(( ${part##*.}-100 ))

curl -Si \
 https://$communityUrl/api.ashx/v2/cfs/temporary.json \
  -H 'Rest-User-Token: $verintToken' \
  -F UploadContextId=$uuid \
  -F FileName=$file \
  -F TotalChunks=$numparts \
  -F CurrentChunk="$i" \
  -F 'file=@'$part

done
rm ${partlist[@]}

curl -Si \
  https://$communityUrl/api.ashx/v2/media/$galleryId/files.json \
  -H 'Rest-User-Token: $verintToken' \
  -F ContentType=application/zip \
  -F FileName=$file \
  -F FileUploadContext=$uuid \
  -F "Name=$title"

done

done
