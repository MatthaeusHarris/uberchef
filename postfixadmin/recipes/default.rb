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

remote_file "/tmp/postfixadmin-#{node["postfixadmin"]["version"]}.deb" do
  source node["postfixadmin"]["url"]
end