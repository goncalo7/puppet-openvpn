# == Class: openvpn::params
#
class openvpn::params {
  $package_name = $::osfamily ? {
    default => 'openvpn',
  }

  $package_list = $::osfamily ? {
    'Debian' => getvar('::lsbdistcodename') ? {
      'jessie' => ['easy-rsa'],
      'trusty' => ['easy-rsa'],
      default  => undef,
    },
  }

  $config_dir_path = $::osfamily ? {
    default => '/etc/openvpn',
  }

  $config_file_path = $::osfamily ? {
    default => '/etc/openvpn/openvpn.conf',
  }

  $config_file_owner = $::osfamily ? {
    default => 'root',
  }

  $config_file_group = $::osfamily ? {
    default => 'root',
  }

  $config_file_mode = $::osfamily ? {
    default => '0644',
  }

  $config_file_notify = $::osfamily ? {
    default => 'Service[openvpn]',
  }

  $config_file_require = $::osfamily ? {
    default => 'Package[openvpn]',
  }

  $service_name = $::osfamily ? {
    default => 'openvpn',
  }

  $easy_rsa_source = $::osfamily ? {
    'Debian' => getvar('::lsbdistcodename') ? {
      'jessie' => '/usr/share/easy-rsa',
      'trusty' => '/usr/share/easy-rsa',
      default  => '/usr/share/doc/openvpn/examples/easy-rsa/2.0',
    }
  }

  case $::osfamily {
    'Debian': {
    }
    default: {
      fail("${::operatingsystem} not supported.")
    }
  }
}
