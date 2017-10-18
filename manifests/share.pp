# === Define samba::share ===
#
# === Parameters ===
# [*keep_owner*]
#   If set to false, the directory is owned by share_owner/share_group and 'force user', 'force group' are added into share's config.
#   Default: true
#
# [*public*] 
#   Same meaning as in smb.conf. If omitted then the value is calculated based on *valid_users* and *write_list*.
#
# [*manage_dir*]
#   If set to true the directory itself is created, permissions and SELinux context are applied.
#   Default: true
#
# [*ad_locks*]
#   Tuning for the shares the AD users profiles are stored.
#   Default: false
#
define samba::share(
  Stdlib::Unixpath $path,
  Boolean $visible          = true,
  Boolean $keep_owner       = true,
  Array $valid_users        = [],
  Array $write_list         = [],
  Optional[Boolean] $public = undef,
  Boolean $manage_dir       = true,
  Boolean $ad_locks         = false,
) {

  # if valid users and write list are both empty we assume guest = ok if otherwise is not explicitly set
  if $public == undef {
    $_public = (empty($valid_users) and empty($write_list)) ? { true => 'yes', false => 'no' }
  }
  else {
    $_public = $public ? { true => 'yes', false => 'no' }
  }

  include ::samba::server

  if ! $keep_owner {
    realize(User['smbuser'])
  }

  if $_public == 'yes' {
    $public_opts = {
      'target'  => $samba::server::server_config_file,
      'content' => template('samba/map_to_guest.erb'),
      'notify'  => Service[$samba::server::service_name],
      'order'   => '02',
    }
    ensure_resource('concat::fragment', 'smb.conf-map-to-guest', $public_opts)
  }

  concat::fragment { "share-${title}-config":
    target  => $samba::server::server_config_file,
    content => template('samba/share.conf.erb'),
    notify  => Service[$samba::server::service_name],
    order   => '04',
  }

  if $manage_dir {
    selinux::fcontext { "samba-fcontext-for-${path}":
      path    => $path,
      context => 'samba_share_t',
      before  => Exec["create-directory-tree-${path}"],
    }

    exec { "create-directory-tree-${path}":
      command => "mkdir -p ${path}",
      path    => ['/usr/bin','/bin'],
      creates => $path,
      before  => File[$path],
    }

    file { $path:
      ensure  => directory,
      owner   => $keep_owner ? { true => undef, false => 'smbuser' },
      group   => $samba::server::share_group,
      seltype => 'samba_share_t',
      require => $keep_owner ? { true => undef, false => User['smbuser'] },
    }
  }
}
