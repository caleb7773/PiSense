#!/bin/bash



# Enable CGI Scripts on Apache
sudo ln -s /etc/apache2/mods-available/cgi.load /etc/apache2/mods-enabled/
sudo systemctl enable apache2
sudo systemctl restart apache2

# Create CGI Script
sudo tee -a /usr/lib/cgi-bin/wanip.cgi << EOF
#!/bin/bash
echo "Content-type: text/html"
echo ""
echo "<html>"
echo "<meta http-equiv="refresh" content="4\;url=../index.html" />"
echo "<head><title>WAN IP"
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
echo "<h2><a href="../index.html">Return to Main Menu</a></h3>"

echo "</body></html>"
EOF


# Give it execute rights
sudo chmod +x /usr/lib/cgi-bin/wanip.cgi

# Generate Service Script
sudo tee -a /usr/lib/cgi-bin/sshon.cgi << EOF
#!/bin/bash
echo "Content-type: text/html"
echo ""
echo "<html>"
echo "<meta http-equiv="refresh" content="4\;url=../index.html" />"
echo "<head><title>SSH On"
echo "</title></head><body>"


echo "<h1> SSH Status </h1>"
echo "\$(sudo systemctl start ssh)"
echo "\$(sudo systemctl status ssh | grep 'Active:')"

echo "<br>"
echo "<br>"
echo "\$(date)"
echo "<h2><a href="../index.html">Return to Main Menu</a></h3>"

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
echo "<meta http-equiv="refresh" content="4\;url=../index.html" />"
echo "<head><title>SSH Off"
echo "</title></head><body>"


echo "<h1> SSH Status </h1>"
echo "\$(sudo systemctl stop ssh)"
echo "\$(sudo systemctl status ssh | grep 'Active:')"

echo "<br>"
echo "<br>"
echo "\$(date)"
echo "<h2><a href="../index.html">Return to Main Menu</a></h3>"

echo ""
echo "</body></html>"
EOF

# Give it execute rights
sudo chmod +x /usr/lib/cgi-bin/sshoff.cgi

# Generate Service Script
sudo tee -a /usr/lib/cgi-bin/vpnon.cgi << EOF
#!/bin/bash
echo "Content-type: text/html"
echo ""
echo "<html>"
echo "<meta http-equiv="refresh" content="4\;url=../index.html" />"
echo "<head><title>VPN On"
echo "</title></head><body>"


echo "<h1> VPN Status </h1>"
echo "\$(sudo sed -i 's/FF0000/7CFC00/g' /usr/lib/cgi-bin/wanipsimple.cgi)"
echo "\$(sudo iptables -t nat -F POSTROUTING)"
echo "\$(sudo iptables -t nat -A POSTROUTING -s 192.168.254.0/29 -o pine0 -j MASQUERADE)"
echo "\$(sudo systemctl start openvpn@client1)"
echo "\$(sudo systemctl status openvpn@client1 | grep 'Active:')"

echo "<br>"
echo "<br>"
echo "\$(date)"
echo "<h2><a href="../index.html">Return to Main Menu</a></h3>"

echo ""
echo "</body></html>"
EOF

# Give it execute rights
sudo chmod +x /usr/lib/cgi-bin/vpnon.cgi

# Generate Service Script
sudo tee -a /usr/lib/cgi-bin/vpnoff.cgi << EOF
#!/bin/bash
echo "Content-type: text/html"
echo ""
echo "<html>"
echo "<meta http-equiv="refresh" content="4\;url=../index.html" />"
echo "<head><title>VPN Off"
echo "</title></head><body>"


echo "<h1> VPN Status </h1>"
echo "\$(sudo sed -i 's/7CFC00/FF0000/g' /usr/lib/cgi-bin/wanipsimple.cgi)"
echo "\$(sudo systemctl stop openvpn@client1)"
echo "\$(sudo systemctl status openvpn@client1 | grep 'Active:')"

echo "<br>"
echo "<br>"
echo "\$(date)"
echo "<h2><a href="../index.html">Return to Main Menu</a></h3>"

echo ""
echo "</body></html>"
EOF

# Give it execute rights
sudo chmod +x /usr/lib/cgi-bin/vpnoff.cgi

