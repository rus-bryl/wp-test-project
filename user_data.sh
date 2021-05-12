#!/bin/bash

sudo apt update
sudo apt install lamp -y

myip=`curl https://ipinfo.io/ip`

cat <<EOF > /var/www/html/index.html
<html>
<body bgcolor="black">
<h2><font color="gold">Build by Power Terraform <font color="red"> v0.12</font></h2><br><p>
<font color="green">Server IP: <font color="aqua">$myip<br><br>

<font color="magenta">
<b>Version 3.0</b>
</body>
</html>
EOF

sudo service httpd start
chkconfig httpd on
