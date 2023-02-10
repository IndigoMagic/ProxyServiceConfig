#!/usr/bin/env bash
yum -y update
yum -y install epel-release python-setuptools m2crypto firewalld
easy_install pip
pip install #service-name# #service-name#替换为网络代理服务的名称

echo "Preparations have been completed！"
echo "input server_port(do not overlap with existing ports)"
echo "[default server_port: 45678]"
read -p "input server_port: " server_port

if [[ -z ${server_port} ]];then
server_port="45678"
echo "server_port is default!"
while true
do
    check_result=`netstat -apn | grep ${server_port}`
    echo ${check_result}
    if [[ -z ${check_result} ]];then
    echo "port ${server_port} is not used"
    echo "set server_port is ok!"
    break
    else
    echo "port ${server_port} is used"
    echo "Please select another port that is not occupied(like 40000-60000)"
    read -p "input server_port: " server_port
    fi
done
else
echo $server_port
while true
do
    check_result=`netstat -apn | grep ${server_port}`
    echo ${check_result}
    if [[ -z ${check_result} ]];then
    echo "port ${server_port} is not used"
    echo "set server_port is ok!"
    break
    else
    echo "port ${server_port} is used"
    echo "Please select another port that is not occupied(like 40000-60000)"
    read -p "input server_port: " server_port
    fi
done
fi


read -p "input password: " -s password

cat>>/etc/#service-name#.json<<EOF
{
    "server":"0.0.0.0",
    "server_port":${server_port},
    "local_port":1080,
    "password":"${password}",
    "timeout":600,
    "method":"aes-256-cfb"
}
EOF
echo "#service-name# info have set up!"
cat>>/etc/rc.local<<EOF
ssserver -c /etc/#service-name#.json -d start
EOF
echo "#service-name# starts up automatically!"
systemctl start firewalld
echo "firewalld started!"
firewall-cmd --permanent --zone=public --add-port=${server_port}/tcp
firewall-cmd --reload
ssserver -c /etc/#service-name#.json -d start
echo "#service-name# service started!"
