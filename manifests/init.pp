class xtables ( 
	$xtables_version = '1.41', 
	$tarball_url, $tarball_dir = '/opt',
        $account        = 'build_ACCOUNT=m',
        $chaos          = 'build_CHAOS=m',                                        
        $checksum       = 'build_CHECKSUM=',
        $delude		= 'build_DELUDE=m',
	$dhcpmac	= 'build_DHCPMAC=m',
	$dnetmap	= 'build_DNETMAP=m',
	$echo		= 'build_ECHO=',
	$ipmark		= 'build_IPMARK=m',
	$logmark	= 'build_LOGMARK=m',
	$rawnat		= '#build_RAWNAT=m',
	$steal		= 'build_STEAL=m',
	$sysrq		= '#build_SYSRQ=m',
	$tarpit		= 'build_TARPIT=m',
	$tee		= 'build_TEE=',
	$condition	= 'build_condition=m',
	$fuzzy		= 'build_fuzzy=m',
	$geoip		= 'build_geoip=m',
	$gradm		= 'build_gradm=m',
	$iface		= 'build_iface=m',
	$ipp2p		= 'build_ipp2p=m',
	$ipset6		= 'build_ipset6=',
	$ipv4options	= 'build_ipv4options=m',
	$lenght2	= '#build_length2=m',
	$lscan		= 'build_lscan=m',
	$pknock		= 'build_pknock=m',
	$psd		= 'build_psd=m',
	$quota2		= 'build_quota2=m',
		) {

  Exec {
    path => '/usr/bin/:/bin:/usr/sbin:/sbin',
  }

  package { [
		'gcc',
		'gcc-c++',
		'make',
		'automake',
		'unzip',
		'zip',
		'perl',
		'perl-Text-CSV_XS',
		'xz',
            ]:
    ensure => installed,
    before => [ Exec['compile-xtables'], ],
  }
 exec { 'kernel-dependencies':
	command		=>"yum install iptables-devel kernel-headers-`uname -r` kernel-devel-`uname -r` -y",
	provider	=> 'shell',
	before 		=>  [ Exec['compile-xtables'], ],
	}

#  $xtables_tarball = "xtables-addons-${xtables_version}.tar.gz"
  $xtables_tarball = "xtables-addons-${xtables_version}.tar.xz"

  include wget

    file { '/opt/xtables-addons-1.41/mconfig':
      ensure => present,
      owner => root,
      group => root,
      mode => 600,
      content => template("xtables/mconfig"),
	before => [ Exec['configure-xtables'], ]
                }

  # Installl xtables-addons
  wget::fetch { 'xtables':
    source      => "${tarball_url}/${xtables_tarball}",
    destination => "${tarball_dir}/${xtables_tarball}",
  }
  service { "iptables":
	ensure	=>	"running",
	}
  exec {'extract-xtables':
    cwd     => "${tarball_dir}",
    command => "tar -xvf ${xtables_tarball}",
    creates => "${tarball_dir}/xtables-addons-${xtables_version}",
    require => Wget::Fetch['xtables'],
	before => File['/opt/xtables-addons-1.41/mconfig'],
  }
  exec {'configure-xtables':
	cwd      => "${tarball_dir}/xtables-addons-${xtables_version}/",
	provider => 'shell',
	command  => "./configure",
	creates  => "${tarball_dir}/xtables-addons-${xtables_version}/Makefile",
	require  => Exec['extract-xtables'],
  }
  exec {'compile-xtables':
	cwd      => "${tarball_dir}/xtables-addons-${xtables_version}/",
	provider => 'shell',
	command  => "make && make install",
	onlyif => '/usr/bin/test ! -d /usr/local/libexec/xtables-addons',
	require  => Exec['configure-xtables'],
	notify	=> Service ['iptables'],
  }
  exec {'update-geoip-db':
	cwd      => "${tarball_dir}/xtables-addons-${xtables_version}/geoip/",
	provider => 'shell',
	command  => "./xt_geoip_dl && ./xt_geoip_build GeoIPCountryWhois.csv",
	require  => Exec['compile-xtables'],
  }
  file { "/usr/share/xt_geoip/":
	ensure	=> "directory",
	require	=> Exec['update-geoip-db'],
	}
  exec {'copy-geoip-db':
	cwd      => "${tarball_dir}/xtables-addons-${xtables_version}/geoip/",
	provider => 'shell',
	command  => "cp -r {BE,LE} /usr/share/xt_geoip/",
	require	 => File['/usr/share/xt_geoip/'],
  }
  

}
