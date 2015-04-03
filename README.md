Client scripts for
<http://archiveteam.org/index.php?title=INTERNETARCHIVE.BAK/git-annex_implementation>

You can use git-annex commands by hand, if you prefer, but the `iabak`
script automates several things for you.

Clone this git repository to somewhere that has a lot of disk space,
and run the `iabak` script to get started.

Currently, `iabak` handles initial download of data, but not long-term
maintenance tasks. You'll want to stop running it once it's downloaded
enough. Just hit ctrl-C at any time.

## checking out additional shards

Running `iabak` will check out one shard of the IA. If you have more disk
space, you may want to add additional shards later. To do so, run the
`checkoutshard` script, passing it the name of a shard, such as "shard2".
See the `repolist` file for a list of shards and their status.

Once you have multiple shards checked out, the next time you run iabak,
it will process all the shards.

## instructions for earlier users

If you cloned shard1 by hand before, here's how to convert to managing it
with iabak.

1. Clone this repo to the same drive you cloned shard1 to before.
2. Stop any running git-annex process.
3. Move the shard1 repo to IA.BAK/shard1
4. Go to IA.BAK, and run ./iabak
