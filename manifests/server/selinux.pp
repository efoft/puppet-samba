#
class samba::server::selinux {

  selboolean { 'samba_enable_home_dirs':
    persistent  => true,
    value       => $samba::server::homes ? { true => 'on', false => 'off' },
  }
}
