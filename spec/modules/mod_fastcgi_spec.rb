require 'spec_helper'

describe 'apache2::mod_fastcgi' do
  before do
    stub_command('test -f /usr/lib/httpd/modules/mod_auth_openid.so').and_return(true)
    stub_command('test -f /etc/httpd/mods-available/fastcgi.conf').and_return(true)
  end

  supported_platforms.each do |platform, versions|
    versions.each do |version|
      context "on #{platform.capitalize} #{version}" do
        let(:chef_run) do
          ChefSpec::Runner.new(:platform => platform, :version => version).converge(described_recipe)
        end

        if %w(debian ubuntu).include?(platform)
          it 'installs package libapache2-mod-fastcgi' do
            expect(chef_run).to install_package('libapache2-mod-fastcgi')
          end
        elsif %w(redhat centos).include?(platform)
          %w(gcc make libtool httpd-devel apr-devel apr).each do |package|
            it "installs package #{package}" do
              expect(chef_run).to upgrade_yum_package(package)
            end
          end
        end
      end
    end
  end

  it_should_behave_like 'an apache2 module', 'fastcgi', true, supported_platforms
end
