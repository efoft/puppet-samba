#
class samba::server::service {

  $_service = ( $samba::server::security == 'ads' ) ? {
    true  => [$samba::params::server_service_name, $samba::params::winbind_service_name],
    false => $samba::params::server_service_name
  }
  
  service { $_service:
    ensure => $samba::server::ensure ? { 'present' => 'running', default => undef },
    enable => $samba::server::ensure ? { 'present' => true, default => undef },
  }
} 
