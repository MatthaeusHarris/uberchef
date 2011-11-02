#
# Cookbook Name:: rcg
# Recipe:: default
#
# Copyright 2010, Montana State University
#
# All rights reserved - Do Not Redistribute
#

require "pp"

package "ntp"
package "libshadow-ruby1.8"
package "pv"
package "curl"
package "git-core"
package "vim"
package "acpid"

# Load the admin group onto all machines regardless of local configuration
admins = data_bag_item("groups","admin")
adminlist = []
#pp admins
admins['users'].each do |username|
  rcg_user username
  useritem = data_bag_item("users",username)
  systemusername = useritem["username"]
  systemusername = username unless systemusername
  adminlist.push(systemusername)
end

group "admin" do
  members   adminlist
end

template "/etc/sudoers" do
  source "sudoers.erb"
  mode 0440
  owner "root"
  group "root"
  variables(
    :sudoers_append => node[:sudoers_append]
  )
end

@local_users = []
begin
  node[:users].each do |role_user|
    @local_users << role_user
  end
  node[:localusers].each do |local_user|
    @local_users << local_user
  end
rescue => err
  puts err
end

#puts "pp'ing local users:"
#pp @local_users

@local_users.each do |local_user|
  rcg_user local_user
end

@local_groups = []
begin
  node[:groups].each do |role_group|
    @local_groups << role_group
  end
  node[:localgroups].each do |local_group|
    @local_groups << local_group
  end
rescue => err
  puts err
end

@local_groups.each do |local_group|
  g = data_bag_item("groups",local_group)
  group g['id'] do 
    gid       g['gid']
    members   g['users']
  end
end

@role_users = []
begin
  pp node[:role_users]
end
