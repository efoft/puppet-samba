require 'facter'
 
result = %x{/bin/rpm -q --queryformat "%{VERSION}-%{RELEASE}" samba}
 
Facter.add('samba_version') do
    setcode do
        result
    end
end

