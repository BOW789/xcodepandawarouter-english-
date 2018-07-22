#!/bin/bash
#Progammer : Kurniawan. trainingxcode@gmail.com. xcode.or.id.
again='y'
while [[ $again == 'Y' ]] || [[ $again == 'y' ]];
do
clear
echo "=====================================================================";
echo " X-code Pandawa Router for Ubuntu 18.04 Server                       ";
echo " Progammer : Kurniawan. xcode.or.id                                  ";
echo " Version 1.0 (18/06/2018)                                            ";
echo "=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=";
echo " Option to support the router                                        ";
echo " [1]  Install X-code Pandawa (To rename the interface to eth0 & eth1)";
echo " [2]  Setting IP Address for eth0 and eth1                           ";
echo " [3]  Install NAT, DHCP Server & Bandwidth monitoring                ";
echo " [4]  Install Squid for log dan cache                                ";
echo " [5]  Setting DHCP Server                                            ";
echo " [6]  Port Forwarding                                                ";
echo " [7]  Enable Squid + Logs users (transparent)                        ";
echo " [8]  Enable Squid + Log users + Cache (transparent)                 ";
echo " [10] Install VPN Server PPTP                                        ";
echo " [11] Setting ip client VPN Server                                   ";
echo " [12] Setting Password VPN Server                                    ";
echo " [13] Setting ms-dns VPN Server                                      ";
echo " =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-";
echo " Logs and more..                                                     ";
echo " [14] DHCP Leases                                                    ";
echo " [15] See the logs of websites opened by the client                  ";
echo " [16] View the size of the stored web cache                          ";
echo " [17] Edit squid.conf                                                ";
echo " [18] Enable rc.local for NAT                                        ";
echo " [19] Edit rc.local                                                  ";
echo " [20] Reboot                                                         ";
echo " [21] Exit                                                           ";
echo "=====================================================================";
read -p " Please enter the number of your choice [1 - 21] : " choice;
echo "";
case $choice in
1)  if [ -z "$(sudo ls -A /etc/default/grub)" ]; then
    echo "Grub is not detected, are you sure using ubuntu 18.04?"
    else
    sudo apt-get install ifupdown
    cp support/grub /etc/default/grub
    grub-mkconfig -o /boot/grub/grub.cfg
    cp support/resolved.conf /etc/systemd/
    sudo systemctl restart systemd-resolved
    cp support/interfaces /etc/network/
    sudo nano /etc/network/interfaces
    read -p "Press enter to restart"
    reboot
    fi
    ;;
2)  if [ -z "$(ls -l /etc/network/interfaces)" ]; then
    echo "Not detected /etc/network/interfaces"
    else
    sudo nano /etc/network/interfaces
    read -p "Do you want to restart eth0 and eth1 connections now? y/n :" -n 1 -r
    echo 
        if [[ ! $REPLY =~ ^[Nn]$ ]]
        then
        ip addr flush eth0 && sudo systemctl restart networking.service
        ip addr flush eth1 && sudo systemctl restart networking.service
        sudo ifconfig
        fi
    fi
    ;;
3)  read -p "Are you sure you want to install NAT, DHCP Server, and iptraf ? y/n :" -n 1 -r
    echo  ""
    if [[ ! $REPLY =~ ^[Nn]$ ]]
    then
    sudo sysctl -w net.ipv4.ip_forward=1
    sudo /sbin/iptables -P FORWARD ACCEPT
    sudo /sbin/iptables --table nat -A POSTROUTING -o eth0 -j MASQUERADE
    sudo apt-get install isc-dhcp-server
    sudo mv /etc/dhcp/dhcp.conf /tmp
    sudo cp support/dhcpd.conf /etc/dhcp
    sudo nano /etc/dhcp/dhcpd.conf
    sudo service isc-dhcp-server restart
    sudo apt-get install iptraf
    fi
    ;;

4)  read -p "Are you sure to install squid?  y/n :" -n 1 -r
    echo  ""
    if [[ ! $REPLY =~ ^[Nn]$ ]]
    then
    sudo apt-get install squid3
    fi
    ;;

5)  if [ -z "$(ls -A /etc/dhcp/dhcpd.conf)" ]; then
    echo "DHCP Server not detected"
    else
    echo "Setting DHCP Server"
    sudo nano /etc/dhcp/dhcpd.conf
    service isc-dhcp-server restart
    fi
    ;;   

6) sudo iptraf-ng
    ;;


