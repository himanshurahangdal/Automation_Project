#!/bin/bash


s3_bucket="upgraad-himanshurahangdale"
myname="himanshu"
timestamp=$(date '+%d%m%Y-%H%M%S')

check_apache=$(sudo dpkg --get-selections | grep -m 1 apache2)
ct=$(echo $check_apache| grep -c "apache2")
#
if [ "$ct" -gt "0" ]; then
	echo 'apache2 is already installed on this machine'
else
  sudo apt update -y
	sudo apt install apache2 -y
fi


apache_status=$(systemctl status apache2 | grep -m 1 "Active")


if [[ $apache_status == *"(running)"* ]]; then
	echo "apache2 is already Active and running"
else
	systemctl start apache2
fi	


is_apache_enable=$(systemctl is-enabled apache2 | grep -m 1 "enabled")

if [[ $is_apache_enable == *"enabled"* ]];
then
  echo 'apache service is enabled'
else
  systemctl enable apache2
fi



tar -cvf /tmp/${myname}-httpd-logs-${timestamp}.tar /var/log/apache2/*.log

aws s3 \
cp /tmp/${myname}-httpd-logs-${timestamp}.tar \
s3://${s3_bucket}/${myname}-httpd-logs-${timestamp}.tar

