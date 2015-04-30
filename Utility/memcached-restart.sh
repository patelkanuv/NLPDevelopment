#!/usr/bin/sh

sudo pkill memcached

sleep 2

sudo memcached -d -m 100 -u www-data -p 11211 -l 192.168.16.61 -t 8
sudo memcached -d -m 100 -u www-data -p 11212 -l 192.168.16.61 -t 8