# Generate Service Script
sudo tee -a /usr/lib/cgi-bin/vpnstat.cgi << EOF
#!/bin/bash
echo "Content-type: text/html"
echo ""
echo "<html>"
echo "<meta http-equiv="refresh" content="4\;url=../index.html" />"
echo "<head><title>VPN Status"
echo "</title></head><body>"


echo "<h1> VPN Status </h1>"
echo "\$(sudo systemctl status openvpn@client1 | grep 'Active:')"

echo "<br>"
echo "<br>"
echo "\$(date)"
echo "<h2><a href="../index.html">Return to Main Menu</a></h3>"

echo ""
echo "</body></html>"
EOF

# Give it execute rights
sudo chmod +x /usr/lib/cgi-bin/vpnstat.cgi


# Generate Service Script
sudo tee -a /usr/lib/cgi-bin/sshstat.cgi << EOF
#!/bin/bash
echo "Content-type: text/html"
echo ""
echo "<html>"
echo "<meta http-equiv="refresh" content="4\;url=../index.html" />"
echo "<head><title>SSH Status"
echo "</title></head><body>"


echo "<h1> SSH Status </h1>"
echo "\$(sudo systemctl status ssh | grep 'Active:')"

echo "<br>"
echo "<br>"
echo "\$(date)"
echo "<h2><a href="../index.html">Return to Main Menu</a></h3>"

echo ""
echo "</body></html>"
EOF

# Give it execute rights
sudo chmod +x /usr/lib/cgi-bin/sshstat.cgi


# Generate Service Script
sudo tee -a /usr/lib/cgi-bin/pubip.cgi << EOF
#!/bin/bash
echo "Content-type: text/html"
echo ""
echo "<html>"
echo "<meta http-equiv="refresh" content="4\;url=../index.html" />"
echo "<head><title>Public IP"
echo "</title></head><body>"


echo "<h1> Public IP </h1>"
echo "\$(curl ipinfo.io)"

echo "<br>"
echo "<br>"
echo "\$(date)"
echo "<h2><a href="../index.html">Return to Main Menu</a></h3>"

echo ""
echo "</body></html>"
EOF

# Give it execute rights
sudo chmod +x /usr/lib/cgi-bin/pubip.cgi

# Generate Service Script
sudo tee -a /usr/lib/cgi-bin/shutdown.cgi << EOF
#!/bin/bash
echo "Content-type: text/html"
echo ""
echo "<html>"
echo "<meta http-equiv="refresh" content="4\;url=../index.html" />"
echo "<head><title>Shutdown"
echo "</title></head><body>"


echo "<h1> Shutting Down... </h1>"
echo "\$(sudo shutdown -h now)"
echo "<br>"
echo "\$(date)"
echo "<h2><a href="../index.html">Return to Main Menu</a></h3>"

echo ""
echo "</body></html>"
EOF

# Give it execute rights
sudo chmod +x /usr/lib/cgi-bin/shutdown.cgi

# Generate Service Script
sudo tee -a /usr/lib/cgi-bin/reboot.cgi << EOF
#!/bin/bash
echo "Content-type: text/html"
echo ""
echo "<html>"
echo "<meta http-equiv="refresh" content="4\;url=../index.html" />"
echo "<head><title>Rebooting"
echo "</title></head><body>"


echo "<h1> Rebooting PiSense... </h1>"
echo "\$(sudo reboot)"
echo "<br>"
echo "\$(date)"
echo "<h2><a href="../index.html">Return to Main Menu</a></h3>"

echo ""
echo "</body></html>"
EOF

# Give it execute rights
sudo chmod +x /usr/lib/cgi-bin/reboot.cgi

# Generate Service Script
sudo tee -a /usr/lib/cgi-bin/bypass.cgi << EOF
#!/bin/bash
echo "Content-type: text/html"
echo ""
echo "<html>"
echo "<meta http-equiv="refresh" content="4\;url=../index.html" />"
echo "<head><title>Bypass"
echo "</title></head><body>"


