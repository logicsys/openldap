property :package_action, Symbol, default: :install

action :install do
  if db_package
    package db_package do
      action new_resource.package_action
    end
  end

  # the debian package needs a preseed file in order to silently install
  if platform_family?('debian')
    package 'ldap-utils'

    directory node['openldap']['preseed_dir'] do
      action :create
      recursive true
      mode '0755'
      owner 'root'
      group node['root_group']
    end

    cookbook_file "#{node['openldap']['preseed_dir']}/slapd.seed" do
      source 'slapd.seed'
      cookbook 'openldap'
      mode '0600'
      owner 'root'
      group node['root_group']
    end

    dpkg_autostart server_package do
      allow false
    end
  end

  # NOTE(ramereth): RHEL 8 doesn't include openldap-servers so we pull from the
  # OSUOSL which builds the latest Fedora release for EL8
  if platform_family?('rhel') && node['platform_version'].to_i >= 8
    yum_repository 'osuosl-openldap' do
      baseurl 'https://ftp.osuosl.org/pub/osl/repos/yum/$releasever/openldap/$basearch'
      gpgkey 'https://ftp.osuosl.org/pub/osl/repos/yum/RPM-GPG-KEY-osuosl'
      description 'OSUOSL OpenLDAP repository'
      gpgcheck true
      enabled true
    end
  end

  package server_package do
    response_file 'slapd.seed' if platform_family?('debian')
    action new_resource.package_action
  end
end

action_class do
  def server_package
    case node['platform_family']
    when 'debian'
      'slapd'
    when 'rhel', 'fedora', 'amazon'
      'openldap-servers'
    when 'freebsd'
      'openldap-server'
    when 'suse'
      'openldap2'
    end
  end

  def db_package
    case node['platform_family']
    when 'debian'
      'db-util'
    when 'rhel', 'amazon'
      'compat-db47' if node['platform_version'].to_i < 8
    when 'freebsd'
      'libdbi'
    end
  end
end
