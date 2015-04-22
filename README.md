Client scripts for
<http://archiveteam.org/index.php?title=INTERNETARCHIVE.BAK/git-annex_implementation>

You can use git-annex commands by hand, if you prefer, but the `iabak`
script automates several things for you.

Clone this git repository to somewhere that has a lot of disk space,
and run the `iabak` script to get started.

You can stop running it once it's downloaded enough. Just hit ctrl-C at any
time.

This script has been tested on:

* Linux (any not too minimal distribution)
* OSX

## care and feeding of your backup

To be sure that your backup still exists and is still in good shape,
you shoud periodically run either `iabak` or `iabak-cronjob`. Either
of these will check back in and verify that your repo exists. The
difference is that `iabak-cronjob` avoids downloading any more data
from the IA, and logs to `iabak-cronjob.log`.

We recommend setting up a cron job that runs one of these at least once per
week, so we can notice when repositories go missing or develop problems.

For example, to run it at 10:30am on Mondays, put this in crontab:

	30 10 * * 1 /path/to/IA.BAK/iabak-cronjob

## checking out additional shards

Running `iabak` will check out one shard of the IA at a time. If you have
more disk space, you may want to add additional shards. To do so, run the
`checkoutshard` script, passing it the name of a shard, such as "shard3".
See the `repolist` file for a list of shards and their status.

Once you have multiple shards checked out, the next time you run iabak,
it will process all the shards.

## flag files

You can touch these files in the IA.BAK directory to control iabak.

NOSHUF	
	Prevents shuffling files before downloading.
NOMORE	
	Prevents iabak from checking out additional shards as existing
	shards complete.

Also, these files in the IA.BAK directory can have values written
to them to tune its behavior.

FSCKTIMELIMIT
	Limits how much time is spent verifying checksums of
	files in your backup. The default is "5h", which means
	it will spend up to 5 hours per shard per run of
	iabak/iabak-cronjob. Feel free to set this to a smaller time
	limit like "1h" or "30m".

	The goal is to verify the checksum of each file
	in your backup once per month. If it's interrupted by this time
	limit, or just by your ctrl-c, it will pick up next time where it
	left off. Once it's verified all files, it will avoid doing
	any more checksumming until the next month.

## tuning resource usage

So you want to back up part of the IA, but don't want this to take over
your whole disk or internet pipe? Here's some tuning options you can use..
Run these commands in git repos like IA.BAK/shard1 etc.

* git config annex.diskreserve 200GB

  This will prevent git-annex from using up the last 200gb of your disk.
  Adjust to suite. This is prompted for the first time you run iabak, and it
  is automatically propigated to each new shard.

* git config annex.web-options=--limit-rate=200k

  This will limit wget/curl to downloading at 200 kb/s. Adjust to suite. 

## instructions for earlier users

If you cloned shard1 by hand before, here's how to convert to managing it
with iabak.

1. Clone this repo to the same drive you cloned shard1 to before.
2. Stop any running git-annex process.
3. Move the shard1 repo to IA.BAK/shard1
4. Go to IA.BAK, and run ./iabak
