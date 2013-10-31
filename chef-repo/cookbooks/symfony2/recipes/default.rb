#
# Cookbook Name:: symfony2
# Recipe:: default
#
# Copyright 2013, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#

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
ip = node[:network][:interfaces][:eth1][:addresses].detect{|k,v| v[:family] == "inet" }.first
remote_ip = ip.gsub /\.\d+$/, '.1'
node.default['symfony2']['remote_host'] = remote_ip
template "app_dev.php" do
  path "/share/web/app_dev.php"
  source "app_dev.php.erb"
  owner "root"
  group "root"
  mode 0644
end
