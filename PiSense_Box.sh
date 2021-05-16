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

# Generate Service Script
sudo tee -a /usr/lib/cgi-bin/sshon.cgi << EOF
#!/bin/bash
echo "Content-type: text/html"
echo ""
echo "<html>"
echo "<meta http-equiv="refresh" content="4\;url=http://localhost/" />"
echo "<head><title>Bash as CGI"
echo "</title></head><body>"


echo "<h1> SSH Status </h1>"
echo "$(sudo systemctl start ssh)"
echo "$(sudo systemctl status ssh | grep 'Active:')"

echo "<br>"
echo "<br>"
echo "$(date)"
echo "<h2><a href="http://localhost">Click here to return</a></h3>"

echo ""
echo "</body></html>"
EOF

# Give it execute rights
sudo chmod +x /usr/lib/cgi-bin/sshon.cgi

# Generate Service Script
sudo tee -a /usr/lib/cgi-bin/sshoff.cgi << EOF
#!/bin/bash
echo "Content-type: text/html"
echo ""
echo "<html>"
echo "<meta http-equiv="refresh" content="4\;url=http://localhost/" />"
echo "<head><title>Bash as CGI"
echo "</title></head><body>"


echo "<h1> SSH Status </h1>"
echo "$(sudo systemctl stop ssh)"
echo "$(sudo systemctl status ssh | grep 'Active:')"

echo "<br>"
echo "<br>"
echo "$(date)"
echo "<h2><a href="http://localhost">Click here to return</a></h3>"

echo ""
echo "</body></html>"
EOF

# Give it execute rights
sudo chmod +x /usr/lib/cgi-bin/sshoff.cgi



# Restart the apache service
sudo systemctl restart apache2

# Set www-data to no password sudo permissions
echo '%www-data ALL=NOPASSWD: ALL /usr/bin/systemctl start ssh, /usr/bin/systemctl stop ssh, /usr/bin/systemctl status ssh' | sudo EDITOR='tee -a' visudo
