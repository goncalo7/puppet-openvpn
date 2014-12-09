# == Class: openvpn::config
#
class openvpn::config {
  if $::openvpn::config_dir_source {
    file { 'openvpn.dir':
      ensure  => $::openvpn::config_dir_ensure,
      path    => $::openvpn::config_dir_path,
      force   => $::openvpn::config_dir_purge,
      purge   => $::openvpn::config_dir_purge,
      recurse => $::openvpn::config_dir_recurse,
      source  => $::openvpn::config_dir_source,
      notify  => $::openvpn::config_file_notify,
      require => $::openvpn::config_file_require,
    }
  }

  if $::openvpn::config_file_path {
    exec { 'ca.key':
      cwd      => $::openvpn::easy_rsa_dir_path,
      command  => '. ./vars && ./pkitool --initca',
      creates  => "${::openvpn::easy_rsa_dir_path}/keys/ca.key",
      provider => 'shell',
      require  => Exec["dh${::openvpn::key_size}.pem"],
    }

    exec { 'crl.pem':
      cwd      => $::openvpn::easy_rsa_dir_path,
      command  => ". ./vars && KEY_CN='' KEY_NAME='' KEY_OU='' openssl ca -gencrl -out ${::openvpn::config_dir_path}/crl.pem -config ${::openvpn::easy_rsa_dir_path}/openssl.cnf",
      creates  => "${::openvpn::config_dir_path}/crl.pem",
      provider => 'shell',
      require  => Exec['server.key'],
    }

    exec { "dh${::openvpn::key_size}.pem":
      cwd      => $::openvpn::easy_rsa_dir_path,
      command  => '. ./vars && ./clean-all && ./build-dh',
      creates  => "${::openvpn::easy_rsa_dir_path}/keys/dh${::openvpn::key_size}.pem",
      provider => 'shell',
      require  => File['easy-rsa.conf'],
    }

    exec { 'easy-rsa.dir':
      path    => '/usr/bin:/usr/sbin/:/bin:/sbin',
      command => "cp -r ${::openvpn::easy_rsa_source} ${::openvpn::easy_rsa_dir_path}",
      creates => $::openvpn::easy_rsa_dir_path,
      require => $::openvpn::config_file_require,
    }

    exec { 'server.key':
      cwd      => $::openvpn::easy_rsa_dir_path,
      command  => '. ./vars && ./pkitool --server server',
      creates  => "${::openvpn::easy_rsa_dir_path}/keys/server.key",
      provider => 'shell',
      require  => Exec['ca.key'],
    }

    file { 'easy-rsa.conf':
      ensure  => $::openvpn::config_file_ensure,
      path    => $::openvpn::easy_rsa_file_path,
      owner   => $::openvpn::config_file_owner,
      group   => $::openvpn::config_file_group,
      mode    => $::openvpn::config_file_mode,
      content => template("openvpn/common/${::openvpn::easy_rsa_file_path}.erb"),
      require => Exec['easy-rsa.dir'],
    }

    file { [
        "${::openvpn::config_dir_path}/download",
        "${::openvpn::config_dir_path}/easy-rsa",
      ]:
      ensure  => $::openvpn::config_dir_ensure,
      owner   => $::openvpn::config_file_owner,
      group   => $::openvpn::config_file_group,
      mode    => '0750',
      require => Exec['easy-rsa.dir'],
    }

    if getvar('::lsbdistcodename') != 'squeeze' {
      file { 'openssl.cnf':
        ensure  => 'link',
        path    => "${::openvpn::easy_rsa_dir_path}/openssl.cnf",
        force   => true,
        target  => "${::openvpn::easy_rsa_dir_path}/openssl-1.0.0.cnf",
        before  => Exec['crl.pem'],
        require => Exec['easy-rsa.dir'],
      }
    }

    file { 'openvpn.conf':
      ensure  => $::openvpn::config_file_ensure,
      path    => $::openvpn::config_file_path,
      owner   => $::openvpn::config_file_owner,
      group   => $::openvpn::config_file_group,
      mode    => $::openvpn::config_file_mode,
      source  => $::openvpn::config_file_source,
      content => $::openvpn::config_file_content,
      notify  => $::openvpn::config_file_notify,
      require => $::openvpn::config_file_require,
    }
  }
}
