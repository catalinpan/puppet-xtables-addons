#puppet-xtables-addons

## Overview

This module installs xtables-addons from source tarballs on CentOS/RedHat 6.x. 
Tested with xtables-addons 1.41. 
## Usage

```tarball_url``` defines from where the tarball will be downloaded.

Using the class below will ensure that the module is installed
```
class { 'xtables':
	tarball_url     => 'http://downloads.sourceforge.net/project/xtables-addons/Xtables-addons/1.41',
	xtables_version => '1.41',
	}
```
The modules can be disabled and enabled using the variables from  ```mconfig```
Disable a module by adding on the main class:
```
rawnat         = '#build_RAWNAT=m',
```
Enable a module by adding on the main class:
```
rawnat         = 'build_RAWNAT=m',
```
By default ```RAWNAT```, ```SYSRQ``` and ```length2``` are disabled.

Use the autoupdate script only if you fully manage the cronjobs on your server with puppet, otherwise your cronjobs will be deleted.
```
        include xtables::update
```
## Dependencies
'maestrodev/wget', '>= 1.3.2'
'yguenane/repoforge', '>=0.2.0'
