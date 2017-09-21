#
class samba::server::config {

  concat { $samba::params::server_config_file:
    ensure  => $samba::server::ensure,
  }

  concat::fragment { 'smb.conf-global':
    target  => $samba::params::server_config_file,
    content => template('samba/smb.conf.erb'),
    order   => '01',
  }
    
  # users and groups
  # all content inside shares belong to group smbgrp
  # if share is public it also belong to user smbuser
  # this user is realized if such share occures
  @user { 'smbuser':
    ensure => $samba::server::ensure,
    name   => $samba::server::share_owner,
    uid    => $samba::server::share_uid,
    gid    => $samba::server::share_group,
    shell  => '/sbin/nologin',
    home   => '/tmp',
  }

  group { 'smbgrp':
    ensure => $samba::server::ensure,
    name   => $samba::server::share_group,
    gid    => $samba::server::share_gid,
  }
}
