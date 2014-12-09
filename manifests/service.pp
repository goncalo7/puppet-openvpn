# == Class: openvpn::service
#
class openvpn::service {
  if $::openvpn::service_name {
    service { 'openvpn':
      ensure     => $::openvpn::_service_ensure,
      name       => $::openvpn::service_name,
      enable     => $::openvpn::_service_enable,
      hasrestart => true,
    }
  }
}
