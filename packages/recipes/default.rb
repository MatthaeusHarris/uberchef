#
# Cookbook Name:: packages
# Recipe:: default
#
# Copyright 2011, MATT HARRIS
#
# All rights reserved - Do Not Redistribute
#
require "pp"

node["packages"].each do |p|
  package p
end