#!/usr/bin/env python

from datetime import *

lsb = []
fh = open( '/etc/lsb-release' )
lsb = fh.readlines()
fh.close()

codename = lsb[2].split( '=' )[1].strip()

description = lsb[3].split( '=' )[1].strip().strip( "\"" )
dist_date = lsb[1].split( '=' )[1].strip().split( '.' )

release_date = datetime( 2000 + int( dist_date[0] ), int( dist_date[1] ), 1 )

if description[-3:] == "LTS":
	years = 4
else:
	years = 2

expire_date = release_date + timedelta( days = 365 * years )

remaining = expire_date - datetime.now()
if remaining <= timedelta( 0 ):
	print "Distribution is out of date by %s days - %s(%s)" % (remaining.days, description,codename)
else:
	print "Distribution is ok. Expires in %s days - %s(%s)" % (remaining.days, description,codename)
