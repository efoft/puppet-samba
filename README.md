# puppet-samba
Installs and configures samba server on RHEL/CentOS.

## Installation
Clone to the puppet's modules directory:
```
git clone https://github.com/efoft/puppet-samba.git samba
```

## Example of usage:
Simple:
```
include samba::server
```

With params:
```
class { '::samba::server':
  netbios_name => 'fs01',
  security     => 'ads',
}
```

Shares:
```
samba::share { 'folder1':
  path       => '/path/to/folder1',
  keep_owner => false,
  ad_locks   => true,
}
```
