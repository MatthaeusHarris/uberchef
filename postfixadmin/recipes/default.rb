#
# Cookbook Name:: postfixadmin
# Recipe:: default
#
# Copyright 2011, Matthew Harris
#
# All rights reserved
#

require "pp"

%w{"postfix php5"}.do |p| {
  package p
}


