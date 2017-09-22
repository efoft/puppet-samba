#
class samba::params {

  case $::osfamily {
    'redhat': {
      $server_package_name  = 'samba'
      $server_config_file   = '/etc/samba/smb.conf'
      $server_service_name  = 'smb'
      $winbind_package_name = ['samba-winbind','samba-winbind-clients']
      $winbind_service_name = 'winbind'
    }
    default: {
      fail('Sorry! Your OS is not supported.')
    }
  }

  $dos_charset     = '866'
  $unix_charset    = 'utf8'

  if versioncmp($facts['samba_version'], '4.0.0') {
    $display_charset = undef
  }
  else {
    $display_charset = 'cp1251'
  }

  $share_owner = 'smbuser'
  $share_group = 'smbgrp'
  $share_uid   = '5010'
  $share_gid   = '5010'
}
