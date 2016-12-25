module IABak where

import Propellor.Base
import qualified Propellor.Property.Apt as Apt
import qualified Propellor.Property.Git as Git
import qualified Propellor.Property.Cron as Cron
import qualified Propellor.Property.File as File
import qualified Propellor.Property.Apache as Apache
import qualified Propellor.Property.User as User
import qualified Propellor.Property.Ssh as Ssh
import qualified Propellor.Property.Sudo as Sudo

repo :: String
repo = "https://github.com/ArchiveTeam/IA.BAK/"

userrepo :: String
userrepo = "git@gitlab.com:archiveteam/IA.bak.users.git"

adminList :: Property DebianLike
adminList = propertyList "iabak admins" $ props
	& IABak.admin (User "joey") "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICfFntnesZcYz2B2T41ay45igfckXRSh5uVffkuCQkLv joey@darkstar"
	& IABak.admin (User "db48x") "ssh-rsa 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 db48x@anglachel"
	& IABak.admin (User "db48x") "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJQkqIgZ7D8WHW5Y3o+fpZC/4xtv/3IQrORJrTPCt7KY db48x@erebor"
	& IABak.admin (User "db48x") "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAAMFoRm8trenxhZWe6dDEB2c6POPbsPfM5ArZep9lU+ db48x@anglachel"
	& IABak.admin (User "hcross") "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIP5OhU2Lita9RdjPkX9N0w9wZnmVlednUDEx24bVn4Mk IABAK key - Harry C"
	& IABak.admin (User "kaz") "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHhFYMd9Htlf9wPZzIDyqbYYNwuo3m+kWQ9/pfAD/TE9 Kaz IABAK"
	& IABak.admin (User "yipdw") "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIEo2mGPw2TTJMHp7G86hMBh6n9/+abzg1oXIIlkwWwzo trythil@aglarond"

commonTools :: Property DebianLike
commonTools = propertyList "some vital but generic tools" $ props
	& Apt.installed ["sudo", "etckeeper", "mosh", "vim", "emacs-nox", "nano", "screen", "tmux", "less", "netcat", "bc", "python3", "ruby"]

shardTools :: Property DebianLike
shardTools = propertyList "tools specifically needed for creating new shards" $ props
	& Apt.installed  ["jq", "python3-aiohttp", "python-virtualenv"]

publicFace :: Property DebianLike
publicFace = propertyList "iabak public face" $ props
	& Git.cloned (User "root") repo "/usr/local/IA.BAK" (Just "server")
	& Apt.serviceInstalledRunning "apache2"
	& Cron.niceJob "graph-gen" (Cron.Times "*/10 * * * *") (User "root") "/"
		"/usr/local/IA.BAK/web/graph-gen.sh"

gitServer :: Property (HasInfo + DebianLike)
gitServer = propertyList "iabak git server" $ props
	& Git.cloned (User "root") repo "/usr/local/IA.BAK" (Just "server")
	& Git.cloned (User "root") repo "/usr/local/IA.BAK/client" (Just "master")
	& Ssh.userKeys (User "root") (Context "IA.bak.users.git") sshKeys
	& Ssh.knownHost knownHosts "gitlab.com" (User "root")
	& Git.cloned (User "root") userrepo pubkeyrepo (Just "master")
	& pubkeyrepo `Git.repoConfigured` ("remote.registrar.url", "/home/registrar/users")
	& pubkeyrepo `Git.repoConfigured` ("remote.registrar.fetch", "+refs/heads/*:refs/remotes/registrar/*")
	& Apt.serviceInstalledRunning "apache2"
	& "/usr/lib/cgi-bin/pushme.cgi" `File.isSymlinkedTo` File.LinkTarget "/usr/local/IA.BAK/pushme.cgi"
	& File.containsLine "/etc/sudoers" "www-data ALL=NOPASSWD:/usr/local/IA.BAK/pushed.sh"
	& Cron.niceJob "shardstats" (Cron.Times "*/30 * * * *") (User "root") "/"
		"/usr/local/IA.BAK/shardstats-all"
	& Cron.niceJob "shardmaint" Cron.Daily (User "root") "/"
		"/usr/local/IA.BAK/shardmaint-fast; /usr/local/IA.BAK/shardmaint"
	& Apt.installed ["git-annex"]
	& Apt.installed ["libmail-sendmail-perl"]
	& Cron.niceJob "expireemailer" Cron.Daily (User "root") 
		"/usr/local/IA.BAK"
		"./expireemailer"
  where
	pubkeyrepo = "/usr/local/IA.BAK/pubkeys"

