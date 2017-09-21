#
class samba::server (
  $ensure          = 'present',
  $workgroup       = undef,
  $server_string   = undef,
  $netbios_name    = undef,
  $interfaces      = [],
  $hosts_allow     = [],
  $security        = 'user',
  $realm           = undef,
  $password_server = [],
  $master_browser  = false,
  $printing        = false,
  $wins_support    = false,
  $wins_server     = undef,
  $wins_proxy      = false,
  $dns_proxy       = false,
  $winbind_separator = '+',
  $winbind_enum_users = true,
  $winbind_enum_groups = true,
  $dos_charset         = $samba::params::dos_charset,
  $unix_charset        = $samba::params::unix_charset,
  $display_charset     = $samba::params::display_charset,
  $homes               = false,
  $home_root           = undef,
  $share_owner         = $samba::params::share_owner,
  $share_uid           = $samba::params::share_uid,
  $share_group         = $samba::params::share_group,
  $share_gid           = $samba::params::share_gid,
) inherits samba::params {

  # Input validation
  validate_re($ensure, ['present','absent'], "${ensure} is not valid for ensure, expected 'present' or 'absent'")
  validate_re($security, ['user','domain','ads'], "${security} is not valid for security, expected 'user','domain' or 'ads'")
  validate_array($interfaces, $hosts_allow)
  validate_bool($printing, $master_browser, $wins_support, $wins_proxy, $dns_proxy, $winbind_enum_users, $winbind_enum_groups, $homes)

  if $security == 'ads' and ! $realm {
    fail('Parameter realm is required for security = ads')
  }

  if $homes and ! $home_root {
    fail('Parameter home_root is required if homes = true')
  }
  # End of input validation

  class { 'samba::server::install': } ->
  class { 'samba::server::selinux': } ->
  class { 'samba::server::config': } ~>
  class { 'samba::server::service': }
}
