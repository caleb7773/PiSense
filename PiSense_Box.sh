#!/bin/bash


# Color Changer Script # Changes to Red
#sudo sed -i 's/: #.*/: #FF0000;"/g' /usr/lib/cgi-bin/wanipsimple.cgi
# Color Changer Script # Changes to Green
#sudo sed -i 's/: #.*/: #7CFC00;"/g' /usr/lib/cgi-bin/wanipsimple.cgi


sudo apt install isc-dhcp-server openvpn apache2-bin net-tools -y
sudo apt install apache2 -y

# Setup DHCP Server
sudo rm -rf /etc/dhcp/dhcpd.conf

sudo tee -a /etc/dhcp/dhcpd.conf << EOF
# DHCP Server for Pine
option domain-name "pine";
option domain-name-servers 8.8.8.8, 1.1.1.1;
default-lease-time 600;
max-lease-time 7200;

ddns-update-style  none;
authoritative;

subnet 192.168.254.0 netmask 255.255.255.248 {
  range 192.168.254.2 192.168.254.6;
  option subnet-mask 255.255.255.248;
  option routers 192.168.254.1;
  option broadcast-address 192.168.254.7;
}
EOF

sudo rm -rf /etc/default/isc-dhcp-server
sudo tee -a /etc/default/isc-dhcp-server << EOF
INTERFACESv4="eth0"
EOF


sudo systemctl enable isc-dhcp-server
sudo systemctl start isc-dhcp-server

# Enable Forwarding
sudo tee -a /etc/sysctl.conf << EOF
net.ipv6.conf.all.disable_ipv6=1
net.ipv6.conf.default.disable_ipv6=1
EOF
sudo sed -i 's/#net.ipv4.ip_forward=1/net.ipv4.ip_forward=1/g' /etc/sysctl.conf && sudo sysctl -p


