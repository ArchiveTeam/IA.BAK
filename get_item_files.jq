# Assign identifier and collection to variables for use in final output.
.metadata.identifier as $i |
.metadata.collection as $c |

# Filter out any items that do not have files metadata.
select(.files != null) |

# Get all non-derivative files that have a file size, and slim down the metadata.
.files |
map(
    select(.source != "derivative") |
    # if case for catching files with size=null (i.e. files.xml).
    if .size != null then
        {"url": "https://archive.org/download/\($i)/\(.name)", "size": (.size | tonumber), "collection": $c[0], "md5": .md5}
    else
        {"url": "https://archive.org/download/\($i)/\(.name)", "size": 0, "collection": $c[0], "md5": .md5}
    end
) |
map([.md5, .size, .collection, .url]) | map(@tsv) | .[]
