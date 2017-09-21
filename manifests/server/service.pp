#
class samba::server::service {
  
  service { 'samba':
    name   => $samba::params::server_service_name,
    ensure => $samba::server::ensure ? { 'present' => 'running', default => undef },
    enable => $samba::server::ensure ? { 'present' => true, default => undef },
  }
} 
