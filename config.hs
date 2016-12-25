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
import qualified Propellor.Property.HostingProvider.DigitalOcean as DO

main :: IO ()
main = defaultMain hosts

-- The hosts propellor knows about.
hosts :: [Host]
hosts = [ iabak
        , andor
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
	& IABak.commonTools
	& IABak.shardTools
	& User.hasSomePassword (User "root")
	& GitHome.installedFor (User "joey")
	& IABak.adminList
	& Ssh.noPasswords
	& IABak.gitServer
	& IABak.registrationServer
	& IABak.graphiteServer
	& IABak.publicFace
  where

andor :: Host
andor = host "andor.db48x.net" $ props
	& ipv4 "138.68.7.198"
	& Hostname.sane
	& osDebian Testing X86_64
	& DO.distroKernel
	& Systemd.persistentJournal
	& Cron.runPropellor (Cron.Times "30 * * * *")
	& Apt.stdSourcesList `onChange` Apt.upgrade
	& Apt.installed ["git", "ssh"]
	& IABak.sshConfig
	& Ssh.randomHostKeys
	& IABak.adminList
	& User.hasSomePassword (User "root")
	& GitHome.installedFor (User "joey")
	& IABak.commonTools
	& IABak.shardTools
