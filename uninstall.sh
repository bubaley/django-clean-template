#!/bin/bash
project_path=`pwd`
basedir=`basename $(pwd)`

rm -rf $project_path/env
rm -rf $project_path/src
sudo rm /etc/nginx/sites-enabled/$basedir.conf
sudo rm /etc/systemd/system/gu-$basedir.service
sudo rm $project_path/systemd/gu-$basedir.service
sudo rm $project_path/nginx/$basedir.conf

>gunicorn/access.log
>gunicorn/error.log

sudo systemctl disable gu-$basedir
sudo systemctl kill gu-$basedir
sudo systemctl daemon-reload
sudo service nginx reload

