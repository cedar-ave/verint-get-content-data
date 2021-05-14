# telligent-get-content-data
> Get data about content in a Telligent instance via the Telligent API.

This script gets Telligent content type objects through the Telligent API as JSON for analytics purposes.

Final JSON files are in `{directory of this script}/api`.

Prerequisites: Install `jq` and put your Telligent token in the script. How to get token:
- Go to your Telligent avatar (top right) > Settings > API Keys (very bottom) > Manage application API keys > Generate new API key.
- Base-64 encode `apikey:username`.

Filenames increment by number ($i), calling e.g. PageIndex=7, PageIndex=8, etc. This corresponds to the total number of objects by 100s. For example, in a call to see all thread objects, PageIndex=7 is the last PageIndex if there are 785 total threads. PageIndex=7 would output to 7.json. 7.json would have objects for threads 700-785.

Unfortunately the script continues to loop when the last PageIndex is reached. For example 8.json has the same content as 7.json (and therefore the same PageIndex in the .json). 9.json also has the 7.json content, so does 10.json, and so on forever.

To break the loop, this script compares the .PageIndex value in a .json file to the filename of the .json file. If they don't match (e.g., 8.json has a PageIndex=7) it breaks.

### Notes
- User PageIndexes are assembled 1,10,11,12, etc.; 2,21,22, etc.; 3,4,5,6, etc.
- Unlike the other media types, due to limitations in the Telligent API, WikiPages cURL only returns one wiki at a time.

Script does not work if a content category has fewer than 100 items, due to `rm -f $i.json`.
