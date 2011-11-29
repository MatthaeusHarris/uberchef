#
# Cookbook Name:: postfixadmin
# Recipe:: default
#
# Copyright 2011, Matthew Harris
#
# All rights reserved
#

default["postfixadmin"]["version"] = "2.3.4"
default["postfixadmin"]["url"] = "http://downloads.sourceforge.net/project/postfixadmin/postfixadmin/postfixadmin-2.3.4/postfixadmin_2.3.4.tar.gz"
default["postfixadmin"]["hash"] = "6ac663e2f4bd8bfbe7daaf759b18071d915efd242fe13964561da94f18c82ec6"
default["postfixadmin"]["webroot"] = "/var/www/postfixadmin"
default["postfixadmin"]["database"]["host"] = "mysql"
default["postfixadmin"]["database"]["database"] = "postfixadmin"
default["postfixadmin"]["database"]["user"] = "postfixadmin"
default["postfixadmin"]["admin"]["password"] = "changeme"


