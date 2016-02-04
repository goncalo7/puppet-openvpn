# openvpn

[![Build Status](https://travis-ci.org/dhoppe/puppet-openvpn.png?branch=master)](https://travis-ci.org/dhoppe/puppet-openvpn)
[![Puppet Forge](https://img.shields.io/puppetforge/v/dhoppe/openvpn.svg)](https://forge.puppetlabs.com/dhoppe/openvpn)
[![Puppet Forge](https://img.shields.io/puppetforge/dt/dhoppe/openvpn.svg)](https://forge.puppetlabs.com/dhoppe/openvpn)
[![Puppet Forge](https://img.shields.io/puppetforge/mc/dhoppe.svg)](https://forge.puppetlabs.com/dhoppe)
[![Puppet Forge](https://img.shields.io/puppetforge/rc/dhoppe.svg)](https://forge.puppetlabs.com/dhoppe)

#### Table of Contents

1. [Overview](#overview)
2. [Module Description - What the module does and why it is useful](#module-description)
3. [Setup - The basics of getting started with openvpn](#setup)
    * [What openvpn affects](#what-openvpn-affects)
    * [Setup requirements](#setup-requirements)
    * [Beginning with openvpn](#beginning-with-openvpn)
4. [Usage - Configuration options and additional functionality](#usage)
5. [Reference - An under-the-hood peek at what the module is doing and how](#reference)
6. [Limitations - OS compatibility, etc.](#limitations)
7. [Development - Guide for contributing to the module](#development)

## Overview

This module installs, configures and manages the OpenVPN service.

## Module Description

This module handles installing, configuring and running OpenVPN across a range of operating systems and distributions.

## Setup

### What openvpn affects

* openvpn package.
* openvpn configuration file.
* openvpn service.

### Setup Requirements

* Puppet >= 2.7
* Facter >= 1.6
* [Stdlib module](https://github.com/puppetlabs/puppetlabs-stdlib)

### Beginning with openvpn

Install openvpn with the default parameters ***(No configuration files will be changed)***.

```puppet
    class { 'openvpn': }
```

Install openvpn with the recommended parameters.

```puppet
    class { 'openvpn':
      config_file_template => 'openvpn/common/etc/openvpn/openvpn.conf.erb',
      config_file_hash     => {
        'openvpn' => {
          config_file_path     => '/etc/default/openvpn',
          config_file_template => 'openvpn/common/etc/default/openvpn.erb',
        },
      },
      key_country          => 'DE',
      key_province         => 'NRW',
      key_city             => 'Muenster',
      server_subnet        => '192.168.57.0 255.255.255.0',
    }
```

## Usage

Update the openvpn package.

```puppet
    class { 'openvpn':
      package_ensure => 'latest',
    }
```

Remove the openvpn package.

```puppet
    class { 'openvpn':
      package_ensure => 'absent',
    }
```

Purge the openvpn package ***(All configuration files will be removed)***.

```puppet
    class { 'openvpn':
      package_ensure => 'purged',
    }
```

Deploy the configuration files from source directory.

```puppet
    class { 'openvpn':
      config_dir_source => 'puppet:///modules/openvpn/common/etc/openvpn',
    }
```

Deploy the configuration files from source directory ***(Unmanaged configuration files will be removed)***.

```puppet
    class { 'openvpn':
      config_dir_purge  => true,
      config_dir_source => 'puppet:///modules/openvpn/common/etc/openvpn',
    }
```

Deploy the configuration file from source.

```puppet
    class { 'openvpn':
      config_file_source => 'puppet:///modules/openvpn/common/etc/openvpn/openvpn.conf',
    }
```

Deploy the configuration file from string.

```puppet
    class { 'openvpn':
      config_file_string => '# THIS FILE IS MANAGED BY PUPPET',
    }
```

Deploy the configuration file from template.

```puppet
    class { 'openvpn':
      config_file_template => 'openvpn/common/etc/openvpn/openvpn.conf.erb',
    }
```

Deploy the configuration file from custom template ***(Additional parameters can be defined)***.

```puppet
    class { 'openvpn':
      config_file_template     => 'openvpn/common/etc/openvpn/openvpn.conf.erb',
      config_file_options_hash => {
        'key' => 'value',
      },
    }
```

Deploy additional configuration files from source, string or template.

```puppet
    class { 'openvpn':
      config_file_hash => {
        'openvpn.2nd.conf' => {
          config_file_path   => '/etc/openvpn/openvpn.2nd.conf',
          config_file_source => 'puppet:///modules/openvpn/common/etc/openvpn/openvpn.2nd.conf',
        },
        'openvpn.3rd.conf' => {
          config_file_path   => '/etc/openvpn/openvpn.3rd.conf',
          config_file_string => '# THIS FILE IS MANAGED BY PUPPET',
        },
        'openvpn.4th.conf' => {
          config_file_path     => '/etc/openvpn/openvpn.4th.conf',
          config_file_template => 'openvpn/common/etc/openvpn/openvpn.4th.conf.erb',
        },
      },
    }
```

Disable the openvpn service.

```puppet
    class { 'openvpn':
      service_ensure => 'stopped',
    }
```

## Reference

### Classes

#### Public Classes

* openvpn: Main class, includes all other classes.

#### Private Classes

* openvpn::install: Handles the packages.
* openvpn::config: Handles the configuration file.
* openvpn::service: Handles the service.

### Parameters

#### `package_ensure`

Determines if the package should be installed. Valid values are 'present', 'latest', 'absent' and 'purged'. Defaults to 'present'.

#### `package_name`

Determines the name of package to manage. Defaults to 'openvpn'.

#### `package_list`

Determines if additional packages should be managed. Defaults to 'undef'.

#### `config_dir_ensure`

Determines if the configuration directory should be present. Valid values are 'absent' and 'directory'. Defaults to 'directory'.

#### `config_dir_path`

Determines if the configuration directory should be managed. Defaults to '/etc/openvpn'

#### `config_dir_purge`

Determines if unmanaged configuration files should be removed. Valid values are 'true' and 'false'. Defaults to 'false'.

#### `config_dir_recurse`

Determines if the configuration directory should be recursively managed. Valid values are 'true' and 'false'. Defaults to 'true'.

#### `config_dir_source`

Determines the source of a configuration directory. Defaults to 'undef'.

#### `config_file_ensure`

Determines if the configuration file should be present. Valid values are 'absent' and 'present'. Defaults to 'present'.

#### `config_file_path`

Determines if the configuration file should be managed. Defaults to '/etc/openvpn/openvpn.conf'

#### `config_file_owner`

Determines which user should own the configuration file. Defaults to 'root'.

#### `config_file_group`

Determines which group should own the configuration file. Defaults to 'root'.

#### `config_file_mode`

Determines the desired permissions mode of the configuration file. Defaults to '0644'.

#### `config_file_source`

Determines the source of a configuration file. Defaults to 'undef'.

#### `config_file_string`

Determines the content of a configuration file. Defaults to 'undef'.

#### `config_file_template`

Determines the content of a configuration file. Defaults to 'undef'.

#### `config_file_notify`

Determines if the service should be restarted after configuration changes. Defaults to 'Service[openvpn]'.

#### `config_file_require`

Determines which package a configuration file depends on. Defaults to 'Package[openvpn]'.

#### `config_file_hash`

Determines which configuration files should be managed via `openvpn::define`. Defaults to '{}'.

#### `config_file_options_hash`

Determines which parameters should be passed to an ERB template. Defaults to '{}'.

#### `service_ensure`

Determines if the service should be running or not. Valid values are 'running' and 'stopped'. Defaults to 'running'.

#### `service_name`

Determines the name of service to manage. Defaults to 'openvpn'.

#### `service_enable`

Determines if the service should be enabled at boot. Valid values are 'true' and 'false'. Defaults to 'true'.

#### `ca_expire`

Determines the number of days to certify the CA certificate for. Defaults to '3650'.

#### `key_expire`

Determines the number of days to certify the server certificate for. Defaults to '3650'.

#### `key_size`

Determines the length of SSL keys (in bits) generated by this module. Defaults to '1024'.

#### `key_country`

Determines the country to be used for the SSL certificate, mandatory for server mode. Defaults to 'undef'.

#### `key_province`

Determines the province to be used for the SSL certificate, mandatory for server mode. Defaults to 'undef'.

#### `key_city`

Determines the city to be used for the SSL certificate, mandatory for server mode. Defaults to 'undef'.

#### `key_organization`

Determines the organization to be used for the SSL certificate, mandatory for server mode. Defaults to "$::domain".

#### `key_email`

Determines the email to be used for the SSL certificate, mandatory for server mode. Defaults to "admin@${::domain}".

#### `key_cn`

Determines the value for commonName_default variable in openssl.cnf and KEY_CN in vars. Defaults to ''.

#### `key_name`

Determines the value for name_default variable in openssl.cnf and KEY_NAME in vars. Defaults to ''.

#### `key_ou`

Determines the value for organizationalUnitName_default variable in openssl.cnf and KEY_OU in vars. Defaults to ''.

#### `server_port`

Determines the port the openvpn server service is running on. Defaults to '1194'.

#### `server_proto`

Determines which IP protocol should be used. Defaults to 'udp'.

#### `server_dev`

Determines which virtual network device should be used. Defaults to 'tun'.

#### `server_subnet`

Determines the network to assign client addresses out of. Defaults to 'undef'.

#### `server_push`

Determines options to push out to the client. For example routes, DNS servers, DNS search domains and many more. Defaults to 'undef'.

#### `server_compression`

Determines if compression should be enabled. Defaults to 'true'.

#### `server_user`

Determines if privileges should be dropped to user 'nobody' after startup. Defaults to 'true'.

#### `server_group`

Determines if privileges should be dropped to group 'nogroup' after startup. Defaults to 'true'.

### Parameters within `openvpn::client`

#### `mute`

Determines the log mute level. Defaults to 'undef'.

#### `mute_replay_warning`

Determines if duplicate packet warnings should be silenced. Valid values are 'true' and 'false'. Defaults to 'false'.

## Limitations

This module has been tested on:

* Debian 6/7/8
* Ubuntu 12.04/14.04

## Development

### Bug Report

If you find a bug, have trouble following the documentation or have a question about this module - please create an issue.

### Pull Request

If you are able to patch the bug or add the feature yourself - please make a pull request.

### Contributors

The list of contributors can be found at: [https://github.com/dhoppe/puppet-openvpn/graphs/contributors](https://github.com/dhoppe/puppet-openvpn/graphs/contributors)
