#
# Cookbook Name:: rinetd
# Recipe:: default
#
# Copyright 2012, Matt Harris
#
# All rights reserved - Redistribute at will
#

require "pp"

package "rinetd" do
  action	:install
end