registrationServer :: Property (HasInfo + DebianLike)
registrationServer = propertyList "iabak registration server" $ props
	& User.accountFor (User "registrar")
	& Ssh.userKeys (User "registrar") (Context "IA.bak.users.git") sshKeys
	& Ssh.knownHost knownHosts "gitlab.com" (User "registrar")
	& Git.cloned (User "registrar") repo "/home/registrar/IA.BAK" (Just "server")
	& Git.cloned (User "registrar") userrepo "/home/registrar/users" (Just "master")
	& Apt.serviceInstalledRunning "apache2"
	& Apt.installed ["perl", "perl-modules"]
	& link `File.isSymlinkedTo` File.LinkTarget "/home/registrar/IA.BAK/registrar/register.cgi"
	& cmdProperty "chown" ["-h", "registrar:registrar", link]
		`changesFile` link
	& File.containsLine "/etc/sudoers" "www-data ALL=(registrar) NOPASSWD:/home/registrar/IA.BAK/registrar/register.pl"
	& Apt.installed ["kgb-client"]
	& File.hasPrivContentExposed "/etc/kgb-bot/kgb-client.conf" anyContext
		`requires` File.dirExists "/etc/kgb-bot/"
  where
	link = "/usr/lib/cgi-bin/register.cgi"

sshKeys :: [(SshKeyType, Ssh.PubKeyText)]
sshKeys = 
	[ (SshRsa, "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCoiE+CPiIQyfWnl/E9iKG3eo4QzlH30vi7xAgKolGaTu6qKy4XPtl+8MNm2Dqn9QEYRVyyOT/XH0yP5dRc6uyReT8dBy03MmLkVbj8Q+nKCz5YOMTxrY3sX6RRXU1zVGjeVd0DtC+rKRT7reoCxef42LAJTm8nCyZu/enAuso5qHqBbqulFz2YXEKfU1SEEXLawtvgGck1KmCyg+pqazeI1eHWXrojQf5isTBKfPQLWVppBkWAf5cA4wP5U1vN9dVirIdw66ds1M8vnGlkTBjxP/HLGBWGYhZHE7QXjXRsk2RIXlHN9q6GdNu8+F3HXS22mst47E4UAeRoiXSMMtF5")
	]

graphiteServer :: Property (HasInfo + DebianLike)
graphiteServer = propertyList "iabak graphite server" $ props
	& Apt.serviceInstalledRunning "apache2"
	& Apt.installed ["libapache2-mod-wsgi", "graphite-carbon", "graphite-web"]
	& File.hasContent "/etc/carbon/storage-schemas.conf"
		[ "[carbon]"
		, "pattern = ^carbon\\."
		, "retentions = 60:90d"
		, "[iabak-connections]"
		, "pattern = ^iabak\\.shardstats\\.connections"
		, "retentions = 1h:1y,3h:10y"
		, "[iabak-default]"
		, "pattern = ^iabak\\."
		, "retentions = 10m:30d,1h:1y,3h:10y"
		, "[default_1min_for_1day]"
		, "pattern = .*"
		, "retentions = 60s:1d"
		]
	& graphiteCSRF
	& cmdProperty "graphite-manage" ["syncdb", "--noinput"]
		`assume` MadeChange
		`flagFile` "/etc/flagFiles/graphite-syncdb"
	& cmdProperty "graphite-manage" ["createsuperuser", "--noinput", "--username=joey", "--email=joey@localhost"]
		`assume` MadeChange
		`flagFile` "/etc/flagFiles/graphite-user-joey"
	& cmdProperty "graphite-manage" ["createsuperuser", "--noinput", "--username=db48x", "--email=db48x@localhost"]
		`assume` MadeChange
		`flagFile` "/etc/flagFiles/graphite-user-db48x"
	-- TODO: deal with passwords somehow
	& File.ownerGroup "/var/lib/graphite/graphite.db" (User "_graphite") (Group "_graphite")
	& "/etc/apache2/ports.conf" `File.containsLine` "Listen 8080"
		`onChange` Apache.restarted
	& Apache.siteEnabled "iabak-graphite-web"
		[ "<VirtualHost *:8080>"
		, "        WSGIDaemonProcess _graphite processes=5 threads=5 display-name='%{GROUP}' inactivity-timeout=120 user=_graphite group=_graphite"
		, "        WSGIProcessGroup _graphite"
		, "        WSGIImportScript /usr/share/graphite-web/graphite.wsgi process-group=_graphite application-group=%{GLOBAL}"
		, "        WSGIScriptAlias / /usr/share/graphite-web/graphite.wsgi"
		, "        Alias /content/ /usr/share/graphite-web/static/"
		, "        <Location \"/content/\">"
		, "                SetHandler None"
		, "        </Location>"
		, "        ErrorLog ${APACHE_LOG_DIR}/graphite-web_error.log"
		, "        LogLevel warn"
		, "        CustomLog ${APACHE_LOG_DIR}/graphite-web_access.log combined"
		, "</VirtualHost>"
		]
  where
	graphiteCSRF :: Property (HasInfo + DebianLike)
	graphiteCSRF = withPrivData (Password "csrf-token") (Context "iabak.archiveteam.org") $
		\gettoken -> property' "graphite-web CSRF token" $ \w ->
			gettoken $ \token -> ensureProperty w $ File.containsLine
				"/etc/graphite/local_settings.py" ("SECRET_KEY = '"++ privDataVal token ++"'")