7) echo -n "Enter the ip WAN on the router : "
    read ipwan
    echo -n "Enter ip LAN on the destination server : "
    read iplan
    echo -n "Enter the port number to be forwarded : "
    read portip
    sudo sysctl -w net.ipv4.ip_forward=1
    sudo iptables -t nat -A PREROUTING -j DNAT -d $ipwan -p tcp --dport $portip --to $iplan
    ;;

8) echo -n "Enter the ip LAN on the router : "
    read iplan2
    if [ -z "$(ls -A /etc/squid/squid.conf)" ]; then
    echo "Squid is not detected"
    else
    rm /etc/squid/squid.conf
    sudo cp support/squid1/squid.conf /etc/squid/
    sudo iptables -t nat -A PREROUTING -i eth1 -p tcp -m tcp --dport 80 -j DNAT --to-destination $iplan2:3127
    read -p "Log will be active if restarted"
    fi
    ;;

9) echo -n "Enter the ip LAN on the router : "
    read iplan3
    if [ -z "$(ls -l /etc/squid/squid.conf)" ]; then
    echo "Squid is not detected"
    else
    rm /etc/squid/squid.conf
    sudo cp support/squid2/squid.conf /etc/squid/
    sudo iptables -t nat -A PREROUTING -i eth1 -p tcp -m tcp --dport 80 -j DNAT --to-destination $iplan3:3127
    read -p "Log will be active if restarted"
    fi
    ;;

10) read -p "Are you sure to install PPTP VPN Server ? y/n :" -n 1 -r
    echo  ""
    if [[ ! $REPLY =~ ^[Nn]$ ]]
    then
    if [ -z "$(ls -l /etc/pptpd.conf)" ]; then
    echo "Install PPTP Server" 
    sudo apt-get install pptpd
    sudo cp support/etc/pptpd.conf /etc
    sudo cp support/chap-secrets /etc/ppp
    sudo cp support/ppptpd-options /etc/ppp
    sudo nano /etc/pptpd.conf
    sudo nano /etc/ppp/chap-secrets
    sudo nano /etc/ppp/pptpd-options
    service pptpd restart
    else
    echo "PPTP already exists"
    fi
    fi
    ;;

11) if [ -z "$(ls -l /etc/pptpd.conf)" ]; then
    echo "No pptpd.conf file detected on the VPN Server"
    else
    echo "Edit pptpd.conf" 
    sudo nano /etc/pptpd.conf
    service pptpd restart
    fi
    ;;

12) if [ -z "$(ls -l /etc/ppp/chap-secrets)" ]; then
    echo "No chap-secrets file detected on the VPN Server"
    else
    echo "Edit file chap-secrets" 
    sudo nano /etc/ppp/chap-secrets
    service pptpd restart
    fi
    ;;

13) if [ -z "$(ls -l /etc/pptpd.conf)" ]; then
    echo "No pptpd-options file detected on the VPN Server"
    else
    echo "Edit file pptpd-options" 
    sudo nano /etc/ppp/pptpd-options
    service pptpd restart
    fi
    ;;

14) if [ -z "$(ls -l /var/lib/dhcp/dhcpd.leases)" ]; then
    echo "DHCP Server not detected"
    else
    sudo perl support/dhcplist.pl
    fi
    ;;

15) if [ -z "$(ls -l /var/log/squid/access.log)" ]; then
    echo "Log access from squid is not detected"
    else
    sudo nano /var/log/squid/access.log
    fi
    ;;

16) du -s /var/spool/squid
    read -p "Press enter to continue"
    ;;

17) if [ -z "$(ls -l /etc/squid/squid.conf)" ]; then
    echo "Squid is not detected"
    else
    sudo nano /etc/squid/squid.conf
    fi
    ;;

18) cp support/rc.local /etc/
    chmod 777 rc.local
    sudo sysmctl enable rc-local.service
    ;; 

19) sudo nano /etc/rc.local
    ;;

20) read -p "Are you sure you want to restart? y/n :" -n 1 -r
    echo 
    if [[ ! $REPLY =~ ^[Nn]$ ]]
    then
    reboot
    fi
    ;;

21) exit
    ;;
*)    echo "Sorry your choice is not available"
esac
echo ""
echo "X-code Pandawa"
echo "By Kurniawan - trainingxcode@gmail.com. xcode.or.id"
echo ""
echo -n "Back to menu? [y/n]: ";
read again;
while [[ $again != 'Y' ]] && [[ $again != 'y' ]] && [[ $again != 'N' ]] && [[ $again != 'n' ]];
do
echo "Sorry your choice is not available";
echo -n "Back to menu? [y/n]: ";
read again;
done
done
