# Get data for each content type in Verint

This script creates a single JSON file for each content type in a Verint instance. A use case is to feed the JSON files into a Power BI report. A benefit of extracting this data programmatically via the REST API is that native Verint reporting requires downloading CSVs manually in the UI.

## Prerequisites

- `chocolatey install jq`
- Add token in `verint_token` variable
  - How to get token:
    - Go to community site avatar (top right) > **Settings** > **API Keys** (very bottom) > **Manage application API keys** > **Generate new API key**
    - Base-64 encode `apikey:user.name`

## Notes

Filenames increment by number `($i)`, calling e.g., `PageIndex=7`, `PageIndex=8`, etc. This corresponds to the total number of objects by 100s. For example, in a call to see all thread objects, `PageIndex=7` is the last `PageIndex` if there are 785 total threads. `PageIndex=7` would output to `7.json`. `7.json` would have objects for threads 700-785.

Unfortunately, the script continues to loop when the last `PageIndex` is reached. For example `8.json` has the same content as `7.json` (and therefore the same `PageIndex` in the JSON file). `9.json` also has the `7.json` content, so does `10.json`, and so on forever.

To break the loop, this script compares the `.PageIndex` value in a JSON file to the filename of the JSON file. If they don't match (e.g., `8.json` has a `PageIndex=7`) it breaks.

User `PageIndexes` are assembled 1,10,11,12, etc.; 2,21,22, etc.; 3,4,5,6, etc.

## Troubleshoot

- If `Users.json` won't load in Power BI, there may be blanks in Power BI. Use the column filter arrow in **Query Editor** > **Remove Blanks.**
- Script does not work if a content category has fewer than 100 items due to `rm -f $i.json`.