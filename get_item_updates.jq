# Assign identifier and collection to variables for use in final output.
.metadata.identifier as $i |
(.metadata.collection[0]? // .metadata.collection) as $c |

if .is_dark != true then
    .files |
    map(select(.source != "derivative") |
        (if .name | endswith("_files.xml") then
             "URL--"
         else
             "MD5-s\(.size)--\(.md5)"
         end) as $key |
        ["file", $c, $i, $key, "\($i)/\(.name)"])
else
    [["dark", $c, $i]]
end |
map(@tsv) | .[]
