#
# Author:: Joshua Sierles <joshua@37signals.com>
# Author:: Joshua Timberman <joshua@opscode.com>
# Author:: Nathan Haneysmith <nathan@opscode.com>
# Cookbook Name:: nagios
# Recipe:: client
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
#
require "pp"
mon_host = Array.new

if node.run_list.roles.include?(node[:nagios][:server_role])
  mon_host << node[:ipaddress]
else
  search(:node, "role:#{node[:nagios][:server_role]} AND chef_environment:#{node.chef_environment}") do |n|
    mon_host << n['ipaddress']
  end
end

pp mon_host

%w{
  nagios-nrpe-server
  nagios-plugins
  nagios-plugins-basic
  nagios-plugins-standard
}.each do |pkg|
  package pkg
end

service "nagios-nrpe-server" do
  action :enable
  supports :restart => true, :reload => true
end

remote_directory "#{node[:nagios][:nrpe_plugind]}" do
  source "plugins/#{node[:kernel][:machine]}"
  owner "nagios"
  group "nagios"
  mode 0755
  files_mode 0755
end

remote_directory "#{node[:nagios][:nrpe_plugind]}" do
  source "plugins/any"
  owner "nagios"
  group "nagios"
  mode 0755
  files_mode 0755
end

template "/etc/nagios/nrpe.cfg" do
  source "nrpe.cfg.erb"
  owner "nagios"
  group "nagios"
  mode "0644"
  variables :mon_host => mon_host
  notifies :restart, resources(:service => "nagios-nrpe-server")
end

directory "#{node[:nagios][:nrpe_confd]}" do
  owner "nagios"
  group "nagios"
  mode "0755"
  action :create
end

# Default NRPE Checks
nrpe_cmd node[:nagios][:checks][:memory][:check_command] do
	script_name "check_mem.sh"
	script_params "-w #{node[:nagios][:checks][:memory][:warning]} -c #{node[:nagios][:checks][:memory][:critical]} -p"
end

nrpe_cmd node[:nagios][:checks][:procs][:check_command] do
	script_name "check_procs"
	script_params "-w #{node[:nagios][:checks][:procs][:warning]} -c #{node[:nagios][:checks][:procs][:critical]}"
end

nrpe_cmd node[:nagios][:checks][:load][:check_command] do
	script_name "check_load"
	script_params "-w #{node[:nagios][:checks][:load][:warning]} -c #{node[:nagios][:checks][:load][:critical]}"
end

nrpe_cmd node[:nagios][:checks][:check_all_disks][:check_command] do
	script_name "check_disk"
	script_params "-w #{node[:nagios][:checks][:check_all_disks][:warning]} -c #{node[:nagios][:checks][:check_all_disks][:critical]} -A -x /dev/shm -X nfs -i /boot"
end

nrpe_cmd node[:nagios][:checks][:chef_client][:check_command] do
	script_name "check_procs"
	script_params "-w 1:2 -c 1:2 -C chef-client"
end

nrpe_cmd node[:nagios][:checks][:check_release][:check_command] do
	script_name "check_release.py"
	script_params ""
end
