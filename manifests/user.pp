# === Define samba::user ===
# Manages samba users with smbpasswd command.
# It can set only initial password but won't revert it back if it has been changed manually.
# Passwords are passed to smbpasswd command in plain text, so that it can be security issue.
#
# Bare in mind that the user must be added to OS level before adding to smb.
#
# === Parameters ===
# [*username*]
#   By default is used $title of the resource.
#
# [*ensure*]
#   Add (present) or delete (absent) the user.
#
# [*password*]
#   Plain text password for the user.
#
define samba::user (
  String $username = $title,
  Enum['present','absent'] $ensure = 'present',
  String $password,
) {

  include ::samba::server

  if $ensure == 'present' {
    exec { "add-smbuser-${username}":
      command => "echo -e \"${password}\n${password}\" | smbpasswd -L -s -a ${username}",
      path    => ['/bin'],
      unless  => "smbpasswd -e ${username}",
    }
  }
  else {
    exec { "delete-smbuser-${username}":
      command => "smbpasswd -L -x ${username}",
      path    => ['/bin'],
      onlyif  => "smbpasswd -e ${username}",
    }
  }
}
