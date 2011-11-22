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
  source node["postfixadmin"]["url"]["ubuntu"]
end

package "postfixadmin" do
  source  "/tmp/postfixadmin-#{node["postfixadmin"]["version"]}.deb"
end
  
