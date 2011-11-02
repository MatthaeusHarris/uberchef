define :nrpe_cmd, :script_name => nil, :script_params => {}, :cookbook => "nagios", :path => "any" do
  if params[:copy_script]:
	  cookbook_file "#{node[:nagios][:nrpe_plugind]}/#{params[:script_name]}" do
	    backup 0
	    group "nagios"
	    owner "nagios"
	    mode 0744
	    source "plugins/#{params[:path]}/#{params[:script_name]}"
	  end
  end

  template "#{node[:nagios][:nrpe_confd]}/#{params[:name]}.cfg" do
    owner "nagios"
    group "nagios"
    source "nrpe_check.cfg.erb"
    cookbook params[:cookbook]
    mode 0644
    variables :cmd_name => params[:name], :script_name => params[:script_name], :script_params => params[:script_params]
    notifies :restart, resources(:service => "nagios-nrpe-server")
    backup 0
  end
end
