require 'spec_helper'

describe 'default recipe on ubuntu 20.04' do
  cached(:runner) { ChefSpec::ServerRunner.new(platform: 'ubuntu', version: '20.04', step_into: ['openldap_install']) }
  cached(:chef_run) { runner.converge('openldap::default') }

  it 'converges successfully' do
    expect { :chef_run }.to_not raise_error
  end

  it 'installs the openldap server packages' do
    expect(chef_run).to install_package('slapd')
  end

  it 'installs the ldap-utils' do
    expect(chef_run).to install_package('ldap-utils')
  end

  it 'installs the dbd package' do
    expect(chef_run).to install_package('db-util')
  end
end

describe 'default recipe on centos 7' do
  cached(:runner) { ChefSpec::ServerRunner.new(platform: 'centos', version: '7', step_into: ['openldap_install']) }
  cached(:chef_run) { runner.converge('openldap::default') }

  it 'converges successfully' do
    expect { :chef_run }.to_not raise_error
  end

  it 'installs the openldap server package' do
    expect(chef_run).to install_package('openldap-servers')
  end

  it 'installs the dbd package' do
    expect(chef_run).to install_package('compat-db47')
  end
end

describe 'default recipe on freebsd 11' do
  cached(:runner) { ChefSpec::ServerRunner.new(platform: 'freebsd', version: '11', step_into: ['openldap_install']) }
  cached(:chef_run) { runner.converge('openldap::default') }

  it 'converges successfully' do
    expect { :chef_run }.to_not raise_error
  end

  it 'installs the openldap server package' do
    expect(chef_run).to install_package('openldap-server')
  end

  it 'does not install the dbd package' do
    expect(chef_run).to install_package('libdbi')
  end
end
