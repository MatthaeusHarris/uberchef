#
# Cookbook Name:: postfixadmin
# Recipe:: default
#
# Copyright 2011, Matthew Harris
#
# All rights reserved
#

require "pp"

%w{
  postfix 
  postfix-mysql 
  postgrey
  php5 
  php5-mysql
  php5-pgsql
  php5-imap
  dbconfig-common
  wwwconfig-common
  courier-base 
  courier-ssl 
  courier-authdaemon 
  courier-authlib 
  courier-authlib-mysql 
  courier-imap 
  courier-imap-ssl
  }.each do |p|
  package p
end

remote_file "/tmp/postfixadmin-#{node["postfixadmin"]["version"]}.tgz" do
  source node["postfixadmin"]["url"]
end

directory node["postfixadmin"]["webroot"] do
  recursive   true
end

script "unpack_postfixadmin" do
  not_if "test -f /var/www/postfixadmin/index.php"
  interpreter "bash"
  user "root"
  cwd node["postfixadmin"]["webroot"]
  code <<-EOH
  tar -zxvf --strip-component=1 /tmp/postfixadmin-#{node["postfixadmin"]["version"]}.tgz
  EOH
end