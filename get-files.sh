#! /bin/bash

communityUrl="" #Example: community.site.com
verintToken=""
groupId=""

for ((i=0; ; i+=1)); do

    objects=$(curl -H "Rest-User-Token: $verintToken" -X GET "https://$communityUrl/api.ashx/v2/media/$groupId/files.json?PageIndex=$i&PageSize=100")
    echo "$objects" > $i.json
    match=`jq '.PageIndex' < $i.json`

    # If PageIndex value and filename don't match, it breaks
    if [[ "$match" != "$i" ]]; then
    rm -f $i.json
    break
    fi <<< "$objects"
done

# Assemble all .json files into one
jq -s . *.json > GroupMediaPosts.json

# Extract desired fields from JSON file
jq '[.[] | .MediaPosts[] | {Title: .Title, Url: .Url, Name: .File.FileName, FileId: .Id}]' GroupMediaPosts.json > files.json

# Turn into CSV
json2csv -i files.json -f Title,Url,Name,FileId > files-1.csv

# Duplicate FileName column for processing
awk 'FS=OFS="," {print $1, $2, $3, $3, $4}' files-1.csv > files-2.csv

# Put file ending (everything until last \. - greedy) in new column
## .File.ContentType produced by the API was often inaccurate, so this script just splits off the actual filename ending into its own column
awk -F, -v OFS=, '{sub(/.*\./,"\"",$4); print $1, $2, $3, $4, $5}'  files-2.csv > files-3.csv
