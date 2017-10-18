Facter.add('samba_version') do
  confine :osfamily => "RedHat"
  result = Facter::Util::Resolution.exec('/bin/rpm -q --queryformat "%{VERSION}-%{RELEASE}" samba')
  setcode do
    result
  end
end

