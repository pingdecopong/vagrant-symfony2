#
# Cookbook Name:: common
# Recipe:: default
#
# Copyright 2013, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#

#
# iptables disable
#
service 'iptables' do
  action [:disable,  :stop]
end

#
# mysql55 install
#
package "mysql-libs" do
 action :remove
end

package "mysql55-server" do
 action :install
end

service "mysqld" do
  supports :status => true, :restart => true, :reload => true
  action [ :enable, :start ]
end

bash "mysql_role" do
  code <<-"EOH"
    mysql -u root -e "grant all privileges on *.* to root@'%' identified by '' with grant option;"
    mysql -u root -e "flush privileges;"
  EOH
  action :run
end

#
# php install
#
%w(php54 php54-cli php54-pdo php54-mbstring php54-mcrypt php54-pecl-memcache php54-mysql php54-devel php54-common php54-pgsql php54-pear php54-gd php54-xml php54-pecl-xdebug php54-pecl-apc php54-process php54-intl).each do |package|
  yum_package package do
    action :install
  end
end

# Host IP
ip = node[:network][:interfaces][:eth1][:addresses].detect{|k,v| v[:family] == "inet" }.first
remote_ip = ip.gsub /\.\d+$/, '.1'
node.default["php54"]["xdebug"]["remote_host"] = remote_ip

# php.ini config
template "php.ini" do
  path "/php.ini"
  source "php.ini.erb"
  owner "root"
  group "root"
  mode "0644"
end

#
# apache install
#
package "httpd" do
 action :install
end

template "vhosts.conf" do
  path "/etc/httpd/conf.d/vhosts.conf"
  source "vhosts.conf.erb"
  owner "root"
  group "root"
  mode 0644
  notifies :reload, 'service[httpd]'
end

service "httpd" do
  supports :status => true, :restart => true, :reload => true
  action [ :enable, :start ]
end

#composer_project_packages "symfony/framework-standard-edition" do
#    project_packpath "/var/www"
#    project_packfolder "Symfony"
#    project_packversion "2.3.6"
#    project_packuser "root"
#    project_packgroup "root"
#    dev false
#    action [:install]
#end

#
# symfony install
#
composer_project "/share" do
 action :install
end

#
# app_dev.php config
#
node.default['symfony2']['remote_host'] = remote_ip
template "app_dev.php" do
  path "/share/web/app_dev.php"
  source "app_dev.php.erb"
  owner "root"
  group "root"
  mode 0644
end



