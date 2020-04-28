#!/bin/bash
base_python=""
default_python="/home/www/.python/bin/python3.8"
project_domain=""
project_path=`pwd`
basedir=`basename $(pwd)`
git_url=""

read -p "Python interpreter (default=$default_python): " base_python
if [ "$base_python" = "" ]
then
	base_python=$default_python
fi

read -p "Your domain without protocol (for example, google.com): " project_domain
read -p "Git url to your django-project: " git_url

$base_python -m venv env
source env/bin/activate
pip install -U pip
pip install gunicorn
git clone $git_url src
pip install -r src/requirements.txt

cp nginx/site.conf nginx/$basedir.conf
cp systemd/gunicorn.service systemd/gu-$basedir.service

sed -i "s~template_domain~$project_domain~g" nginx/$basedir.conf
sed -i "s~template_path~$project_path~g" nginx/$basedir.conf systemd/gu-$basedir.service

if [ -e "/etc/nginx/sites-enabled/$basedir.conf" ]
then
	echo "Ссылка для nginx уже создана"
else
	sudo ln -s $project_path/nginx/$basedir.conf /etc/nginx/sites-enabled/
fi

if [ -e "/etc/systemd/system/gu-$basedir.service" ]
then
	echo "Ссылка на сервис уже существует"
else
	sudo ln -s  $project_path/systemd/gu-$basedir.service /etc/systemd/system/
fi

random_str=`sudo head /dev/urandom | tr -dc "A-Za-z0-9!#$%&()*+,-./:;<=>?@[\]^_{|}~" | fold -w 50 | head -n 1`
env_path="$project_path/src/core/settings/.env"
echo "SECRET_KEY=$random_str" >> $env_path
echo "ALLOWED_HOST=$project_domain"

sudo systemctl daemon-reload
sudo systemctl start gu-$basedir
sudo systemctl enable gu-$basedir
sudo service nginx restart

setup_ssl=""
read -p "Do you want to install ssl? (y/n): " setup_ssl
if [ "$setup_ssl" = "y"  ]
then
sudo apt-get update
sudo apt-get install software-properties-common
sudo add-apt-repository universe
sudo add-apt-repository ppa:certbot/certbot
sudo apt-get update
sudo apt-get install certbot python-certbot-nginx
sudo certbot --nginx
fi
