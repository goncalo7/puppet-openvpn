require 'spec_helper_acceptance'

case fact('osfamily')
when 'Debian'
  package_name     = 'openvpn'
  config_dir_path  = '/etc/openvpn'
  config_file_path = '/etc/openvpn/openvpn.conf'
  service_name     = 'openvpn'
end

describe 'openvpn', :if => SUPPORTED_PLATFORMS.include?(fact('osfamily')) do
  it 'is_expected.to work with no errors' do
    pp = <<-EOS
      class { 'openvpn': }
    EOS

    apply_manifest(pp, :catch_failures => true)
    apply_manifest(pp, :catch_changes => true)
  end

  describe 'openvpn::install' do
    context 'defaults' do
      it 'is_expected.to work with no errors' do
        pp = <<-EOS
          class { 'openvpn': }
        EOS

        apply_manifest(pp, :catch_failures => true)
      end

      describe package(package_name) do
        it { is_expected.to be_installed }
      end
    end

    context 'when package latest' do
      it 'is_expected.to work with no errors' do
        pp = <<-EOS
          class { 'openvpn':
            package_ensure => 'latest',
          }
        EOS

        apply_manifest(pp, :catch_failures => true)
      end

      describe package(package_name) do
        it { is_expected.to be_installed }
      end
    end

    context 'when package absent' do
      it 'is_expected.to work with no errors' do
        pp = <<-EOS
          class { 'openvpn':
            package_ensure => 'absent',
            service_ensure => 'stopped',
            service_enable => false,
          }
        EOS

        apply_manifest(pp, :catch_failures => true)
      end

      describe package(package_name) do
        it { is_expected.not_to be_installed }
      end
      describe file(config_file_path) do
        it { is_expected.to be_file }
      end
      describe service(service_name) do
        it { is_expected.not_to be_running }
        it { is_expected.not_to be_enabled }
      end
    end

    context 'when package purged' do
      it 'is_expected.to work with no errors' do
        pp = <<-EOS
          class { 'openvpn':
            package_ensure => 'purged',
            service_ensure => 'stopped',
            service_enable => false,
          }
        EOS

        apply_manifest(pp, :expect_failures => true)
      end

      describe package(package_name) do
        it { is_expected.not_to be_installed }
      end
      describe file(config_file_path) do
        it { is_expected.not_to be_file }
      end
      describe service(service_name) do
        it { is_expected.not_to be_running }
        it { is_expected.not_to be_enabled }
      end
    end
  end

  describe 'openvpn::config' do
    context 'defaults' do
      it 'is_expected.to work with no errors' do
        pp = <<-EOS
          class { 'openvpn': }
        EOS

        apply_manifest(pp, :catch_failures => true)
      end

      describe file(config_file_path) do
        it { is_expected.to be_file }
      end
    end

    context 'when content template' do
      it 'is_expected.to work with no errors' do
        pp = <<-EOS
          class { 'openvpn':
            config_file_template => "openvpn/#{config_file_path}.erb",
          }
        EOS

        apply_manifest(pp, :catch_failures => true)
      end

      describe file(config_file_path) do
        it { is_expected.to be_file }
        it { is_expected.to contain 'THIS FILE IS MANAGED BY PUPPET' }
      end
    end

    context 'when hash of files' do
      it 'is_expected.to work with no errors' do
        pp = <<-EOS
          class { 'openvpn':
            config_file_hash => {
              'openvpn.4th.conf' => {
                config_file_path     => '/etc/default/openvpn',
                config_file_template => 'openvpn/common/etc/default.erb',
              },
            },
          }
        EOS

        apply_manifest(pp, :catch_failures => true)
      end

      describe file('/etc/default/openvpn') do
        it { is_expected.to be_file }
        it { is_expected.to contain 'THIS FILE IS MANAGED BY PUPPET' }
      end
    end
  end

  describe 'openvpn::service' do
    context 'defaults' do
      it 'is_expected.to work with no errors' do
        pp = <<-EOS
          class { 'openvpn': }
        EOS

        apply_manifest(pp, :catch_failures => true)
      end

      describe service(service_name) do
        it { is_expected.to be_running }
        it { is_expected.to be_enabled }
      end
    end

    context 'when service stopped' do
      it 'is_expected.to work with no errors' do
        pp = <<-EOS
          class { 'openvpn':
            service_ensure => 'stopped',
          }
        EOS

        apply_manifest(pp, :catch_failures => true)
      end

      describe service(service_name) do
        it { is_expected.not_to be_running }
        it { is_expected.to be_enabled }
      end
    end
  end
end
