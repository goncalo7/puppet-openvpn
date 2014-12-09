require 'spec_helper'

describe 'openvpn::define', :type => :define do
  ['Debian'].each do |osfamily|
    let(:facts) {{
      :osfamily  => osfamily,
      :ipaddress => '10.0.2.15',
    }}
    let(:pre_condition) { 'include openvpn' }
    let(:title) { 'openvpn.conf' }

    context "on #{osfamily}" do
      context 'when source file' do
        let(:params) {{
          :config_file_source => 'puppet:///modules/openvpn/common/etc/openvpn/openvpn.conf',
        }}

        it do
          is_expected.to contain_file('define_openvpn.conf').with({
            'ensure'  => 'present',
            'source'  => 'puppet:///modules/openvpn/common/etc/openvpn/openvpn.conf',
            'notify'  => 'Service[openvpn]',
            'require' => 'Package[openvpn]',
          })
        end
      end

      context 'when content string' do
        let(:params) {{
          :config_file_string => '# THIS FILE IS MANAGED BY PUPPET',
        }}

        it do
          is_expected.to contain_file('define_openvpn.conf').with({
            'ensure'  => 'present',
            'content' => /THIS FILE IS MANAGED BY PUPPET/,
            'notify'  => 'Service[openvpn]',
            'require' => 'Package[openvpn]',
          })
        end
      end

      context 'when content template' do
        let(:params) {{
          :config_file_template => 'openvpn/common/etc/openvpn/openvpn.conf.erb',
        }}

        it do
          is_expected.to contain_file('define_openvpn.conf').with({
            'ensure'  => 'present',
            'content' => /THIS FILE IS MANAGED BY PUPPET/,
            'notify'  => 'Service[openvpn]',
            'require' => 'Package[openvpn]',
          })
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
          is_expected.to contain_file('define_openvpn.conf').with({
            'ensure'  => 'present',
            'content' => /THIS FILE IS MANAGED BY PUPPET/,
            'notify'  => 'Service[openvpn]',
            'require' => 'Package[openvpn]',
          })
        end
      end
    end
  end
end
