module IABak where

import Propellor.Base
import qualified Propellor.Property.Apt as Apt
import qualified Propellor.Property.Git as Git
import qualified Propellor.Property.Cron as Cron
import qualified Propellor.Property.File as File
import qualified Propellor.Property.Apache as Apache
import qualified Propellor.Property.User as User
import qualified Propellor.Property.Ssh as Ssh

repo :: String
repo = "https://github.com/ArchiveTeam/IA.BAK/"

userrepo :: String
userrepo = "git@gitlab.com:archiveteam/IA.bak.users.git"

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
	& Git.cloned (User "root") userrepo "/usr/local/IA.BAK/pubkeys" (Just "master")
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
