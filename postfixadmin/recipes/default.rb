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


