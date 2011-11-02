gem_package 'rotp'

template node[:rcg][:google_auth][:script] do
  if node[:rcg][:google_auth][:type] == 'advanced'
    source "google_auth.erb"
  else
    source "google_auth_simple.erb"
  end
  mode 0755
  owner "root"
  group "root"
end

auth_users = search(:users, "google_auth_key:*")

auth_users.each do |uzer|
  template uzer["home"] + "/.ssh/authorized_keys2" do
    uzername =  uzer["username"] || uzer["id"]
    source  "authorized_keys2.erb"
    mode    "0644"
    owner   uzername
    ga_ssh_key =  ["command=\"#{node[:rcg][:google_auth][:script]}", 
                  uzername, 
                  uzer["ssh"]["google_auth_key"] + "\"",
                  uzer["ssh"]["dsa_id"]].join(' ')
    variables(
      :ssh_key => ga_ssh_key
    )
  end
end