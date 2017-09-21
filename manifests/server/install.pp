#
class samba::server::install (
) {

  $package_ensure = $samba::server::ensure ? {
    'present'     => 'present',
    'absent'      => 'purged'
  }

  package { 'samba':
    name   => $samba::params::server_package_name,
    ensure => $package_ensure,
  }
}
