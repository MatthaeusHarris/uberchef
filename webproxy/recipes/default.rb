#
# Cookbook Name:: webproxy
# Recipe:: default
#
# Copyright 2011, Matt Harris
#
# All rights reserved
#

require "pp"

webhosts = search(:node, "virtualhosts:*")

webhosts.each do |w|
  pp w["ipaddress"]
  w['virtualhosts'].each do |k, v|
    pp v
    template "/etc/apache2/sites-available/#{k}.conf" do
      source "proxyhost.erb"
      variables(
        :servername => v['server_name'],
        :serveraliases => v['server_aliases'],
        :hostip => w['ipaddress']
      )
      notifies :reload, "service[apache2]"
    end
    
    link "/etc/apache2/sites-enabled/#{k}.conf" do
      to "/etc/apache2/sites-available/#{k}.conf"
      notifies :reload, "service[apache2]"
    end
    
  end
end

template "/etc/apache2/mods-available/proxy.conf" do
	source "proxy.conf.erb"
	notifies :reload, "service[apache2]"
end
