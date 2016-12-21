-- This is the main configuration file for Propellor, and is used to build
-- the propellor program.    https://propellor.branchable.com/

import Propellor
import qualified IABak
import qualified Propellor.Property.Apt as Apt
import qualified Propellor.Property.Cron as Cron
import qualified Propellor.Property.User as User
import qualified Propellor.Property.Ssh as Ssh
import qualified Propellor.Property.Hostname as Hostname
import qualified Propellor.Property.Systemd as Systemd
import qualified Propellor.Property.SiteSpecific.GitHome as GitHome

main :: IO ()
main = defaultMain hosts

-- The hosts propellor knows about.
hosts :: [Host]
hosts =
        [ iabak
        ]

iabak :: Host
iabak = host "iabak.archiveteam.org" $ props
	& ipv4 "124.6.40.235"
	& Hostname.sane
	& osDebian Testing X86_64
	& Systemd.persistentJournal
	& Cron.runPropellor (Cron.Times "30 * * * *")
	& Apt.stdSourcesList `onChange` Apt.upgrade
	& Apt.installed ["git", "ssh"]
	& Ssh.hostKeys (Context "iabak.archiveteam.org")
		[ (SshDsa, "ssh-dss AAAAB3NzaC1kc3MAAACBAMhuYTshLxavWCpfyJxg3j/GWyIRlL3VTharsfUTzMOqyMSWantZjflfJX21z2KzFDtPEA711GYztsgMVXMrsPQInaOKNISe/R9cfgnEktKTxeppWTfw0GTNcpCeeecddU0FCPVW3a6yDoT6+Rv0jPvkQoDGmhQ40MhauMrO0mJ9AAAAFQDpCbXG8o/3Sg7wrsp5abizJoQ0yQAAAIEAxxyHo/ZhDPP+EWtDS05s5dwiDMUsxIllk1NeleAOQIyLtFkaifOeskDJybIPWYPGX1trjcPoGuXJ5GBYrRaPiu6FBvYdYMFRLr4uNBsaSHHqlHhBPkP3RzCrdUyau4XyjdE4iA0EQlO+u11A+o3f7aTuJSveM0YRfbqvaatG89EAAACAWd0h0SkRLnGjBzkou0SQfYujFY9ilhWXPWV/oOs+bieDSpvfmnaEfLSinVFRrJPvQp/dtpxPLEm+StrK3w6dmwTZVUM5JEoB1mRjBkVs6gPC9PVVg9qLpzC2/x+r5cTfrffjyRrlPdkwLKpO6oiPxTIxAyCW8ixjafkxe2hAeJo=")
		, (SshRsa, "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDP13oPRLRY0V9ZDWojb8TgHbUdE30Nq3b541TwPmlLMbYPAhldxGHkuXGlX8g9/FYP/1AgkPcxs2Uc61ZV+1Ss7q7t52f4R0bO4WHqxfdXHd9FlLzMLWxMU3aMr693pGlhnUp3/xH6O6/+bNEIo3VGGgv9XDr2cAxypS9J7X9ibHZcZ3BGvoCR+nnFJ00ERG2tREKZBPDWKk76lhCiM21fG/CSmcApXaA45FHDaM9/2Clj1sXvoS72f0hEKpl1m08sUx+F0GPzQESnKqNFl+xXdYPPbfhdrgCnDmx9tL5NnXsJU2beFiuxpICOeB1HV6DJsdlO18WqwXYhOg/2A1H3")
		, (SshEcdsa, "ecdsa-sha2-nistp256 AAAAE2VjZHNhLXNoYTItbmlzdHAyNTYAAAAIbmlzdHAyNTYAAABBBHb0kXcrF5ThwS8wB0Hez404Zp9bz78ZxEGSqnwuF4d/N3+bymg7/HAj7l/SzRoEXKHsJ7P5320oMxBHeM16Y+k=")
		]
	& Apt.installed ["etckeeper", "sudo"]
	-- vital but generic tools
	& Apt.installed ["vim", "screen", "tmux", "less", "emacs-nox", "netcat", "nano", "bc", "ruby"]
	-- tools for creating shards
	& Apt.installed ["jq", "python3", "python3-aiohttp", "python-virtualenv"]
	& User.hasSomePassword (User "root")
	& GitHome.installedFor (User "joey")
	& IABak.admin (User "joey") "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICfFntnesZcYz2B2T41ay45igfckXRSh5uVffkuCQkLv joey@darkstar"
	& IABak.admin (User "db48x") "ssh-rsa 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 db48x@anglachel"
	& IABak.admin (User "db48x") "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJQkqIgZ7D8WHW5Y3o+fpZC/4xtv/3IQrORJrTPCt7KY db48x@erebor"
	& IABak.admin (User "hcross") "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIP5OhU2Lita9RdjPkX9N0w9wZnmVlednUDEx24bVn4Mk IABAK key - Harry C"
	& IABak.admin (User "kaz") "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHhFYMd9Htlf9wPZzIDyqbYYNwuo3m+kWQ9/pfAD/TE9 Kaz IABAK"
	& IABak.admin (User "yipdw") "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIEo2mGPw2TTJMHp7G86hMBh6n9/+abzg1oXIIlkwWwzo trythil@aglarond"
	& Ssh.noPasswords
	& IABak.gitServer
	& IABak.registrationServer
	& IABak.graphiteServer
	& IABak.publicFace
  where
