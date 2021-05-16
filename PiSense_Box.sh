#!/bin/bash

# Enable CGI Scripts on Apache
sudo ln -s /etc/apache2/mods-available/cgi.load /etc/apache2/mods-enabled/
sudo systemctl restart apache2

# Create CGI Script
sudo tee -a /usr/lib/cgi-bin/third.cgi << EOF
#!/bin/bash
echo "Content-type: text/html"
echo ""
echo "<html><head><title>Bash as CGI"
echo "</title></head><body>"

echo "<h1>IP Information</h1>"
echo "\$(ifconfig | grep eth0 > /tmp/int)"
echo "\$(ifconfig | grep -A 1 eth0 | grep inet > /tmp/ip)"
echo "\$(sed -i 's/netmask.*\$//g' /tmp/ip)"
echo "\$(sed -i 's/inet //g' /tmp/ip)"

echo "<h2> Interface </h2>"
echo "\$(cat /tmp/int | cut -d ':' -f1)"
echo "<br>"
echo "<h2> IP </h2>"
echo "\$(cat /tmp/ip)"
echo "<br>"
echo "<br>"
echo "<br>"
echo "\$(date)"
echo ""

echo "</body></html>"
EOF


# Give it execute rights
sudo chmod +x /usr/lib/cgi-bin/third.cgi

# Restart the apache service
sudo systemctl restart apache2
