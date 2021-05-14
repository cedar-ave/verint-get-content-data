#! /bin/bash

# This script gets Telligent content type objects through the Telligent API as JSON for analytics purposes.
# Final JSON files are in `{directory of this script}/api`.
# Prerequisites: Install `jq` and put your Telligent token in the script.
  ## How to get token:
     ### Go to your Telligent avatar (top right) > Settings > API Keys (very bottom) > Manage application API keys > Generate new API key.
     ### Base-64 encode `apikey:username`.

telligent_token="TOKEN"

# Removes files from previous runs without complaining if empty
rm -r api/* 2>/dev/null

mkdir -p api
cd api

for type in \
BlogPosts \
Ideas \
MediaPosts \
Threads \
Users \
WikiPages \
Comments ; do

## Creates new directory for each type
mkdir $type
cd $type

# Parts of the API call URL

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

if [[ $type = WikiPages ]]
then
urlPath="wikis/13/pages"
fi

if [[ $type = Comments ]]
then
urlPath="comments"
fi

# Calls URL by 100s until all objects are retrieved (with no duplicates), then breaks

for ((i=0; ; i+=1)); do

    objects=$(curl -H "Rest-User-Token: $telligent_token" -X GET "https://company.telligenthosting.net/api.ashx/v2/$urlPath.json?PageIndex=$i&PageSize=100")
    echo "$objects" > $i.json

    match=`jq '.PageIndex' < $i.json`

    # If PageIndex value and filename don't match, it breaks
    if [[ "$match" != "$i" ]]; then
    rm -f $i.json
    break
    fi <<< "$objects"

    # Without these filters, Users and Ideas don't break and endlessly loop with incrementing PageIndex values. The following filters are separate because Ideas fails at the Users filter.

    # Breaks Users
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

# Assembles all .json files for a type into one
jq -s . *.json > $type.json

mv $type.json ../
cd ..

done

