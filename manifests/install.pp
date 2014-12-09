# == Class: openvpn::install
#
class openvpn::install {
  if $::openvpn::package_name {
    package { 'openvpn':
      ensure => $::openvpn::package_ensure,
      name   => $::openvpn::package_name,
    }
  }

  if $::openvpn::package_list {
    ensure_resource('package', $::openvpn::package_list, { 'ensure' => $::openvpn::package_ensure })
  }
}
