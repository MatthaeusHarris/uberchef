#
# Cookbook Name:: bind
# Recipe:: default
#
# Copyright 2011, MONTANA STATE UNIVERSITY, RESEARCH COMPUTING GROUP
#
# All rights reserved - Do Not Redistribute
#

require "pp"
require "ipaddr"

package "bind9" do
  action  :install
end

records = Hash.new()
zones = Array.new()

all_nodes = search(:node, "*:*")
all_nodes.each do |n|
  if !n["ipaddress"].nil?
    if n.name =~ /#{Regexp.escape(node["bind"]["defaultdomain"])}$/
      fqdn = n.name + '.'
    else
      fqdn = n.name
    end
    pp fqdn    
    records[fqdn + "IN A"] = {"name" => fqdn, "type" => "IN A", "info" => n.ipaddress}
  end
end

pp records

data_bag("dns").each do |domain|
  domain_data = data_bag_item("dns",domain)
  zones << {:domain => domain_data["zone"], :zonefile => "db.#{domain_data["zone"]}", :alsonotify => domain_data["zoneinfo"]["also-notify"], :allowtransfer => domain_data["zoneinfo"]["allow-transfer"], :type => domain_data["zoneinfo"]["type"]}
  local_records = Hash.new()
  if domain_data["zone"] == node["bind"]["defaultdomain"]
    local_records = records
  else
   
  end
  domain_data["records"].each do |record|
    local_records[record["name"] + record["type"]] = record
  end
  local_records.each do |key,value|
    begin
      value["ipaddr"] = IPAddr.new(value["info"])
    rescue ArgumentError
      value["ipaddr"] = IPAddr.new("255.255.255.255")
    end
      
  end
  sorted_local_records = local_records.values.sort{|m,n| m["ipaddr"] <=> n["ipaddr"]}
  template "/etc/bind/db.#{domain_data["zone"]}" do 
    source "zone.erb"
    owner "root"
    mode 0644
    variables(
      :domain => domain_data["zone"],
      :ttl => domain_data["options"]["ttl"],
      :serial => Time.now().tv_sec,
      :refresh => domain_data["options"]["refresh"],
      :retr => domain_data["options"]["retry"],
      :expire => domain_data["options"]["expire"],
      :minimum => domain_data["options"]["minimum_ttl"],
      :records => sorted_local_records,
      :nameservers => domain_data["nameservers"],
      :append => domain_data["append"]
    )
#    notifies :restart, "service[bind9]"
    notifies :run, "execute[rndc-reload]"
  end
end

pp zones

template "/etc/bind/named.conf.local" do
  source "named.conf.local.erb"
  owner "root"
  mode 0644
  variables(
    :zones => zones
  )
end

execute "rndc-reload" do
  command "rndc reload"
  action :nothing
end

service "bind9" do
  supports :reload => true
  reload_command "service bind9 reload"
#  action :enable
#  supports  :reload => true
#  reload_command  "rndc reload"
#  provider Chef::Provider::Service::Upstart
end