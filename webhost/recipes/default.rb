#
# Cookbook Name:: webhost
# Recipe:: default
#
# Copyright 2011, Matt Harris
#
# All rights reserved - Do Not Redistribute
#

require "pp"
include_recipe "apache2"

node[:virtualhosts].each do |servname, virthost|
  pp servname
  pp virthost
  web_app servname do
    server_name       virthost[:server_name]
    server_aliases    virthost[:server_aliases]
    docroot           virthost[:docroot]
    application_name  virthost[:application_name]
  end
  
  link "/var/www/#{virthost[:server_name]}" do
    to  virthost[:docroot]
  end
end