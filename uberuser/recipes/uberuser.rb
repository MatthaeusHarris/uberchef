#
# Cookbook Name:: rcg
# Recipe:: default
#
# Copyright 2010, Montana State University
#
# All rights reserved - Do Not Redistribute
#

require "pp"

#development data dumping
pp node[:uberuser][:userdatabag]
pp node[:uberuser][:groupdatabag]

pp node[:users]
pp node[:groups]
pp node[:load_group_users]

#keep a local array for all the users we're going to collect
local_users = Array.new()

#populate it with all the explicitly listed users
node[:users].each do |user|
  local_users << user
end

#populate it with the implicitly listed users
node[:load_group_users].each do |groupname| 
  local_group = data_bag_item(node[:uberuser][:groupdatabag],groupname)
  local_group["users"].each do |user|
    local_users << user
  end
end

local_users.each do |user|
  rcg_user user
end

node[:groups].each do |groupname|
  local_group = data_bag_item(node[:uberuser][:groupdatabag],groupname)
  group groupname do
    gid       local_group["gid"]
    members   local_group["users"]
  end
end