# === Class samba::server ===
#
# === Parameters ===
# Almost all params are described in man smb.conf
# Below are only module specific ones.
#
# [*homes*]
#   Whether to include [homes] into config.
#
# [*home_root*]
#   Directory under which AD users homes are made via pam.
#
# [*share_owner*]
#   User that owns shares with keep_owner = false
#
# [*share_uid*]
#   *share_owner* uid.
#
# [*share_group*]
#   Group that owns shares with keep_owner = false
#
# [*share_gid*]
#   *share_group* gid.
#
class samba::server (
  Enum['present','absent'] $ensure              = 'present',
  Optional[String] $workgroup                   = undef,
  Optional[String] $server_string               = undef,
  Optional[String] $netbios_name                = undef,
  Array[String] $interfaces                     = [],
  Array[String] $hosts_allow                    = [],
  Enum['share','user','ads','domain'] $security = 'user',
  Optional[String] $realm                       = undef,
  Optional[String] $password_server             = undef,
  Boolean $master_browser                       = false,
  Boolean $printing                             = false,
  Boolean $wins_support                         = false,
  Optional[String] $wins_server                 = undef,
  Boolean $wins_proxy                           = false,
  Boolean $dns_proxy                            = false,
  String $winbind_separator                     = '+',
  Boolean $winbind_enum_users                   = true,
  Boolean $winbind_enum_groups                  = true,
  Optional[String] $dos_charset                 = $samba::params::dos_charset,
  Optional[String] $unix_charset                = $samba::params::unix_charset,
  Optional[String] $display_charset             = $samba::params::display_charset,
  Boolean $homes                                = false,
  Optional[Stdlib::Unixpath] $home_root         = undef,
  String $share_owner                           = $samba::params::share_owner,
  Numeric $share_uid                            = $samba::params::share_uid,
  String $share_group                           = $samba::params::share_group,
  Numeric $share_gid                            = $samba::params::share_gid,
) inherits samba::params {

  # Input validation
  if $security == 'ads' and ! $realm {
    fail('Parameter realm is required for security = ads')
  }

  if $homes and ! $home_root {
    fail('Parameter home_root is required if homes = true')
  }

  if versioncmp($facts['samba_version'], '4.0.0') and $security == 'share' {
    fail("Security type 'share' is not supported in Samba 4, use one of 'user', 'domain' or 'ads'.")
  }
  # End of input validation

  class { 'samba::server::install': } ->
  class { 'samba::server::selinux': } ->
  class { 'samba::server::config': } ~>
  class { 'samba::server::service': }
}
