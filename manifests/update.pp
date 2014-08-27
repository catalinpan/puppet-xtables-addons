class xtables::update 	{
	exec {'create_scripts_folder':
		provider => 'shell',
		command  => "/bin/mkdir -p /opt/scripts/",
		onlyif  => '/usr/bin/test ! -d /opt/scripts/',
		before => File['/opt/scripts/xtables-addons-update.sh'],
  		}
	file { '/opt/scripts/xtables-addons-update.sh':
		ensure => present,
		owner => root,
		group => root,
		mode => 600,
		content => template("xtables/xtables-addons-update.sh"),
                }
	cron { 'Xtables-addons geoip database auto update':
                command => "/bin/bash /opt/scripts/xtables-addons-update.sh",
                user    =>      'root',
                minute  =>      '0',
		hour    =>      '9',
		weekday =>      '6',
                ensure  =>      present,
		}
	}
