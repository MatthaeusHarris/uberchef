require "pp"

define :rcg_user do
#  pp params
  useritem = data_bag_item("users",params[:name])
#  pp useritem["ssh"]["dsa_id"]
  useritem["username"] = params[:name] unless useritem["username"]
  user useritem["username"] do
    comment     useritem["comment"]
    uid         useritem["uid"]
    gid         useritem["gid"]
    home        useritem["home"]
    shell       useritem["shell"]
    password    useritem["password"]
    supports    :manage_home => true
  end
  
  directory useritem["home"] do
    owner   useritem["username"]
    group   useritem["gid"].to_s
    mode    "0700"
  end
  
  directory useritem["home"] + "/.ssh" do
    owner   useritem["username"]
    group   useritem["gid"].to_s
    mode    "0700"
  end
  
  template useritem["home"] + "/.ssh/authorized_keys2" do
    source  "authorized_keys2.erb"
    mode    "0644"
    owner   useritem["username"]
    variables(
      :ssh_key => useritem["ssh"]["dsa_id"]
    )
  end
end