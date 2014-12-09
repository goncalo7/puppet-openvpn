# == Define: openvpn::client
#
define openvpn::client (
  $mute                = undef,
  $mute_replay_warning = false,
) {
  exec { "${name}.crt":
    cwd      => $::openvpn::easy_rsa_dir_path,
    command  => ". ./vars && ./pkitool ${name}",
    creates  => "${::openvpn::easy_rsa_dir_path}/keys/${name}.crt",
    provider => 'shell',
  }

  exec { "${name}.ovpn":
    path    => '/usr/bin:/usr/sbin/:/bin:/sbin',
    cwd     => "${::openvpn::config_dir_path}/download",
    command => "cat ${name}/${name}.conf | perl -lne 'if(m|^ca keys/ca.crt|){ chomp(\$ca=`cat ${name}/keys/ca.crt`); print \"<ca>\n\$ca\n</ca>\"} elsif(m|^cert keys/${name}.crt|) { chomp(\$crt=`cat ${name}/keys/${name}.crt`); print \"<cert>\n\$crt\n</cert>\"} elsif(m|^key keys/${name}.key|){ chomp(\$key=`cat ${name}/keys/${name}.key`); print \"<key>\n\$key\n</key>\"} else { print} ' > ${name}.ovpn",
    creates => "${::openvpn::config_dir_path}/download/${name}.ovpn",
    require => [
      File["${name}_ca.crt"],
      File["${name}.conf"],
      File["${name}.crt"],
      File["${name}.key"],
    ],
  }

  exec { "${name}.tar.gz":
    path    => '/usr/bin:/usr/sbin/:/bin:/sbin',
    cwd     => "${::openvpn::config_dir_path}/download",
    command => "tar cvfzh ${name}.tar.gz ${name}",
    creates => "${::openvpn::config_dir_path}/download/${name}.tar.gz",
    require => [
      File["${name}_ca.crt"],
      File["${name}.conf"],
      File["${name}.crt"],
      File["${name}.key"],
    ],
  }

  file { [
      "${::openvpn::config_dir_path}/download/${name}",
      "${::openvpn::config_dir_path}/download/${name}/keys",
    ]:
    ensure => $::openvpn::config_dir_ensure,
    owner  => $::openvpn::config_file_owner,
    group  => $::openvpn::config_file_group,
    mode   => '0750',
  }

  file { "${name}_ca.crt":
    ensure  => 'link',
    path    => "${::openvpn::config_dir_path}/download/${name}/keys/ca.crt",
    force   => true,
    target  => "${::openvpn::easy_rsa_dir_path}/keys/ca.crt",
    require => Exec["${name}.crt"],
  }

  file { "${name}.conf":
    ensure  => $::openvpn::config_file_ensure,
    path    => "${::openvpn::config_dir_path}/download/${name}/${name}.conf",
    owner   => $::openvpn::config_file_owner,
    group   => $::openvpn::config_file_group,
    mode    => '0440',
    content => template("openvpn/common/${::openvpn::config_dir_path}/client.conf.erb"),
  }

  file { "${name}.crt":
    ensure  => 'link',
    path    => "${::openvpn::config_dir_path}/download/${name}/keys/${name}.crt",
    force   => true,
    target  => "${::openvpn::easy_rsa_dir_path}/keys/${name}.crt",
    require => Exec["${name}.crt"],
  }

  file { "${name}.key":
    ensure  => 'link',
    path    => "${::openvpn::config_dir_path}/download/${name}/keys/${name}.key",
    force   => true,
    target  => "${::openvpn::easy_rsa_dir_path}/keys/${name}.key",
    require => Exec["${name}.crt"],
  }

  file { "${name}.ovpn":
    ensure  => $::openvpn::config_file_ensure,
    path    => "${::openvpn::config_dir_path}/download/${name}.ovpn",
    owner   => $::openvpn::config_file_owner,
    group   => $::openvpn::config_file_group,
    mode    => '0440',
    require => Exec["${name}.ovpn"],
  }

  Class['::openvpn::config'] -> Openvpn::Client[$name]
}
