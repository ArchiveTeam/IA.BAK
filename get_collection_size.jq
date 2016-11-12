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
        {"name": .name, "size": (.size | tonumber), "format": .format, "md5": .md5}
    else
        {"name": .name, "size": 0, "format": .format, "md5": .md5}
    end

) |

# Get total size of files (per item).
(map(.size) | reduce .[] as $item (0; . + $item)) as $ts |


# Final output (per item).
#{"id": $i, "collection": $c, "total_size": $ts}
#"\($i) \($ts)"
#"\($ts) \($i)"
[$ts, $i] | @tsv