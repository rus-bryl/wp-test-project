#!/bin/bash

sudo apt update
sudo apt install apache2 -y

myip=`curl https://ipinfo.io/ip`

echo "ServerName localhost"> /etc/apache2/apache2.conf
cat <<EOF > /var/www/html/index.html
<html>
<body bgcolor="black">
<center>
<h2><font color="gold">WordPress will be here little bit later... </h2><br><p>
<font color="green">Server IP: <font color="aqua">$myip<br><br>

<font color="magenta">
<b>Version 3.0</b>
</center>
</body>
</html>
EOF

sudo systemctl start apache2
sudo systemctl enable apache2
chkconfig httpd on