echo "<h1> VPN Bypass </h1>"
echo "\$(sudo sed -i 's/7CFC00/FF0000/g' /usr/lib/cgi-bin/wanipsimple.cgi)"
echo "\$(sudo systemctl stop openvpn@client1)"
echo "\$(sudo systemctl status openvpn@client1 | grep 'Active:')"
echo "\$(sudo iptables -t nat -F POSTROUTING)"
echo "\$(sudo iptables -t nat -A POSTROUTING -s 192.168.254.0/29 -o eth0 -j MASQUERADE)"
echo "<br>"
echo "\$(date)"
echo "<h2><a href="../index.html">Return to Main Menu</a></h3>"

echo ""
echo "</body></html>"
EOF

# Give it execute rights
sudo chmod +x /usr/lib/cgi-bin/bypass.cgi

# Generate Service Script
sudo tee -a /usr/lib/cgi-bin/wanipsimple.cgi << EOF
#!/bin/bash
echo "Content-type: text/html"
echo ""
echo "<html>"
echo "<head><title>WAN IP"
echo "</title>"
echo "<style>"
echo "body {"
echo "  background-color: #7CFC00;"
echo "}"
echo "</style>"
echo "</head><body>"
echo "\$(curl ipinfo.io > /tmp/pubip)"
echo "Public IP : \$(grep -m 1 ip /tmp/pubip | cut -d '\"' -f 4)"
echo "<br>"
echo "Location : \$(grep -m 1 city /tmp/pubip | cut -d '\"' -f 4), \$(grep -m 1 region /tmp/pubip | cut -d '\"' -f 4)"
echo "<br>"
echo "<br>"
echo "\$(ifconfig | grep -A 1 eth0 | grep inet > /tmp/ip)"
echo "\$(sed -i 's/netmask.*\$//g' /tmp/ip)"
echo "\$(sed -i 's/inet //g' /tmp/ip)"
echo "WAN IP : \$(cat /tmp/ip)"
echo "<br>"
echo "\$(sudo systemctl status openvpn@client1 | grep 'Active:' | cut -d '(' -f1 | cut -d ')' -f1 > /tmp/vpnstat)"
echo "\$(sed -i 's/Active/VPN\ Status/g' /tmp/vpnstat && cat /tmp/vpnstat)"
echo "<br>"
echo "\$(sudo systemctl status ssh | grep 'Active:' | cut -d '(' -f1 | cut -d ')' -f1 > /tmp/sshstat)"
echo "<br>"
echo "\$(sed -i 's/Active/SSH\ Status/g' /tmp/sshstat && cat /tmp/sshstat)"
echo "</body></html>"
EOF

# This is just making the code editor not freak out about something above that pissed it off
sudo sed -i 's/\\"/"/g' /usr/lib/cgi-bin/wanipsimple.cgi

# Give it execute rights
sudo chmod +x /usr/lib/cgi-bin/wanipsimple.cgi

# Generate an input html page that will be used be the cgi script
sudo tee -a /var/www/html/input.html << EOF
<HTML>
<head><title>Input Form</title></head>
<body>
<H1> Input Form </H1>
<FORM METHOD=GET ACTION="./cgi-bin/input.cgi" >
IP to Ping: <INPUT TYPE="text" Name="pingip" size=40 maxlength=50>
<br>
Last Name: <INPUT TYPE="text" Name="last" size=40 maxlength=50>
<br>
<INPUT TYPE="submit" value="Submit Form">
<INPUT TYPE="reset" value="Clear Form">
</form>
<hr>
</body>
</html>
EOF


# Generate a cgi script that utilizes the html inputs previously grabbed
sudo tee -a /usr/lib/cgi-bin/input.cgi << EOF
#!/bin/bash
echo "Content-type: text/html"
echo ""
echo "<html>"
echo "<head><title>Input Form"
echo "</title></head><body>"


echo "<h1> Input Form </h1>"
echo \$QUERY_STRING | cut -d '=' -f 2 | cut -d '&' -f 1 > /tmp/first
first=\$(cat /tmp/first)
echo "<br>"
echo "\$(echo \$first)"
echo \$QUERY_STRING | cut -d '=' -f 3 | cut -d '&' -f 1 > /tmp/second
second=\$(cat /tmp/second)
echo "<br>"
echo "\$(echo \$second)"
echo "\$(sudo ping \${first} -c 4 > /tmp/pingresult)"
echo "\$(pingres=\$(cat /tmp/pingresult))"
echo "\$(if [[ \$pingres ~= *64 bytes* ]]; then echo "Ping Success"; else echo "Ping Failed"; fi)"
echo "\$(cat /tmp/pingresult)"
echo "<br>"
echo "\$(date)"
echo "<h2><a href="../index.html">Return to Main Menu</a></h3>"

