#!/bin/bash
########################
echo " delete logs"
echo "---------------------------------------"
sudo find /var/log/  -mindepth 1 -daystart -mtime +7 -type f -delete
echo "---------------------------------------"
echo " disk usage"
echo "---------------------------------------"
df -hl|awk '{print $5  $6}'|sed -n '/\/home$/p'
df -hl|awk '{print $5  $6}'|sed -n '/\/var/p'
df -hl|awk '{print $5  $6}'|sed -n '/\/$/p'|uniq
df -hl|awk '{print $5  $6}'|sed -n '/\/usr/p'
df -hl|awk '{print $5  $6}'|sed -n '/\/tmp/p'
echo "---------------------------------------"
echo " is there zombie process?"
echo "---------------------------------------"
zp_num=$(ps aux|grep Z|grep -v grep|sed -n '2p'|wc -l)
if [ $zp_num -eq 0 ]
then
	echo " no zombie process"
fi
echo "---------------------------------------"
echo "cpu useage %"
echo "cpu model and numbers"
cat /proc/cpuinfo |grep 'model name'|uniq
cat /proc/cpuinfo |grep 'physical id'|sort -u|wc -l
echo "---------------------------------------"
#top -n 3
w
for i in $(seq 3)
do 	
	vmstat
done
echo "---------------------------------------"
echo " mem usage %"
free -m
echo "---------------------------------------"
free -m | sed -n '2p'|awk '{print $3/$2"%"}'
echo "---------------------------------------"
echo "disk io"
iostat
if [ $? -eq 127 ]
then
	sudo apt-get   install -y sysstat >/dev/null
	iostat
fi
echo "---------------------------------------"
echo "end"
