#! /bin/bash

verintToken=""
communityUrl=""
groupNameA=""
groupNameB="" #Example: `Product Group A`

for ((i=0; ; i+=1)); do
    objects=$(curl -H "Rest-User-Token: $verintToken" -X GET "https://$communityUrl/api.ashx/v2/ideas/ideas.json?PageIndex=$i&PageSize=100")
    echo "$objects" > $i.json
    if jq -e '.Ideas | length == 0' >/dev/null; then 
       break
    fi <<< "$objects"
    jq -r '.Ideas[] | .Challenge.Group.Name + "," + "\"" + .Name + "\"" + "," + .CurrentStatus.Author.DisplayName + "," + .Category.Name + "," + .CurrentStatus.Status.Name + "," + .CreatedDate + "," + (.string + (.TotalVotes|tostring)) + "," + (.string + (.YesVotes|tostring)) + "," + (.string+ (.NoVotes|tostring)) + "," + .Url' <<< "$objects" > $i.json
done

cat *.json > ideas-prelim.csv
sed -i 's|,,|,null,|g' ideas-prelim.csv

# Filter out other groups' ideas by printing row only if first column is DOS group
awk -F, '$1 == "$groupNameA" || $1 == "groupNameB"' ideas-prelim.csv > ideas.csv

# Header row
sed -i 1i "Group,Title,User,Category,Status,CreatedDate,TotalVotes,YesVotes,NoVotes,URL" ideas.csv
