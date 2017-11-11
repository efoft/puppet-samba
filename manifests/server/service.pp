#
class samba::server::service {

  $_service = ( $samba::server::security == 'ads' ) ? {
    true  => [$samba::params::server_service_name, $samba::params::winbind_service_name],
    false => $samba::params::server_service_name
  }

  $_ensure = $samba::server::service_manage ?
  {
    true  => 'running',
    false => undef
  }

  service { $_service:
    ensure => $samba::server::ensure ? { 'present' => $_ensure, default => undef },
    enable => $samba::server::ensure ? { 'present' => $samba::server::service_enable, default => undef },
  }
} 
