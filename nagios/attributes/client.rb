#
# Author:: Joshua Sierles <joshua@37signals.com>
# Author:: Joshua Timberman <joshua@opscode.com>
# Author:: Nathan Haneysmith <nathan@opscode.com>
# Cookbook Name:: nagios
# Attributes:: client
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
default[:nagios][:checks][:memory][:check_command] = "check_mem"
default[:nagios][:checks][:memory][:command_name] = "check_mem"
default[:nagios][:checks][:memory][:command_line] = "$USER1$/check_nrpe -H $HOSTADDRESS$ -c check_mem -t 20"
default[:nagios][:checks][:memory][:service_description] = "Free Memory on Host"
default[:nagios][:checks][:memory][:critical] = 150
default[:nagios][:checks][:memory][:warning]  = 250

default[:nagios][:checks][:procs][:check_command] = "check_total_procs"
default[:nagios][:checks][:procs][:command_name] = "check_total_procs"
default[:nagios][:checks][:procs][:command_line] = "$USER1$/check_nrpe -H $HOSTADDRESS$ -c check_total_procs -t 20"
default[:nagios][:checks][:procs][:service_description] = "Total processes on Host"
default[:nagios][:checks][:procs][:critical] = 800
default[:nagios][:checks][:procs][:warning]  = 500

default[:nagios][:checks][:check_all_disks][:check_command] = "check_all_disks"
default[:nagios][:checks][:check_all_disks][:command_name] = "check_all_disks"
default[:nagios][:checks][:check_all_disks][:command_line] = "$USER1$/check_nrpe -H $HOSTADDRESS$ -c check_all_disks -t 20"
default[:nagios][:checks][:check_all_disks][:service_description] = "Free Disk Space on Host"
default[:nagios][:checks][:check_all_disks][:critical] = "5%"
default[:nagios][:checks][:check_all_disks][:warning]  = "8%"

default[:nagios][:checks][:load][:check_command] = "check_load"
default[:nagios][:checks][:load][:command_name] = "check_load"
default[:nagios][:checks][:load][:command_line] = "$USER1$/check_nrpe -H $HOSTADDRESS$ -c check_load -t 20"
default[:nagios][:checks][:load][:service_description] = "Load averages on Host"
default[:nagios][:checks][:load][:critical]   = "30,20,10"
default[:nagios][:checks][:load][:warning]    = "15,10,5"

default[:nagios][:checks][:chef_client][:check_command] = "check_chef_client"
default[:nagios][:checks][:chef_client][:command_name] = "check_chef_client"
default[:nagios][:checks][:chef_client][:command_line] = "$USER1$/check_nrpe -H $HOSTADDRESS$ -c check_chef_client -t 20"
default[:nagios][:checks][:chef_client][:service_description] = "Chef Client Check"

default[:nagios][:checks][:check_release][:check_command] = "check_release"
default[:nagios][:checks][:check_release][:command_name] = "check_release"
default[:nagios][:checks][:check_release][:command_line] = "$USER1$/check_nrpe -H $HOSTADDRESS$ -c check_release"
default[:nagios][:checks][:check_release][:service_description] = "Distribution Release Expiration"

#default[:nagios][:checks][:smtp_host] = String.new

default[:nagios][:server_role] = "nagios_server"
default[:nagios][:nrpe_confd] = "/etc/nagios/nrpe.d"
default[:nagios][:nrpe_plugind] = "/usr/lib/nagios/plugins"
