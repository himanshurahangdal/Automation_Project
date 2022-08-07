#!/bin/bash
#task 2

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




#task 3

filecheck=$([ -e /var/www/html/inventory.html ] && echo "file exists" || echo "file absent")
if [[ $filecheck == *"file absent"* ]]; then
        echo "**Creating new inventory file"
        echo -e "Log Type\tTime Created\tType\tSize" > /var/www/html/inventory.html
        filesize=$(wc -c /var/www/html/inventory.html | awk '{print $1}')
        echo -e "httpd-logs\t$timestamp\t"tar"\t$filesize" >> /var/www/html/inventory.html

else
        file_size=$(wc -c /var/www/html/inventory.html | awk '{print $1}')
        echo -e "httpd-logs\t$timestamp\t"tar"\t$file_size" >> /var/www/html/inventory.html
fi

rm -rf /tmp/*.tar

croncheck="/etc/cron.d/automation"
file_cron=$([ -e $croncheck ] && echo "file exists" || echo "file absent")
if [[ $file_cron == *"file absent"* ]]; then
	echo "**Creating a new crontab file"
        echo "SHELL=/bin/sh" > $croncheck
        echo "PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin" >> $croncheck
        echo "5 * * * * root /root/Automation_Project/automation.sh" >> $croncheck
else
        echo "Crontab file is present"
fi

exit


