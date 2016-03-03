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
