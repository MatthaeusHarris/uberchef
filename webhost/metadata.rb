maintainer       "Matt Harris"
maintainer_email "raven@uberduck.net"
license          "All rights reserved"
description      "Uses providers in the opsocde apache2 recipe to set up virtualhosts"
long_description IO.read(File.join(File.dirname(__FILE__), 'README.rdoc'))
version          "0.0.1"
depends          "apache2"
depends          "apache2::php5"
depends          "apache2::mod_rewrite"
