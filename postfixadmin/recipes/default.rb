#
# Cookbook Name:: postfixadmin
# Recipe:: default
#
# Copyright 2011, Matthew Harris
#
# All rights reserved
#

::Chef::Recipe.send(:include, Opscode::OpenSSL::Password)
include_recipe "mysql::client"
require "pp"

node.set_unless["postfixadmin"]["database"]["password"] = secure_password

pp node["postfixadmin"]

database_server = search(:node, "hostname:#{node["postfixadmin"]["database"]["host"]}")
mysql_server_root_password = database_server[0]["mysql"]["server_root_password"]
mysql_server_fqdn = database_server[0]["ipaddress"]

pp mysql_server_root_password
pp mysql_server_fqdn


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
  checksum node["postfixadmin"]["hash"]
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
  tar -zxvf /tmp/postfixadmin-#{node["postfixadmin"]["version"]}.tgz --strip-component=1 
  EOH
end

database_code = <<-EOH
mysql -uroot -h #{mysql_server_fqdn} -p#{mysql_server_root_password} -e 'create database #{node["postfixadmin"]["database"]["database"]}'
mysql -uroot -h #{mysql_server_fqdn} -p#{mysql_server_root_password} mysql -e 'insert into user (Host, User, Password) values(\"#{node["ipaddress"]}\", \"#{node["postfixadmin"]["database"]["user"]}\", PASSWORD(\"#{node["postfixadmin"]["database"]["password"]}\")); flush privileges;'
mysql -uroot -h #{mysql_server_fqdn} -p#{mysql_server_root_password} mysql -e 'grant all on #{node["postfixadmin"]["database"]["database"]}.* to #{node["postfixadmin"]["database"]["user"]}@#{node["ipaddress"]}'
mysql -u#{node["postfixadmin"]["database"]["user"]} -p#{node["postfixadmin"]["database"]["password"]} -h #{mysql_server_fqdn} #{node["postfixadmin"]["database"]["database"]} -e 'show tables;'
EOH
pp database_code

script "create_database" do
  not_if "mysql -u#{node["postfixadmin"]["database"]["user"]} -p#{node["postfixadmin"]["database"]["password"]} -h #{mysql_server_fqdn} #{node["postfixadmin"]["database"]["database"]} -e 'show tables;'"
  interpreter "bash"
  user "root"
  code database_code
  cwd node["postfixadmin"]["webroot"]
end

script "config_postfixadmin" do
#  not_if "test -f #{node["postfixadmin"]["webroot"]}/config.inc.php.new"
  not_if "grep '\[\'configured\'\] = false' #{node["postfixadmin"]["webroot"]}/config.inc.php"
  interpreter "bash"
  user "root"
  cwd node["postfixadmin"]["webroot"]
  code <<-EOH
  cat config.inc.php \
  | sed "s/\\['configured'\\] = false/\\['configured'\\] = true/g"\
  | sed "s/\\['database_host'\\] = '.\*'/\\['database_host'\\] = '#{mysql_server_fqdn}'/g" \
  | sed "s/\\['database_user'\\] = '.\*'/\\['database_user'\\] = '#{node["postfixadmin"]["database"]["user"]}'/g" \
  | sed "s/\\['database_name'\\] = '.\*'/\\['database_name'\\] = '#{node["postfixadmin"]["database"]["database"]}'/g" \
  | sed "s/\\['database_password'\\] = '.\*'/\\['database_password'\\] = '#{node["postfixadmin"]["database"]["password"]}'/g" \
  > config.inc.php.new
  mv config.inc.php config.inc.php.`date +%Y%m%d-%H%M%S`
  mv config.inc.php.new config.inc.php
  EOH
#  $CONF['database_user'] = 'postfix';
#  $CONF['database_password'] = 'postfixadmin';
#  $CONF['database_name'] = 'postfix';
  
end