echo ""
echo "</body></html>"
EOF

# Give it execute rights
sudo chmod +x /usr/lib/cgi-bin/input.cgi




# Restart the apache service
sudo systemctl restart apache2

# Set www-data to no password sudo permissions
echo '' | sudo EDITOR='tee -a' visudo
echo '%www-data ALL=NOPASSWD: /usr/bin/systemctl start ssh, /usr/bin/systemctl stop ssh, /usr/bin/systemctl status ssh' | sudo EDITOR='tee -a' visudo
echo '%www-data ALL=NOPASSWD: /usr/bin/systemctl start openvpn@client1, /usr/bin/systemctl stop openvpn@client1, /usr/bin/systemctl status openvpn@client1' | sudo EDITOR='tee -a' visudo
echo '%www-data ALL=NOPASSWD: /usr/sbin/shutdown -h now, /usr/sbin/reboot' | sudo EDITOR='tee -a' visudo
echo '%www-data ALL=NOPASSWD: /usr/sbin/iptables -t nat -A POSTROUTING -s 192.168.254.0/29 -o pine0 -j MASQUERADE, /usr/sbin/iptables -t nat -A POSTROUTING -s 192.168.254.0/29 -o eth0 -j MASQUERADE' | sudo EDITOR='tee -a' visudo
echo '%www-data ALL=NOPASSWD: /usr/sbin/iptables -t nat -F POSTROUTING' | sudo EDITOR='tee -a' visudo
echo '%www-data ALL=NOPASSWD: /usr/bin/sed -i 's/7CFC00/FF0000/g' /usr/lib/cgi-bin/wanipsimple.cgi' | sudo EDITOR='tee -a' visudo
echo '%www-data ALL=NOPASSWD: /usr/bin/sed -i 's/FF0000/7CFC00/g' /usr/lib/cgi-bin/wanipsimple.cgi' | sudo EDITOR='tee -a' visudo
echo '%www-data ALL=NOPASSWD: /bin/ping' | sudo EDITOR='tee -a' visudo


# Delete default HTML index file
sudo rm -rf /var/www/html/index.html

# Generate new index HTML file
sudo tee -a /var/www/html/index.html << EOF
<Content-type: text/html>

<html>
<meta http-equiv="refresh" content="10;url=index.html" />
<head>
<title>PiSense</title>
</head>
<body>
<h1>Welcome to PiSense</h1>
<br>
<iframe src="./cgi-bin/wanipsimple.cgi" width="300" height="200"></iframe>
<br>
<a href="./cgi-bin/wanip.cgi">WAN IP Information</a>
<br>
<a href="./cgi-bin/pubip.cgi">What is my Public IP</a>
<br>
<a href="./cgi-bin/vpnstat.cgi">VPN Status</a>
<br>
<a href="./cgi-bin/vpnon.cgi">Turn VPN On</a> (autostart by default)
<br>
<a href="./cgi-bin/vpnoff.cgi">Turn VPN Off</a>
<br>
<a href="./cgi-bin/bypass.cgi">Allow VPN Bypass</a>
<br>
<a href="./input.html">Ping Test</a>
<br>
<a href="./cgi-bin/sshstat.cgi">SSH Status</a>
<br>
<a href="./cgi-bin/sshon.cgi">Turn SSH On</a>
<br>
<a href="./cgi-bin/sshoff.cgi">Turn SSH Off</a> (off by default)
<br>
<br>
<a href="./cgi-bin/shutdown.cgi">Safe Shutdown</a>
<br>
<a href="./cgi-bin/reboot.cgi">Reboot</a>
</body>
EOF


# Green to Red Background
#sudo sed -i 's/7CFC00/FF0000/g' /var/www/html/index.html

# Red to Green Background
#sudo sed -i 's/FF0000/7CFC00/g' /var/www/html/index.html


# Set Hostname
sudo hostnamectl set-hostname PiSense
sudo sed -i 's/kali/PiSense/g' /etc/hosts
