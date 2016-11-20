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
you shoud periodically run either `iabak` or `iabak-cronjob` or
both. Either of these will check back in and verify that your repo
exists. The difference is that `iabak-cronjob` avoids downloading any
more data from the IA, avoids verifying the checksums of the files you
are storing, and logs to `iabak-cronjob.log`.

We recommend setting up a cron job that runs one of these at least once per
week, so we can notice when repositories go missing or develop problems.

For example, to run it at 10:30am on Mondays, put this in crontab:

	30 10 * * 1 /path/to/IA.BAK/iabak-cronjob

The `install-fsck-service` installs a systemd timer or cron job that will run
`iabak-cronjob` once a day. This is now set up automatically the first time
`iabak` is run.

## checking out additional shards

Running `iabak` will check out one shard of the IA at a time. Once it
finishes the current shard, if you have more disk space available, it will
find and check out another shard.

To manually check out a particular shard, you can run the
`checkoutshard` script, passing it the name of a shard, such as "shard3".
See the `repolist` file for a list of shards and their status.

Once you have multiple shards checked out, the next time you run `iabak`,
it will process all them.

## flag files

You can touch these files in the IA.BAK directory to control `iabak`.

* `NOSHUF`
	Prevents shuffling files before downloading.
* `NOMORE`
	Prevents `iabak` from checking out additional shards as existing
	shards complete.

Also, these files in the IA.BAK directory can have values written
to them to tune its behavior.

* `ANNEXGETOPTS`
	Options passed to `git annex get`.
	This is useful to enable concurrent downloads of multiple files.
	For example "-J10" for concurrent downloads.
* `FSCKTIMELIMIT`
	Limits how much time is spent verifying checksums of
	files in your backup. The default is "5h", which means
	it will spend up to 5 hours per shard per run of `iabak`.
	Feel free to set this to a smaller time limit like "1h" or "30m".
	(Note that `iabak-cronjob` does not perform these expensive fscks.)

	The goal is to verify the checksum of each file
	in your backup once per month. If it's interrupted by this time
	limit, or just by your ctrl-c, it will pick up next time where it
	left off. Once it's verified all files, it will avoid doing
	any more checksumming until the next month.

## tuning resource usage

So you want to back up part of the IA, but don't want this to take over
your whole disk or internet pipe? Here's some tuning options you can use..
Run these commands in git repos like IA.BAK/shard1, IA.BAK/shard2, etc.

* `git config annex.diskreserve 200GB`
	This will prevent git-annex from using up the last 200gb of your disk.
	Adjust to suit. This is prompted for the first time you run `iabak`, and it
	is automatically propigated to each new shard.

* `git config annex.web-options --limit-rate=200k`
	This will limit wget/curl to downloading at 200 kb/s. Adjust to suit.

	Note that if concurrent downloads are enabled, each download thread will
	use up to this rate limit.

## instructions for earlier users

If you cloned shard1 by hand before, here's how to convert to managing it
with iabak.

1. Clone this repo to the same drive you cloned shard1 to before.
2. Stop any running git-annex process.
3. Move the shard1 repo to IA.BAK/shard1
4. Go to IA.BAK, and run `./iabak`

## FAQ

* `Can I run this on BSD?`
	Not without some serious work. You'll need /bin/bash, GNU awk, and possibly other things I can't think of off the top of my head. Join the IRC channel and chat with other BSD users; they may have more up-to-date information.

* `Can I store the backups on an NFS or SMB filesystem?`
	Kinda. If you're using SMB then you're on your own (but do send us a pull request). If you're using NFS then you'll have to install git-annex manually (as the default install tarball uses symlinks), and you'll have to add "-c annex.sshcaching=false" to the ANNEXGETOPTS file so that git-annex doesn't try to create unix sockets on your NFS filesystem.

* `I keep seeing this error message from git-annex: "Unable to access these remotes: web"; what do I do?`
	This indicates that a file used to exist on archive.org but has since been hidden for one reason or another. The message will also list which git remotes are believed to contain the file; if remotes other than the web remote are listed then you could contact that user and arrange for access to the file. The best way to do this is to set up mutual SSH access.

* `What do I do when git-annex tells me "verification of content failed"?`
	This means that git-annex tried to verify the content of a file it has downloaded, but failed to do so. Most likely the file has changed since we first added it to the shard. This is most common with torrent files and the *_meta.xml files.
