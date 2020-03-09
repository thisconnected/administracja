#!/bin/bash

#this script was made to configure interfaces fast for my netowrking lab
# GPLv3 Patryk Kaniewski
function show()
{
    ip addr show| grep -v vir |
	awk '
        #Output function to format results (if any)
        function outline() {
            if (link>"") {printf "%s %s %s\n", iface, link, inets}
        }

        # Interface section starts here
        $0 ~ /^[1-9]/ {
            outline();                              # Output anything we previously collected
            iface=substr($2, 1, index($2,":")-1);   # Capture the interface name
            inets="";                               # Reset the list of addresses
            link=""                                 # and MAC too
        }

        # Capture the MAC
        $1 == "link/ether" {
            link=$2                   
        }

        # Capture an IPv4 address. Concatenate to previous with comma
        $1 == "inet" {
            inet=substr($2, 1, index($2,"/")-1);    # Discard /nn subnet mask
            if (inets>"") inets=inets ",";          # Suffix existing list with comma
            inets=inets inet                        # Append this IPv4
        }

        # Input processing has finished
        END {
            outline()                               # Output remaining collection
        }
    '
    }

function menu()
{

 interfaces=$(show)
 
 options+=('show configuration')
 options+=('show diffrences')
 options+=('commit changes')
 SAVEIFS=$IFS   # Save current IFS
 IFS=$'\n'      # Change IFS to new line
 interfaces=($interfaces) # split to array $names
 options+=(${interfaces[@]})
 IFS=$SAVEIFS   # Restore IFS
 
 
 
 
    
    PS3="wybierz akcje:"
    select opt in "${options[@]}"
    do
	case $opt in
	    "show configuration")
		rm /tmp/final.conf
	        cat /tmp/*.conf > /tmp/final.conf
		nano final.conf
		;;
	    "commit changes")
		echo "writing to /tmp/interfaces"
		cat /tmp/*.conf > /tmp/interfaces
		show
		;;
	    "show diffrences")
		rm /tmp/final.conf
		cat /tmp/*.conf > /tmp/final.conf
		diff /etc/network/interfaces /tmp/final.conf
		;;
	    *)
		if (printf '%s\n' "${options[@]}" | grep "$opt" > /dev/null); then
		    configure $opt
		else
		    echo "nie ma takiej operacji"
		fi
		;;
	esac
    done

}
function configure()
{
    echo "configure"
    echo "$1"
    configuration=("show old" "show current" "configure ip" "configure netmask" "configure gateway" "configure dns" "commit changes" "go back")

    ip=""
    netmask=""
    gateway=""
    dns=""
    PS3=$1
    select opt in "${configuration[@]}"
    do
	case $opt in
	    "show old")
		ip a | grep $1
		;;
	    "show current")
		printconf $1
		;;
	    "configure ip")
	        echo "enter ip"
		read ip
		echo $ip
		;;
	    "configure netmask")
		echo "enter netmask"
		read netmask
		echo $netmask
		;;
	    "configure gateway")
		echo "enter netmask"
		read netmask
		echo $gateway
		;;
	    "configure dns")
		echo "enter netmask"
		read netmask
		echo $dns
		;;
	    "commit changes")
		printconf $1 > /tmp/$1.conf
		;;
	    "go back")
		break;
		;;
	    *)
		echo "no options"
		;;
	esac
    done
}
function printconf()
{
    echo "iface $1 inet static"
    if [ -n "$ip" ]; then
	echo adress $ip
    fi
    if [ -n "$netmask" ]; then
	echo netmask $netmask
    fi
    if [ -n "$gateway" ]; then
	echo gateway $gateway
    fi
    if [ -n "$dns" ]; then
	echo dns-nameservers $dns
    fi
}

echo "start"
cp /etc/network/interfaces /tmp/base.conf
menu
