#
define samba::share(
  $path        = undef,
  $visible     = true,
  $keep_owner  = true,
  $valid_users = [],
  $write_list  = [],
  $manage_dir  = true,
  $ad_locks    = false,
) {

  # Input validation
  validate_bool($visible, $keep_owner, $manage_dir, $ad_locks)
  validate_array($valid_users, $write_list)

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

  concat::fragment { "share-${title}-config":
    target  => $samba::server::server_config_file,
    content => template('samba/share.conf.erb'),
    notify  => Service['samba'],
    order   => '02',
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
    }

    file { $path:
      ensure  => directory,
      group   => $samba::server::share_group,
      seltype => 'samba_share_t',
      require => Exec["create-directory-tree-${path}"],
    }
  }
}
