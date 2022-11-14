#! /bin/bash

verintToken=""
communityUrl="" #Example: community.site.com

# Removes files from previous runs without complaining if empty
rm -r api
mkdir api
cd api

for type in BlogPosts \
Wikis \
Ideas \
MediaPosts \
Threads \
Users \
Comments ; do

echo ">>> Processing $type"

if [[ $type = BlogPosts ]]
then
urlPath="blogs/posts"
fi

if [[ $type = Ideas ]]
then
urlPath="ideas/ideas"
fi

if [[ $type = MediaPosts ]]
then
urlPath="media/files"
fi

if [[ $type = Threads ]]
then
urlPath="forums/threads"
fi

if [[ $type = Users ]]
then
urlPath="users"
fi

if [[ $type = Wikis ]]
then
urlPath="wikis"
fi

if [[ $type = Comments ]]
then
urlPath="comments"
fi

# Creates new directory for each type
mkdir -p $type
cd $type

# Parts of the API call URL

for ((i=0; ; i+=1)); do

    objects=$(curl -H "Rest-User-Token: $verintToken" -X GET "https://$communityUrl/api.ashx/v2/$urlPath.json?PageIndex=$i&PageSize=100")
    echo "$objects" > $i.json

    match=`jq '.PageIndex' < $i.json`

    # If `PageIndex` value and filename don't match, it breaks
    if [[ "$match" != "$i" ]]; then
    rm -f $i.json
    break
    fi <<< "$objects"

    # Without these filters, Users, Ideas, and Comments don't break and endlessly loop with incrementing `PageIndex` values. The following filters are separate because Ideas fails at the Users filter.

    ## Breaks Users
    if [ $type = "Users" ] && jq -e '.Users | length == 0' >/dev/null; then 
    rm -f $i.json
    break
    fi <<< "$objects"

    ## Breaks Ideas
    if [ $type = "Ideas" ] && jq -e '.Ideas | length == 0' >/dev/null; then 
    rm -f $i.json
    break
    fi <<< "$objects"

    ## Breaks Comments
    if [ $type = "Comments" ] && jq -e '.Comments | length == 0' >/dev/null; then 
    rm -f $i.json
    break
    fi <<< "$objects"

done

# Assembles all JSON files for a type into one
mkdir -p process

for file in *.json; do
jq --arg type "$type" '.[$type][]' $file > $file.tmp && mv $file.tmp process/$file
done

cd process
jq -s . *.json > ../../$type.json

cd ..
cd ..

# Validation
var=$(jq length $type.json)
echo "$type: $var" >> totals.txt

done

# Wiki pages must be called individually from `Wikis.json` because there is no API call for all wiki pages, only metadata on individual wikis.

mkdir WikiPages
cd WikiPages

jq -r '.[] | .Id' ../Wikis.json | while read -r wiki; do 

echo ">>> Wiki id: $wiki"

# Fix line endings
cr=$'\r'
wiki="${wiki%$cr}"

mkdir $wiki
cd $wiki
for ((i=0; ; i+=1)); do

    objects=$(curl -H "Rest-User-Token: $verintToken" -X GET "https://$communityUrl/api.ashx/v2/wikis/${wiki}/pages.json?PageIndex=$i&PageSize=100")
    echo "$objects" > $i.json

    match=`jq '.PageIndex' < $i.json`

    # If `PageIndex` value and filename don't match, it breaks
    if [[ "$match" != "$i" ]]; then
    rm -f $i.json
    break
    fi <<< "$objects"

done

cd ..

# Assembles all wiki pages JSON files into one
mkdir -p process

for dir in $wiki ; do
cd $wiki
for file in *.json; do
jq '.WikiPages[]' $file > $file.tmp && mv $file.tmp ../process/$wiki-$file
done
cd ..
done

done

cd process

jq -s . *.json > ../../WikiPages.json

var=$(jq length ../../WikiPages.json)
echo "Wiki pages: $var" >> ../../totals.txt

# Echo counts of content type items for validation
cat ../../totals.txt
