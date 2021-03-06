#
# Cookbook Name:: munin
# Recipe:: server
#
# Copyright 2010-2011, Opscode, Inc.
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
#

munin_servers = search(:node, "munin:[* TO *] AND chef_environment:#{node.chef_environment}")
munin_servers.sort! { |a,b| a[:fqdn] <=> b[:fqdn] }

munin_servers.each do |server|
  server[:ip] = server["munin"]["ipaddress"] || server["ipaddress"]
end

if node[:public_domain]
  case node.chef_environment
  when "production"
    public_domain = node[:public_domain]
  else
    public_domain = "#{node.chef_environment}.#{node[:public_domain]}"
  end
else
  public_domain = node[:domain]
end

include_recipe "apache2"
include_recipe "apache2::mod_auth_openid"
include_recipe "apache2::mod_rewrite"
include_recipe "munin::client"

package "munin"

case node[:platform]
when "arch"
  cron "munin-graph-html" do
    command "/usr/bin/munin-cron"
    user "munin"
    minute "*/5"
  end
else
  cookbook_file "/etc/cron.d/munin" do
    source "munin-cron"
    mode "0644"
    owner "root"
    group "root"
    backup 0
  end
end

template "/etc/munin/munin.conf" do
  source "munin.conf.erb"
  mode 0644
  variables(:munin_nodes => munin_servers, :docroot => node['munin']['docroot'])
end

apache_site "000-default" do
  enable false
end

template "#{node[:apache][:dir]}/sites-available/munin.conf" do
  source "htaccess.apache2.conf.erb"
  mode 0644
  variables(:public_domain => public_domain, :docroot => node['munin']['docroot'])
  if ::File.symlink?("#{node[:apache][:dir]}/sites-enabled/munin.conf")
    notifies :reload, resources(:service => "apache2")
  end
end

directory node['munin']['docroot'] do
  owner "munin"
  group "munin"
  mode 0755
end

apache_site "munin.conf"

munin_users = Array.new()

munin_group = data_bag_item(node[:munin][:group_databag],node[:munin][:allow_users])
munin_group["users"].each do |user|
  local_user = data_bag_item(node[:munin][:user_databag],user)
  if local_user["username"].nil?
    local_user["username"] = local_user["id"]
  end
  munin_users << local_user
end

template "/etc/munin/munin.htpasswd" do
  source "munin.htpasswd.erb"
  mode 0600
  owner "www-data"
  group "www-data"
  variables(:users => munin_users)
end