# Configure Interfaces in NetPlan
sudo rm -rf /etc/netplan/*


sudo tee -a /etc/netplan/02-eth1.yaml <<EOF
network:
    ethernets:
        eth1:
            optional: true
            dhcp4: yes
            dhcp6: no
    version: 2
EOF

sudo tee -a /etc/netplan/03-wlan0.yaml <<EOF
network:
    ethernets:
        wlan0:
            optional: true
            dhcp4: yes
            dhcp6: no
    version: 2
EOF


sudo tee -a /etc/netplan/01-eth0.yaml <<EOF
network:
    ethernets:
        eth0:
            optional: true
            dhcp4: no
            addresses:
                    - 192.168.254.1/29
    version: 2
EOF

sudo netplan apply





# Enable CGI Scripts on Apache
sudo chown -R www-data:www-data /var/www
sudo chmod go-rwx /var/www
sudo chmod go+x /var/www
sudo chgrp -R www-data /var/www
sudo chmod -R go-rwx /var/www
sudo chmod -R g+rx /var/www
sudo chmod -R g+rwx /var/www
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
echo "\$(ifconfig | grep eth1 > /tmp/int)"
echo "\$(ifconfig | grep -A 1 eth1 | grep inet > /tmp/ip)"
echo "\$(sed -i 's/netmask.*\$//g' /tmp/ip)"
echo "\$(sed -i 's/inet //g' /tmp/ip)"

echo "\$(ifconfig | grep wlan0 > /tmp/int1)"
echo "\$(ifconfig | grep -A 1 wlan0 | grep inet > /tmp/ip1)"
echo "\$(sed -i 's/netmask.*\$//g' /tmp/ip1)"
echo "\$(sed -i 's/inet //g' /tmp/ip1)"

echo "<h2> Interface </h2>"
echo "\$(cat /tmp/int | cut -d ':' -f1)"
echo "\$(cat /tmp/int1 | cut -d ':' -f1)"
echo "<br>"
echo "<h2> IP </h2>"
echo "\$(cat /tmp/ip)"
echo "\$(cat /tmp/ip1)"
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
echo "\$(sudo systemctl stop ssh)"
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
echo "\$(sudo systemctl stop openvpn@client1)"
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
echo "\$(sudo iptables -t nat -A POSTROUTING -s 192.168.254.0/29 -o eth1 -j MASQUERADE)"
echo "\$(sudo iptables -t nat -A POSTROUTING -s 192.168.254.0/29 -o wlan0 -j MASQUERADE)"
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
echo "  background-color: #FF0000;"
echo "}"
echo "</style>"
echo "</head><body>"
echo "\$(curl ipinfo.io > /tmp/pubip)"
echo "Public IP : \$(grep -m 1 ip /tmp/pubip | cut -d '\"' -f 4)"
echo "<br>"
echo "Location : \$(grep -m 1 city /tmp/pubip | cut -d '\"' -f 4), \$(grep -m 1 region /tmp/pubip | cut -d '\"' -f 4)"
echo "<br>"
echo "<br>"
echo "\$(ifconfig | grep -A 1 eth1 | grep inet > /tmp/ip)"
echo "\$(sed -i 's/netmask.*\$//g' /tmp/ip)"
echo "\$(sed -i 's/inet //g' /tmp/ip)"
echo "\$(ifconfig | grep -A 1 wlan0 | grep inet > /tmp/ip1)"
echo "\$(sed -i 's/netmask.*\$//g' /tmp/ip1)"
echo "\$(sed -i 's/inet //g' /tmp/ip1)"
echo "WAN IP : \$(cat /tmp/ip /tmp/ip1)"
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

echo "\$(sudo ping \${first} -c 4 > /tmp/pingresult)"
echo "\$(grep '64 bytes' /tmp/pingresult > /tmp/outres)"
echo "\$(if [[ -s /tmp/outres ]]; then echo 'Ping Successful'; else echo 'Ping Failed'; fi)"
echo "<br>"
echo "<br>"
echo "\$(date)"
echo "<h2><a href="../index.html">Return to Main Menu</a></h3>"
echo ""
echo "</body></html>"
EOF

# Give it execute rights
sudo chmod +x /usr/lib/cgi-bin/input.cgi


# Generate an input html page that will be used be the cgi script
sudo tee -a /var/www/html/wifi.html << EOF
<HTML>
<head><title>WiFi Connect</title></head>
<body>
<H1> Input Form </H1>
<FORM METHOD=GET ACTION="./cgi-bin/wifi.cgi" >
<br>
WiFi SSID: <INPUT TYPE="text" Name="last" size=40 maxlength=50>
<br>
WiFi Passphrase: <INPUT TYPE="text" Name="passphrase" size=40 maxlength=50>
<br>
<INPUT TYPE="submit" value="Submit Form">
<INPUT TYPE="reset" value="Clear Form">
</form>
<hr>
</body>
</html>
EOF


# Generate a cgi script that utilizes the html inputs previously grabbed
sudo tee -a /usr/lib/cgi-bin/wifi.cgi << EOF
#!/bin/bash
echo "Content-type: text/html"
echo ""
echo "<html>"
echo "<head><title>WiFi Connect"
echo "</title></head><body>"
echo "<h1> Input Form </h1>"


echo \$QUERY_STRING | cut -d '=' -f 2 | cut -d '&' -f 1 > /home/www-data/wifi_ssid.txt
echo \$QUERY_STRING | cut -d '=' -f 3 | cut -d '&' -f 1 > /home/www-data/wifi_passphrase.txt

echo "\$(sed -i 's/+/\ /g' /home/www-data/wifi_passphrase.txt)"
echo "\$(sed -i 's/%60/\`/g' /home/www-data/wifi_passphrase.txt)"
echo "\$(sed -i 's/%3D/\=/g' /home/www-data/wifi_passphrase.txt)"
echo "\$(sed -i 's/%5B/\[/g' /home/www-data/wifi_passphrase.txt)"
echo "\$(sed -i 's/%5D/\]/g' /home/www-data/wifi_passphrase.txt)"
echo "\$(sed -i 's/%5C/\\/g' /home/www-data/wifi_passphrase.txt)"
echo "\$(sed -i 's/%3B/\;/g' /home/www-data/wifi_passphrase.txt)"
echo "\$(sed -i "s/%27/\'/g" /home/www-data/wifi_passphrase.txt)"
echo "\$(sed -i 's/%2C/\,/g' /home/www-data/wifi_passphrase.txt)"
echo "\$(sed -i 's/%2F/\//g' /home/www-data/wifi_passphrase.txt)"
echo "\$(sed -i 's/%7E/\~/g' /home/www-data/wifi_passphrase.txt)"
echo "\$(sed -i 's/%21/\!/g' /home/www-data/wifi_passphrase.txt)"
echo "\$(sed -i 's/%40/\@/g' /home/www-data/wifi_passphrase.txt)"
echo "\$(sed -i 's/%23/\#/g' /home/www-data/wifi_passphrase.txt)"
echo "\$(sed -i 's/%24/\$/g' /home/www-data/wifi_passphrase.txt)"
echo "\$(sed -i 's/%25/\%/g' /home/www-data/wifi_passphrase.txt)"
echo "\$(sed -i 's/%5E/\^/g' /home/www-data/wifi_passphrase.txt)"
echo "\$(sed -i 's/%26/\&/g' /home/www-data/wifi_passphrase.txt)"
echo "\$(sed -i 's/%28/\(/g' /home/www-data/wifi_passphrase.txt)"
echo "\$(sed -i 's/%29/\)/g' /home/www-data/wifi_passphrase.txt)"
echo "\$(sed -i 's/%2B/\+/g' /home/www-data/wifi_passphrase.txt)"
echo "\$(sed -i 's/%7B/\{/g' /home/www-data/wifi_passphrase.txt)"
echo "\$(sed -i 's/%7D/\}/g' /home/www-data/wifi_passphrase.txt)"
echo "\$(sed -i 's/%7C/\|/g' /home/www-data/wifi_passphrase.txt)"
echo "\$(sed -i 's/%3A/\:/g' /home/www-data/wifi_passphrase.txt)"
echo "\$(sed -i 's/%22/\"/g' /home/www-data/wifi_passphrase.txt)"
echo "\$(sed -i 's/%3C/\</g' /home/www-data/wifi_passphrase.txt)"
echo "\$(sed -i 's/%3E/\>/g' /home/www-data/wifi_passphrase.txt)"
echo "\$(sed -i 's/%3F/\?/g' /home/www-data/wifi_passphrase.txt)"

echo "\$(sed -i 's/+/\ /g' /home/www-data/wifi_ssid.txt)"
echo "\$(sed -i 's/%60/\`/g' /home/www-data/wifi_ssid.txt)"
echo "\$(sed -i 's/%3D/\=/g' /home/www-data/wifi_ssid.txt)"
echo "\$(sed -i 's/%5B/\[/g' /home/www-data/wifi_ssid.txt)"
echo "\$(sed -i 's/%5D/\]/g' /home/www-data/wifi_ssid.txt)"
echo "\$(sed -i 's/%5C/\\/g' /home/www-data/wifi_ssid.txt)"
echo "\$(sed -i 's/%3B/\;/g' /home/www-data/wifi_ssid.txt)"
echo "\$(sed -i "s/%27/\'/g" /home/www-data/wifi_ssid.txt)"
echo "\$(sed -i 's/%2C/\,/g' /home/www-data/wifi_ssid.txt)"
echo "\$(sed -i 's/%2F/\//g' /home/www-data/wifi_ssid.txt)"
echo "\$(sed -i 's/%7E/\~/g' /home/www-data/wifi_ssid.txt)"
echo "\$(sed -i 's/%21/\!/g' /home/www-data/wifi_ssid.txt)"
echo "\$(sed -i 's/%40/\@/g' /home/www-data/wifi_ssid.txt)"
echo "\$(sed -i 's/%23/\#/g' /home/www-data/wifi_ssid.txt)"
echo "\$(sed -i 's/%24/\$/g' /home/www-data/wifi_ssid.txt)"
echo "\$(sed -i 's/%25/\%/g' /home/www-data/wifi_ssid.txt)"
echo "\$(sed -i 's/%5E/\^/g' /home/www-data/wifi_ssid.txt)"
echo "\$(sed -i 's/%26/\&/g' /home/www-data/wifi_ssid.txt)"
echo "\$(sed -i 's/%28/\(/g' /home/www-data/wifi_ssid.txt)"
echo "\$(sed -i 's/%29/\)/g' /home/www-data/wifi_ssid.txt)"
echo "\$(sed -i 's/%2B/\+/g' /home/www-data/wifi_ssid.txt)"
echo "\$(sed -i 's/%7B/\{/g' /home/www-data/wifi_ssid.txt)"
echo "\$(sed -i 's/%7D/\}/g' /home/www-data/wifi_ssid.txt)"
echo "\$(sed -i 's/%7C/\|/g' /home/www-data/wifi_ssid.txt)"
echo "\$(sed -i 's/%3A/\:/g' /home/www-data/wifi_ssid.txt)"
echo "\$(sed -i 's/%22/\"/g' /home/www-data/wifi_ssid.txt)"
echo "\$(sed -i 's/%3C/\</g' /home/www-data/wifi_ssid.txt)"
echo "\$(sed -i 's/%3E/\>/g' /home/www-data/wifi_ssid.txt)"
echo "\$(sed -i 's/%3F/\?/g' /home/www-data/wifi_ssid.txt)"


echo "<br>"
wifi=\$(cat /home/www-data/wifi_ssid.txt)
echo "\$(echo SSID: \$wifi)"
echo "<br>"
passphrase=\$(cat /home/www-data/wifi_passphrase.txt)
echo "\$(echo Passphrase: \$passphrase)"
echo "<br>"
echo "\$(wpa_passphrase "\${wifi}" "\${passphrase}" >> /etc/wpa_supplicant.conf)" 
echo "<br>"
sudo wpa_supplicant -B -c /home/www-data/wpa_supplicant.conf -i wlan0
echo "<br>"
echo "<br>"
echo "\$(date)"
echo "<h2><a href="../index.html">Return to Main Menu</a></h3>"
echo ""
echo "</body></html>"
EOF

# Give it execute rights
sudo chmod +x /usr/lib/cgi-bin/wifi.cgi

# Generate Service Script
sudo tee -a /usr/lib/cgi-bin/wifirestart.cgi << EOF
#!/bin/bash
echo "Content-type: text/html"
echo ""
echo "<html>"
echo "<meta http-equiv="refresh" content="4\;url=../index.html" />"
echo "<head><title>Restarting WiFi"
echo "</title></head><body>"
echo "<h1> Restarting WiFi... </h1>"
echo "\$(sudo killall wpa_supplicant)"
echo "\$(sudo wpa_supplicant -B -c /home/www-data/wpa_supplicant.conf -i wlan0)"
echo "<br>"
echo "\$(date)"
echo "<h2><a href="../index.html">Return to Main Menu</a></h3>"
echo ""
echo "</body></html>"
EOF

# Give it execute rights
sudo chmod +x /usr/lib/cgi-bin/wifirestart.cgi 




# Restart the apache service
sudo systemctl restart apache2

# Set www-data to no password sudo permissions
echo '' | sudo EDITOR='tee -a' visudo
echo '%www-data ALL=NOPASSWD: /usr/bin/systemctl start ssh, /usr/bin/systemctl stop ssh, /usr/bin/systemctl status ssh' | sudo EDITOR='tee -a' visudo
echo '%www-data ALL=NOPASSWD: /usr/bin/systemctl start openvpn@client1, /usr/bin/systemctl stop openvpn@client1, /usr/bin/systemctl status openvpn@client1' | sudo EDITOR='tee -a' visudo
echo '%www-data ALL=NOPASSWD: /usr/sbin/shutdown -h now, /usr/sbin/reboot' | sudo EDITOR='tee -a' visudo
echo '%www-data ALL=NOPASSWD: /usr/sbin/iptables -t nat -A POSTROUTING -s 192.168.254.0/29 -o wlan0 -j MASQUERADE, /usr/sbin/iptables -t nat -A POSTROUTING -s 192.168.254.0/29 -o pine0 -j MASQUERADE, /usr/sbin/iptables -t nat -A POSTROUTING -s 192.168.254.0/29 -o eth1 -j MASQUERADE' | sudo EDITOR='tee -a' visudo
echo '%www-data ALL=NOPASSWD: /usr/sbin/iptables -t nat -F POSTROUTING' | sudo EDITOR='tee -a' visudo
echo '%www-data ALL=NOPASSWD: /usr/bin/killall wpa_supplicant' | sudo EDITOR='tee -a' visudo
echo '%www-data ALL=NOPASSWD: /usr/sbin/wpa_supplicant -B -c /home/www-data/wpa_supplicant.conf -i wlan0' | sudo EDITOR='tee -a' visudo
echo '%www-data ALL=NOPASSWD: /usr/bin/sed -i 's/7CFC00/FF0000/g' /usr/lib/cgi-bin/wanipsimple.cgi' | sudo EDITOR='tee -a' visudo
echo '%www-data ALL=NOPASSWD: /usr/bin/sed -i 's/FF0000/7CFC00/g' /usr/lib/cgi-bin/wanipsimple.cgi' | sudo EDITOR='tee -a' visudo
echo '%www-data ALL=NOPASSWD: /usr/bin/sed -i' | sudo EDITOR='tee -a' visudo
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
<a href="./cgi-bin/vpnon.cgi">Turn VPN On</a>
<br>
<a href="./cgi-bin/vpnoff.cgi">Turn VPN Off</a>
<br>
<a href="./cgi-bin/bypass.cgi">Allow VPN Bypass</a>
<br>
<a href="./input.html">Ping Test</a>
<br>
<a href="./wifi.html">WiFi Connect</a>
<br>
<a href="./cgi-bin/wifirestart.cgi">WiFi Start</a>
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
sudo sed -i 's/localhost/PiSense/g' /etc/hosts

# Set WPA_Supplicant to www-data
sudo touch /etc/wpa_supplicant.conf
sudo chown www-data:www-data /etc/wpa_supplicant.conf



sudo iptables -A INPUT -m conntrack --ctstate RELATED,ESTABLISHED -j ACCEPT
sudo iptables -A INPUT -m conntrack --ctstate INVALID -j DROP
sudo iptables -A INPUT -i lo -j ACCEPT
sudo iptables -A INPUT -i eth0 -j ACCEPT
sudo iptables -A INPUT -i eth1 -j DROP
sudo iptables -A INPUT -i wlan0 -j DROP

sudo iptables -A OUTPUT -m conntrack --ctstate ESTABLISHED -j ACCEPT
sudo iptables -A OUTPUT -m conntrack --ctstate INVALID -j DROP
sudo iptables -A OUTPUT -p tcp -m multiport --dport 53,80,443 -j ACCEPT
sudo iptables -A OUTPUT -p udp -m multiport --dport 53,67,68,123 -j ACCEPT
sudo iptables -A OUTPUT -o lo -j ACCEPT
sudo iptables -A OUTPUT -p icmp -j ACCEPT
sudo iptables -P OUTPUT DROP
sudo iptables -P INPUT DROP


echo iptables-persistent iptables-persistent/autosave_v4 boolean true | sudo debconf-set-selections
echo iptables-persistent iptables-persistent/autosave_v6 boolean false | sudo debconf-set-selections

# Currently this will fail if you are using the ETH0 Interface to access the internet
# This is because ETH0 gets a static IP address and it will no longer be able to access the internet.
sudo apt-get install iptables-persistent -y


# Disable SSH by default
sudo systemctl disable ssh

sudo reboot
