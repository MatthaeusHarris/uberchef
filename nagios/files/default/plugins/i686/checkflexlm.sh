#!/bin/bash

output=`/usr/bin/perl /usr/local/nagios/libexec/check_flexlm.plx -H hopper.msu.montana.edu`
echo $output | /bin/grep CRITICAL
exitstatus=$?
if [ $exitstatus = "0" ]
then
	#/usr/bin/mailx -s 'FLEXlm Down' william.hosbein@gmail.com,vallardt@gmail.com,rocketman331@gmail.com < /var/log/flexoutput.txt
	echo "Fail"
fi


