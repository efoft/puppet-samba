#
define samba::share(
  $path        = undef,
  $visible     = true,
  $keep_owner  = true,
  $valid_users = [],
  $write_list  = [],
  $public      = undef,
  $manage_dir  = true,
  $ad_locks    = false,
) {

  # if valid users and write list are both empty we assume guest = ok if otherwise is not explicitly set
  if $public == undef {
    $_public = (empty($valid_users) and empty($write_list)) ? { true => 'yes', false => 'no' }
  }
  else {
    $_public = $public ? { true => 'yes', false => 'no', default => $public }
  }

  # Input validation
  validate_bool($visible, $keep_owner, $manage_dir, $ad_locks)
  validate_array($valid_users, $write_list)
  validate_re($_public, ['yes','no'], "${_public} is not valid for 'public', expected values are 'yes','no','true' or 'false'.")

  if ! $path {
    fail('Parameter path is required.')
  }
  if $create_lv and ! $size {
    fail('Parameter size is required if create_lv = true.')
  }
  # End of input validation

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
