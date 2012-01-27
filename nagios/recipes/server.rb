#
# Author:: Joshua Sierles <joshua@37signals.com>
# Author:: Joshua Timberman <joshua@opscode.com>
# Author:: Nathan Haneysmith <nathan@opscode.com>
# Cookbook Name:: nagios
# Recipe:: server
#
# Copyright 2009, 37signals
# Copyright 2009-2010, Opscode, Inc
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

include_recipe "apache2"
include_recipe "apache2::mod_ssl"
include_recipe "apache2::mod_rewrite"
include_recipe "nagios::client"

require "pp"

# Default to production
env = 'nagios'
environment = 'Production'
if node.chef_environment == 'Development' || node.chef_environment.nil?
	env = 'nagios-dev'
        environment = 'Development'
end
Chef::Log.debug( "Nagios environment(Node:#{node.chef_environment} Used:#{environment}) string used: #{env}" )
users = search(:users, "#{env}:*")

all_nodes = search(:node, "hostname:* AND chef_environment:#{environment}")
#snmp_nodes = search( :bare_node, "nagios:* AND chef_environment:#{environment}" )
#all_nodes = all_nodes | snmp_nodes
nodes = Array.new

# Will hold the members that will become contacts
members = Array.new
sysadmins = Array.new

# Get rid of entries with blank pager & email
# I can't seem to get the search above to just include non empty values so
# a loop it is

#pp users

users.each do |s|
  begin
    if not s[env]['email'].empty? and not s[env]['pager'].empty?
      Chef::Log.debug( "Adding user #{s['id']} Email: #{s[env]['email']} Pager: #{s[env]['pager']}" )
      sysadmins << s
      members << s['id']
    end
  rescue
    Chef::Log.debug( "Not adding user #{s['id']} to the list because they're missing some contact info." )
  end
end

if all_nodes.empty?
  Chef::Log.debug("No nodes returned from search, using this node so hosts.cfg has data")
  nodes << node
else
 # Get rid of duplicate names
  all_nodes.each do |a|
    can_add = true
    nodes.each do |n|
      if a['hostname'] == n['hostname']
        can_add = false
      end
    end
    if can_add and not a['hostname'].nil?
      Chef::Log.debug( "Adding #{a['hostname']} to nodes to be monitored" )
      nodes << a
    end
  end
end

role_list = Array.new
service_hosts= Hash.new
search(:role, "*:*") do |r|
  role_list << r.name
  search(:node, "role:#{r.name} AND chef_environment:#{node.chef_environment}") do |n|
    service_hosts[r.name] = n['hostname']
  end
end

if node[:public_domain]
  public_domain = node[:public_domain]
else
  public_domain = node[:domain]
end

%w{ nagios3 nagios-nrpe-plugin nagios-images }.each do |pkg|
  package pkg
end

service "nagios3" do
  supports :status => true, :restart => true, :reload => true
  action [ :enable ]
end

nagios_conf "nagios" do
  config_subdir false
end

directory "#{node[:nagios][:dir]}/dist" do
  owner "nagios"
  group "nagios"
  mode "0755"
end

directory node[:nagios][:state_dir] do
  owner "nagios"
  group "nagios"
  mode "0751"
end

directory "#{node[:nagios][:state_dir]}/rw" do
  owner "nagios"
  group node[:apache][:user]
  mode "2710"
end

execute "archive default nagios object definitions" do
  command "mv #{node[:nagios][:dir]}/conf.d/*_nagios*.cfg #{node[:nagios][:dir]}/dist"
  not_if { Dir.glob(node[:nagios][:dir] + "/conf.d/*_nagios*.cfg").empty? }
end

file "#{node[:apache][:dir]}/conf.d/nagios3.conf" do
  action :delete
end

case node[:nagios][:server_auth_method]
when "openid"
  include_recipe "apache2::mod_auth_openid"
else
  template "#{node[:nagios][:dir]}/htpasswd.users" do
    source "htpasswd.users.erb"
    owner "nagios"
    group node[:apache][:user]
    mode 0640
    variables(
      :sysadmins => sysadmins
    )
  end
end

apache_site "000-default" do
  enable false
end

remote_directory "#{node[:apache][:dir]}/ssl" do
  source "ssl"
  owner "root"
  group "root"
  mode "0755"
  action :create
  files_mode "0755"
end

template "#{node[:apache][:dir]}/sites-available/nagios3.conf" do
  source "apache2.conf.erb"
  mode 0644
  variables :public_domain => public_domain
  if ::File.symlink?("#{node[:apache][:dir]}/sites-enabled/nagios3.conf")
    notifies :reload, resources(:service => "apache2")
  end
end

apache_site "nagios3.conf"

%w{ nagios cgi }.each do |conf|
  nagios_conf conf do
    config_subdir false
  end
end

%w{ templates timeperiods}.each do |conf|
  nagios_conf conf
end

hosts = search( :node, "nagios:checks AND chef_environment:#{node.chef_environment}" )
shosts = hosts #| snmp_nodes

services = Hash.new
shosts.each do |h|
    Chef::Log.debug( "Host #{h['hostname']} has the following services:" )
    h['nagios']['checks'].each do |s,v|
      if not v.empty? and not v.nil?
        Chef::Log.debug( s )
        if services[s].nil?
          services[s] = v
        end
        if services[s]['host_name'].nil?
          services[s]['host_name'] = "#{h['hostname']}"
        else
          services[s]['host_name'] << ",#{h['hostname']}"
        end
      end
    end
end

nagios_conf "services" do
  variables :service_hosts => service_hosts, :services => services
end

nagios_conf "commands" do
  variables :commands => services
end

nagios_conf "contacts" do
  variables :admins => sysadmins, :members => members
end

nagios_conf "hostgroups" do
  variables :roles => role_list
end

nagios_conf "hosts" do
  variables :nodes => nodes
end