knownHosts :: [Host]
knownHosts =
	[ host "gitlab.com" $ props
		& Ssh.hostPubKey SshEcdsa "ecdsa-sha2-nistp256 AAAAE2VjZHNhLXNoYTItbmlzdHAyNTYAAAAIbmlzdHAyNTYAAABBBFSMqzJeV9rUzU4kWitGjeR4PWSa29SPqJ1fVkhtj3Hw9xjLVXVYrU9QlYWrOLXBpQ6KWjbjTDTdDkoohFzgbEY="
	]

admin :: User -> Ssh.PubKeyText -> Property DebianLike
admin u@(User n) k = propertyList ("admin user " ++ n) $ props
	& User.accountFor u
	& User.hasGroup u (Group "staff")
	& Sudo.enabledFor u
	& Ssh.authorizedKey u k
	& Ssh.authorizedKey (User "root") k

--admin :: User -> [Ssh.PubKeyText] -> Property DebianLike
--admin u@(User n) ks = propertyList ("admin user " ++ n) $ props
--	& User.accountFor u
--	& User.hasGroup u (Group "staff")
--	& Sudo.enabledFor u
--	& Props (map (Ssh.authorizedKey u) ks)
--	& Props (map (Ssh.authorizedKey (User "root")) ks)

sshConfig :: Property DebianLike
sshConfig = propertyList "ssh config based on the Mozilla OpenSSH Guidelines" $ props
	& Ssh.noPasswords
	& Ssh.setSshdConfig "HostKey" "/etc/ssh/ssh_host_ed25519_key"
	& Ssh.setSshdConfig "KexAlgorithms" "curve25519-sha256@libssh.org,ecdh-sha2-nistp521,ecdh-sha2-nistp384,ecdh-sha2-nistp256,diffie-hellman-group-exchange-sha256"
	& Ssh.setSshdConfig "Ciphers" "chacha20-poly1305@openssh.com,aes256-gcm@openssh.com,aes128-gcm@openssh.com,aes256-ctr,aes192-ctr,aes128-ctr"
	& Ssh.setSshdConfig "MACs" "hmac-sha2-512-etm@openssh.com,hmac-sha2-256-etm@openssh.com,umac-128-etm@openssh.com,hmac-sha2-512,hmac-sha2-256,umac-128@openssh.com"
	& Ssh.setSshdConfig "LogLevel" "VERBOSE"
	& Ssh.setSshdConfig "Subsystem" "sftp  /usr/lib/ssh/sftp-server -f AUTHPRIV -l INFO"
	& Ssh.setSshdConfig "UsePrivilegeSeparation" "sandbox"
