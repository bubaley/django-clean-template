#!/bin/bash
base_python=""
default_python="/home/www/.python/bin/python3.8"
project_domain=""
project_path=`pwd`
basedir=`basedir $(pwd)`
pulled_project=""

echo $project_path

read -p "Python interpreter (default=$default_python): " base_python
if [ "$base_python" = "" ]
then
base_python=$default_python
fi

read -p "Your domain without protocol (for example, google.com): " project_domain
read -p "Did you pull your project to src? (y/n): " pulled_project

`$base_python -m venv env`
source env/bin/activate
pip install -U pip

if [ "$pulled_project"="y" ]
then
pip install -r src/requirements.txt
fi

cp nginx/site.conf nginx/$basedir.conf
cp systemd/gunicorn.service systemd/gu-$basedir.conf

sed -i "s~template_domain~$project_domain~g" nginx/$basedir.conf
sed -i "s~template_path~$project_path~g" nginx/$basedir.conf systemd/gu-$basdir.service


if [ -e "/etc/nginx/sites-enabled/$basedir.conf" ]
then
else 
sudo rm /etc/nginx/sites-enabled/$basedir.conf
fi
if [ -e "/etc/systemd/system/gu-$basedir.service" ]
then
else 
sudo rm /etc/nginx/sites-enabled/$basedir.conf
fi

sudo ln -s $project_path/nginx/$basedir.conf /etc/nginx/sites-enabled/
sudo ln -s $project_path/systemd/$basedir.service /etc/systemd/system/

sudo systemctl daemon-reload
sudo systemctl start gu-$basedir
sudo systemctl enable gu-$basedir
sudo service nginx restart
