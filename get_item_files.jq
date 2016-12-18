# Assign identifier and collection to variables for use in final output.
.metadata.identifier as $i |
(.metadata.collection[0]? // .metadata.collection) as $c |

if .is_dark == true then
   ["dark", $c, $i]
else
# Get all non-derivative files that have a file size, and slim down the metadata.
    .files |
    map(select(.source != "derivative") |
        select(.size != null) |
        ["file", $c, $i, "MD5-s\(.size)--\(.md5)", "\($c)/\($i)/\(.name)"])
end |
map(@tsv) | .[]
