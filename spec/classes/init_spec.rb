require 'spec_helper'

describe 'openvpn', :type => :class do
  ['Debian'].each do |osfamily|
    let(:facts) {{
      :osfamily          => osfamily,
      :ipaddress_primary => '10.0.2.15',
    }}

    it { is_expected.to compile.with_all_deps }
    it { is_expected.to contain_anchor('openvpn::begin') }
    it { is_expected.to contain_class('openvpn::params') }
    it { is_expected.to contain_class('openvpn::install') }
    it { is_expected.to contain_class('openvpn::config') }
    it { is_expected.to contain_class('openvpn::service') }
    it { is_expected.to contain_anchor('openvpn::end') }

    context "on #{osfamily}" do
      describe 'openvpn::install' do
        context 'defaults' do
          it do
            is_expected.to contain_package('openvpn').with(
              'ensure' => 'present',
            )
          end
        end

        context 'when package latest' do
          let(:params) {{
            :package_ensure => 'latest',
          }}

          it do
            is_expected.to contain_package('openvpn').with(
              'ensure' => 'latest',
            )
          end
        end

        context 'when package absent' do
          let(:params) {{
            :package_ensure => 'absent',
            :service_ensure => 'stopped',
            :service_enable => false,
          }}

          it do
            is_expected.to contain_package('openvpn').with(
              'ensure' => 'absent',
            )
          end
          it do
            is_expected.to contain_file('easy-rsa.conf').with(
              'ensure'  => 'present',
              'content' => /THIS FILE IS MANAGED BY PUPPET/,
              'require' => 'Exec[easy-rsa.dir]',
            )
          end
          it do
            is_expected.to contain_file('/etc/openvpn/download').with(
              'ensure'  => 'directory',
              'require' => 'Exec[easy-rsa.dir]',
            )
          end
          it do
            is_expected.to contain_file('/etc/openvpn/easy-rsa').with(
              'ensure'  => 'directory',
              'require' => 'Exec[easy-rsa.dir]',
            )
          end
          it do
            is_expected.to contain_file('openvpn.conf').with(
              'ensure'  => 'present',
              'notify'  => 'Service[openvpn]',
              'require' => 'Package[openvpn]',
            )
          end
          it do
            is_expected.to contain_service('openvpn').with(
              'ensure' => 'stopped',
              'enable' => false,
            )
          end
        end

        context 'when package purged' do
          let(:params) {{
            :package_ensure => 'purged',
            :service_ensure => 'stopped',
            :service_enable => false,
          }}

          it do
            is_expected.to contain_package('openvpn').with(
              'ensure' => 'purged',
            )
          end
          it do
            is_expected.to contain_file('easy-rsa.conf').with(
              'ensure'  => 'absent',
              'content' => /THIS FILE IS MANAGED BY PUPPET/,
              'require' => 'Exec[easy-rsa.dir]',
            )
          end
          it do
            is_expected.to contain_file('/etc/openvpn/download').with(
              'ensure'  => 'absent',
              'require' => 'Exec[easy-rsa.dir]',
            )
          end
          it do
            is_expected.to contain_file('/etc/openvpn/easy-rsa').with(
              'ensure'  => 'absent',
              'require' => 'Exec[easy-rsa.dir]',
            )
          end
          it do
            is_expected.to contain_file('openvpn.conf').with(
              'ensure'  => 'absent',
              'notify'  => 'Service[openvpn]',
              'require' => 'Package[openvpn]',
            )
          end
          it do
            is_expected.to contain_service('openvpn').with(
              'ensure' => 'stopped',
              'enable' => false,
            )
          end
        end
      end

      describe 'openvpn::config' do
        context 'defaults' do
          it do
            is_expected.to contain_file('openvpn.conf').with(
              'ensure'  => 'present',
              'notify'  => 'Service[openvpn]',
              'require' => 'Package[openvpn]',
            )
          end
        end

        context 'when source dir' do
          let(:params) {{
            :config_dir_source => 'puppet:///modules/openvpn/common/etc/openvpn',
          }}

          it do
            is_expected.to contain_file('openvpn.dir').with(
              'ensure'  => 'directory',
              'force'   => false,
              'purge'   => false,
              'recurse' => true,
              'source'  => 'puppet:///modules/openvpn/common/etc/openvpn',
              'notify'  => 'Service[openvpn]',
              'require' => 'Package[openvpn]',
            )
          end
        end

        context 'when source dir purged' do
          let(:params) {{
            :config_dir_purge  => true,
            :config_dir_source => 'puppet:///modules/openvpn/common/etc/openvpn',
          }}

          it do
            is_expected.to contain_file('openvpn.dir').with(
              'ensure'  => 'directory',
              'force'   => true,
              'purge'   => true,
              'recurse' => true,
              'source'  => 'puppet:///modules/openvpn/common/etc/openvpn',
              'notify'  => 'Service[openvpn]',
              'require' => 'Package[openvpn]',
            )
          end
        end

        context 'when source file' do
          let(:params) {{
            :config_file_source => 'puppet:///modules/openvpn/common/etc/openvpn/openvpn.conf',
          }}

          it do
            is_expected.to contain_exec('ca.key').with(
              'command' => '. ./vars && ./pkitool --initca',
              'creates' => '/etc/openvpn/easy-rsa/keys/ca.key',
              'require' => 'Exec[dh1024.pem]',
            )
          end
          it do
            is_expected.to contain_exec('crl.pem').with(
              'command' => '. ./vars && KEY_CN=\'\' KEY_NAME=\'\' KEY_OU=\'\' openssl ca -gencrl -out /etc/openvpn/crl.pem -config /etc/openvpn/easy-rsa/openssl.cnf',
              'creates' => '/etc/openvpn/crl.pem',
              'require' => 'Exec[server.key]',
            )
          end
          it do
            is_expected.to contain_exec('dh1024.pem').with(
              'command' => '. ./vars && ./clean-all && ./build-dh',
              'creates' => '/etc/openvpn/easy-rsa/keys/dh1024.pem',
              'require' => 'File[easy-rsa.conf]',
            )
          end
          it do
            is_expected.to contain_exec('easy-rsa.dir').with(
              'command' => 'cp -r /usr/share/doc/openvpn/examples/easy-rsa/2.0 /etc/openvpn/easy-rsa',
              'creates' => '/etc/openvpn/easy-rsa',
              'require' => 'Package[openvpn]',
            )
          end
          it do
            is_expected.to contain_exec('server.key').with(
              'command' => '. ./vars && ./pkitool --server server',
              'creates' => '/etc/openvpn/easy-rsa/keys/server.key',
              'require' => 'Exec[ca.key]',
            )
          end
          it do
            is_expected.to contain_exec('ca.key').with(
              'command' => '. ./vars && ./pkitool --initca',
              'creates' => '/etc/openvpn/easy-rsa/keys/ca.key',
              'require' => 'Exec[dh1024.pem]',
            )
          end
          it do
            is_expected.to contain_file('easy-rsa.conf').with(
              'ensure'  => 'present',
              'content' => /THIS FILE IS MANAGED BY PUPPET/,
              'require' => 'Exec[easy-rsa.dir]',
            )
          end
          it do
            is_expected.to contain_file('/etc/openvpn/download').with(
              'ensure'  => 'directory',
              'require' => 'Exec[easy-rsa.dir]',
            )
          end
          it do
            is_expected.to contain_file('/etc/openvpn/easy-rsa').with(
              'ensure'  => 'directory',
              'require' => 'Exec[easy-rsa.dir]',
            )
          end
          it do
            is_expected.to contain_file('openssl.cnf').with(
              'ensure'  => 'link',
              'target'  => '/etc/openvpn/easy-rsa/openssl-1.0.0.cnf',
              'before'  => 'Exec[crl.pem]',
              'require' => 'Exec[easy-rsa.dir]',
            )
          end
          it do
            is_expected.to contain_file('openvpn.conf').with(
              'ensure'  => 'present',
              'source'  => 'puppet:///modules/openvpn/common/etc/openvpn/openvpn.conf',
              'notify'  => 'Service[openvpn]',
              'require' => 'Package[openvpn]',
            )
          end
        end

        context 'when content string' do
          let(:params) {{
            :config_file_string => '# THIS FILE IS MANAGED BY PUPPET',
          }}

          it do
            is_expected.to contain_exec('ca.key').with(
              'command' => '. ./vars && ./pkitool --initca',
              'creates' => '/etc/openvpn/easy-rsa/keys/ca.key',
              'require' => 'Exec[dh1024.pem]',
            )
          end
          it do
            is_expected.to contain_exec('crl.pem').with(
              'command' => '. ./vars && KEY_CN=\'\' KEY_NAME=\'\' KEY_OU=\'\' openssl ca -gencrl -out /etc/openvpn/crl.pem -config /etc/openvpn/easy-rsa/openssl.cnf',
              'creates' => '/etc/openvpn/crl.pem',
              'require' => 'Exec[server.key]',
            )
          end
          it do
            is_expected.to contain_exec('dh1024.pem').with(
              'command' => '. ./vars && ./clean-all && ./build-dh',
              'creates' => '/etc/openvpn/easy-rsa/keys/dh1024.pem',
              'require' => 'File[easy-rsa.conf]',
            )
          end
          it do
            is_expected.to contain_exec('easy-rsa.dir').with(
              'command' => 'cp -r /usr/share/doc/openvpn/examples/easy-rsa/2.0 /etc/openvpn/easy-rsa',
              'creates' => '/etc/openvpn/easy-rsa',
              'require' => 'Package[openvpn]',
            )
          end
          it do
            is_expected.to contain_exec('server.key').with(
              'command' => '. ./vars && ./pkitool --server server',
              'creates' => '/etc/openvpn/easy-rsa/keys/server.key',
              'require' => 'Exec[ca.key]',
            )
          end
          it do
            is_expected.to contain_exec('ca.key').with(
              'command' => '. ./vars && ./pkitool --initca',
              'creates' => '/etc/openvpn/easy-rsa/keys/ca.key',
              'require' => 'Exec[dh1024.pem]',
            )
          end
          it do
            is_expected.to contain_file('easy-rsa.conf').with(
              'ensure'  => 'present',
              'content' => /THIS FILE IS MANAGED BY PUPPET/,
              'require' => 'Exec[easy-rsa.dir]',
            )
          end
          it do
            is_expected.to contain_file('/etc/openvpn/download').with(
              'ensure'  => 'directory',
              'require' => 'Exec[easy-rsa.dir]',
            )
          end
          it do
            is_expected.to contain_file('/etc/openvpn/easy-rsa').with(
              'ensure'  => 'directory',
              'require' => 'Exec[easy-rsa.dir]',
            )
          end
          it do
            is_expected.to contain_file('openssl.cnf').with(
              'ensure'  => 'link',
              'target'  => '/etc/openvpn/easy-rsa/openssl-1.0.0.cnf',
              'before'  => 'Exec[crl.pem]',
              'require' => 'Exec[easy-rsa.dir]',
            )
          end
          it do
            is_expected.to contain_file('openvpn.conf').with(
              'ensure'  => 'present',
              'content' => /THIS FILE IS MANAGED BY PUPPET/,
              'notify'  => 'Service[openvpn]',
              'require' => 'Package[openvpn]',
            )
          end
        end

        context 'when content template' do
          let(:params) {{
            :config_file_template => 'openvpn/common/etc/openvpn/openvpn.conf.erb',
          }}

          it do
            is_expected.to contain_exec('ca.key').with(
              'command' => '. ./vars && ./pkitool --initca',
              'creates' => '/etc/openvpn/easy-rsa/keys/ca.key',
              'require' => 'Exec[dh1024.pem]',
            )
          end
          it do
            is_expected.to contain_exec('crl.pem').with(
              'command' => '. ./vars && KEY_CN=\'\' KEY_NAME=\'\' KEY_OU=\'\' openssl ca -gencrl -out /etc/openvpn/crl.pem -config /etc/openvpn/easy-rsa/openssl.cnf',
              'creates' => '/etc/openvpn/crl.pem',
              'require' => 'Exec[server.key]',
            )
          end
          it do
            is_expected.to contain_exec('dh1024.pem').with(
              'command' => '. ./vars && ./clean-all && ./build-dh',
              'creates' => '/etc/openvpn/easy-rsa/keys/dh1024.pem',
              'require' => 'File[easy-rsa.conf]',
            )
          end
          it do
            is_expected.to contain_exec('easy-rsa.dir').with(
              'command' => 'cp -r /usr/share/doc/openvpn/examples/easy-rsa/2.0 /etc/openvpn/easy-rsa',
              'creates' => '/etc/openvpn/easy-rsa',
              'require' => 'Package[openvpn]',
            )
          end
          it do
            is_expected.to contain_exec('server.key').with(
              'command' => '. ./vars && ./pkitool --server server',
              'creates' => '/etc/openvpn/easy-rsa/keys/server.key',
              'require' => 'Exec[ca.key]',
            )
          end
          it do
            is_expected.to contain_exec('ca.key').with(
              'command' => '. ./vars && ./pkitool --initca',
              'creates' => '/etc/openvpn/easy-rsa/keys/ca.key',
              'require' => 'Exec[dh1024.pem]',
            )
          end
          it do
            is_expected.to contain_file('easy-rsa.conf').with(
              'ensure'  => 'present',
              'content' => /THIS FILE IS MANAGED BY PUPPET/,
              'require' => 'Exec[easy-rsa.dir]',
            )
          end
          it do
            is_expected.to contain_file('/etc/openvpn/download').with(
              'ensure'  => 'directory',
              'require' => 'Exec[easy-rsa.dir]',
            )
          end
          it do
            is_expected.to contain_file('/etc/openvpn/easy-rsa').with(
              'ensure'  => 'directory',
              'require' => 'Exec[easy-rsa.dir]',
            )
          end
          it do
            is_expected.to contain_file('openssl.cnf').with(
              'ensure'  => 'link',
              'target'  => '/etc/openvpn/easy-rsa/openssl-1.0.0.cnf',
              'before'  => 'Exec[crl.pem]',
              'require' => 'Exec[easy-rsa.dir]',
            )
          end
          it do
            is_expected.to contain_file('openvpn.conf').with(
              'ensure'  => 'present',
              'content' => /THIS FILE IS MANAGED BY PUPPET/,
              'notify'  => 'Service[openvpn]',
              'require' => 'Package[openvpn]',
            )
          end
        end

        context 'when content template (custom)' do
          let(:params) {{
            :config_file_template     => 'openvpn/common/etc/openvpn/openvpn.conf.erb',
            :config_file_options_hash => {
              'key' => 'value',
            },
          }}

          it do
            is_expected.to contain_exec('ca.key').with(
              'command' => '. ./vars && ./pkitool --initca',
              'creates' => '/etc/openvpn/easy-rsa/keys/ca.key',
              'require' => 'Exec[dh1024.pem]',
            )
          end
          it do
            is_expected.to contain_exec('crl.pem').with(
              'command' => '. ./vars && KEY_CN=\'\' KEY_NAME=\'\' KEY_OU=\'\' openssl ca -gencrl -out /etc/openvpn/crl.pem -config /etc/openvpn/easy-rsa/openssl.cnf',
              'creates' => '/etc/openvpn/crl.pem',
              'require' => 'Exec[server.key]',
            )
          end
          it do
            is_expected.to contain_exec('dh1024.pem').with(
              'command' => '. ./vars && ./clean-all && ./build-dh',
              'creates' => '/etc/openvpn/easy-rsa/keys/dh1024.pem',
              'require' => 'File[easy-rsa.conf]',
            )
          end
          it do
            is_expected.to contain_exec('easy-rsa.dir').with(
              'command' => 'cp -r /usr/share/doc/openvpn/examples/easy-rsa/2.0 /etc/openvpn/easy-rsa',
              'creates' => '/etc/openvpn/easy-rsa',
              'require' => 'Package[openvpn]',
            )
          end
          it do
            is_expected.to contain_exec('server.key').with(
              'command' => '. ./vars && ./pkitool --server server',
              'creates' => '/etc/openvpn/easy-rsa/keys/server.key',
              'require' => 'Exec[ca.key]',
            )
          end
          it do
            is_expected.to contain_exec('ca.key').with(
              'command' => '. ./vars && ./pkitool --initca',
              'creates' => '/etc/openvpn/easy-rsa/keys/ca.key',
              'require' => 'Exec[dh1024.pem]',
            )
          end
          it do
            is_expected.to contain_file('easy-rsa.conf').with(
              'ensure'  => 'present',
              'content' => /THIS FILE IS MANAGED BY PUPPET/,
              'require' => 'Exec[easy-rsa.dir]',
            )
          end
          it do
            is_expected.to contain_file('/etc/openvpn/download').with(
              'ensure'  => 'directory',
              'require' => 'Exec[easy-rsa.dir]',
            )
          end
          it do
            is_expected.to contain_file('/etc/openvpn/easy-rsa').with(
              'ensure'  => 'directory',
              'require' => 'Exec[easy-rsa.dir]',
            )
          end
          it do
            is_expected.to contain_file('openssl.cnf').with(
              'ensure'  => 'link',
              'target'  => '/etc/openvpn/easy-rsa/openssl-1.0.0.cnf',
              'before'  => 'Exec[crl.pem]',
              'require' => 'Exec[easy-rsa.dir]',
            )
          end
          it do
            is_expected.to contain_file('openvpn.conf').with(
              'ensure'  => 'present',
              'content' => /THIS FILE IS MANAGED BY PUPPET/,
              'notify'  => 'Service[openvpn]',
              'require' => 'Package[openvpn]',
            )
          end
        end
      end

      describe 'openvpn::service' do
        context 'defaults' do
          it do
            is_expected.to contain_service('openvpn').with(
              'ensure' => 'running',
              'enable' => true,
            )
          end
        end

        context 'when service stopped' do
          let(:params) {{
            :service_ensure => 'stopped',
          }}

          it do
            is_expected.to contain_service('openvpn').with(
              'ensure' => 'stopped',
              'enable' => true,
            )
          end
        end
      end
    end
  end
end
