# Scripts

- [Lists of content types](#content-types) - JSON files of items by content type
- [List of thread tags](#thread-tags) - CSV file of each thread's tag(s)
- [List of files in a group](#files) - CSV file of all files in a group

## Lists of content types

`content.sh` creates one JSON file per content type in a Verint instance. The JSON file includes all items of that content type.

- Blog posts
- Comments
- Ideas
- Media posts (files, videos)
- Threads
- Users
- Wikis
- Wiki pages

### Use case

Feed the JSON files into a Power BI report.

### Benefit

A benefit of extracting this data programmatically via the REST API is that native Verint reporting requires downloading CSVs manually in the UI.

### Prerequisites

- `chocolatey install jq`
- Add token in `verint_token` variable
  - How to get token:
    - Go to community site avatar (top right) > **Settings** > **API Keys** (very bottom) > **Manage application API keys** > **Generate new API key**
    - Base-64 encode `apikey:user.name`

### Notes

Filenames increment by number `($i)`, calling e.g., `PageIndex=7`, `PageIndex=8`, etc. This corresponds to the total number of objects by 100s. For example, in a call to see all thread objects, `PageIndex=7` is the last `PageIndex` if there are 785 total threads. `PageIndex=7` would output to `7.json`. `7.json` would have objects for threads 700-785.

Unfortunately, the script continues to loop when the last `PageIndex` is reached. For example `8.json` has the same content as `7.json` (and therefore the same `PageIndex` in the JSON file). `9.json` also has the `7.json` content, so does `10.json`, and so on forever.

To break the loop, this script compares the `.PageIndex` value in a JSON file to the filename of the JSON file. If they don't match (e.g., `8.json` has a `PageIndex=7`) it breaks.

User `PageIndexes` are assembled 1,10,11,12, etc.; 2,21,22, etc.; 3,4,5,6, etc.

### Troubleshoot

- If `Users.json` won't load in Power BI, there may be blanks in Power BI. Use the column filter arrow in **Query Editor** > **Remove Blanks.**
- Script does not work if a content category has fewer than 100 items due to `rm -f $i.json`.

## List of thread tags

`threadTags.sh` produces a CSV file of each thread's tag(s), if a user has applied a tag to a thread. 

`threadTags.sh` assumes `content.sh` has run and created `api/Threads.json`.

### Prerequisites
- `chocolatey install jq`
- Run `content.sh`

## List of files in a group

`files.sh` generates a CSV of files in a group.

### Prerequisites
- `chocolatey install jq`
- `npm install json2csv`

