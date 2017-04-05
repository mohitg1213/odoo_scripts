#!/bin/bash
##############################################################################
##############################################################################
## A script to install OpenERP 7.0 server
#-----------------------------------------------------------------------------
#	   Original Author: 
#	   Mohit Chandra (mohit@webkul.com)
#    Webkul Software Pvt. Ltd.
##############################################################################
#    This program is free software: you can redistribute it and/or modify
#    it under the terms of the GNU Affero General Public License as
#    published by the Free Software Foundation, either version 3 of the
#    License, or (at your option) any later version.
#
#    This program is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU Affero General Public License for more details.
#
#    You should have received a copy of the GNU Affero General Public License
#    along with this program.  If not, see <http://www.gnu.org/licenses/>.
#
##############################################################################
##############################################################################
#check for sudoer
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root" 
   exit 1
fi
#fixed parameters:
LOG="/var/log/oe_install.log"
date=$(date +"%Y-%m-%d_%H:%M:%S")

q_no=1
oe_instance=""
oe_user="openerp"
oe_path="/opt/openerp"
db_user="openerp"
db_pwd="False"
db_admin_pwd="admin"
xmlrpc_port="8069"
xmlrpcs_port="8070"
netrpc_port="8071"

oe_log="/var/log"
oe_conf="/etc"
oe_script="/etc/init.d"

install_postgres="y"
install_plib="y"

display_summary(){
sudo clear
progress "100"
echo -e "\n\t\t\t\t... SUMMARY ..."
echo ""
echo -e "\nOpenerp Installation has successfully Done !!!"
echo ""
echo -e "\n To start/stop/restart openerp use openerp-server script file placed on path -"$oe_script"/openerp_server"$oe_instance
echo ""
echo -e "\n Openerp log file path -"$oe_log"/openerp"$oe_instance"/openerp"$oe_instance"-server.log"
echo ""
echo -e "\n Openerp configuration file -"$oe_conf"/openerp"$oe_instance"-config.conf"
echo ""
echo -e "\n Openerp addons path -"$oe_path"/server/openerp/addons"
echo ""
echo -e "\n\n\n--- Thank you ---"
}
#This function shows the progress of the Installation
progress(){
echo ""
echo -e "\n"$1"% Completed..."
echo ""
}

check_existence(){
if [[ -f $1 ]]; then
	echo $2" File already exists on path ("$1"). !!!"
	echo "Either delete it or use some other opeenrp instance to carry out openerp installation sucessfully !!!"
	echo "Please try again later."
	sleep 1
	echo "Thank you."
	echo "exiting..."
	echo ""
	exit
fi

}
#This function display the message of what we rae going to do and what we have done till now !!! 
display(){
echo -e $1
}

set_var(){
q_no=$((q_no+1))
local temp
	echo $1
	read temp
	if [[ -n $temp ]]
		then eval $2=$temp
	fi
	#if [ -z $temp ]
	#	 echo "Default is set - "$2
	#fi
}
#This function creates a conf file for Openerp Instance
create_conf() {
conf_file=$oe_conf"/openerp"$oe_instance"-config.conf"
addons_path=$oe_path"/server/openerp/addons"
	echo "[options]" > $conf_file
	echo "; This is the password that allows database operations:" >> $conf_file
	echo "admin_passwd = "$db_admin_pwd >> $conf_file
	echo "db_host = False" >> $conf_file
	echo "db_port = False" >> $conf_file
	echo "db_user = "$db_user >> $conf_file
	echo "db_password = "$db_pwd >> $conf_file
	echo "logfile = "$oe_log"/openerp"$oe_instance"/openerp"$oe_instance"-server.log" >> $conf_file
	echo "xmlrpc_port = "$xmlrpc_port >> $conf_file
	echo "xmlrpcs_port = "$xmlrpcs_port >> $conf_file
	echo "netrpc_port = "$netrpc_port >> $conf_file
	echo "addons_path = "$addons_path >> $conf_file

sudo chown $oe_user: $conf_file
sudo chmod 640 $conf_file
}

#This function create a script used to start/stop/restart openerp server
create_script() {
#1 openerp server path
#2 openerp user
#3 openerp instance

script_file=$oe_script"/openerp_server"$oe_instance
PATH="/bin:/sbin:/usr/bin"
DAEMON=$oe_path"/server/openerp-server"
NAME="openerp-server"
DESC="openerp-server"
USER=$oe_user
CONFIGFILE=$oe_conf"/openerp"$oe_instance"-config.conf"
cat << EOL >> $script_file
#!/bin/sh

### BEGIN INIT INFO
### END INIT INFO

PATH=$PATH
DAEMON=$DAEMON
NAME=$NAME
DESC=$DESC

# Specify the user name (Default: openerp).
USER=$USER

# Specify an alternate config file (Default: /etc/openerp-server.conf).
CONFIGFILE="$CONFIGFILE"

# pidfile
PIDFILE=/var/run/\$NAME.pid

# Additional options that are passed to the Daemon.
DAEMON_OPTS="-c \$CONFIGFILE"

[ -x \$DAEMON ] || exit 0
[ -f \$CONFIGFILE ] || exit 0

checkpid() {
	[ -f \$PIDFILE ] || return 1
	pid=\`cat \$PIDFILE\`
	[ -d /proc/\$pid ] && return 0
    	return 1
}

case "\${1}" in
	start)
                echo -n "Starting \${DESC}: "

                start-stop-daemon --start --quiet --pidfile \${PIDFILE} \\
                        --chuid \${USER} --background --make-pidfile \\
                        --exec \${DAEMON} -- \${DAEMON_OPTS}

                echo "\${NAME}."
                ;;

        stop)
                echo -n "Stopping \${DESC}: "

                start-stop-daemon --stop --quiet --pidfile \${PIDFILE} \\
                        --oknodo

                echo "\${NAME}."
                ;;

        restart|force-reload)
                echo -n "Restarting \${DESC}: "

                start-stop-daemon --stop --quiet --pidfile \${PIDFILE} \\
                        --oknodo

                sleep 1

                start-stop-daemon --start --quiet --pidfile \${PIDFILE} \\
                        --chuid \${USER} --background --make-pidfile \\
                        --exec \${DAEMON} -- \${DAEMON_OPTS}

                echo "\${NAME}."
                ;;

        *)
                N=/etc/init.d/\${NAME}
                echo "Usage: \${NAME} {start|stop|restart|force-reload}" >&2
                exit 1
                ;;
esac

exit 0
EOL

sudo chmod 755 $script_file
sudo chown root: $script_file
}
#Checks for any arguments and if there is none then the user is asked for arguments
if [ $# = 0 ]; then
	sudo clear
	display "We need some basic information in order to install OpenERP 7 on your server. Press enter to set default"
	display "-------------------------------------------------------------------------------------------------------"
	sleep 1
	display " "
	set_var "     "$q_no") Give the number of openerp instance on your server(i.e 1,2,3,etc).If you are going to install first time,please ignore and press enter. " oe_instance
	set_var "     "$q_no") What will be the location of your openerp server ? (Default - /opt/openerp)" oe_path
	if [ ! -z "$oe_instance" -a "$oe_instance" != "1" ]; then
		set_var "     "$q_no") To own and run the application which has no shell and has logins disabled,we need a system user ? (Default - openerp)" oe_user
		set_var "     "$q_no") Do you want to install postgres also (y/n) ? (Default - y)" install_postgres
		if [ "$install_plib" == "n" ]; then
			set_var "     "$q_no") Postgres user for this openerp will be ? (Default - openerp)" db_user
			sudo -H -u postgres bash -c "createuser --createdb --username postgres --no-createrole --no-superuser --pwprompt $db_user"
			set_var "Enter one more time" db_pwd
		fi
		set_var "     "$q_no") Admin Master password for openerp GUI for creating/restoring databases ? (Default - admin)" db_admin_pwd
		set_var "     "$q_no") Xmlrpc port for this OpenERP ? (Default - 8069)" xmlrpc_port
		set_var "     "$q_no") Xmlrpcs port for this OpenERP ? (Default - 8070)" xmlrpcs_port
		set_var "     "$q_no") Netrpc port for this OpenERP ? (Default - 8071)" netrpc_port
		
		set_var "     "$q_no") Do you want to install all python dependencies also (y/n) ? (Default -y)" install_plib
	fi
	set_var "     "$q_no") What will be the location of your openerp log file ? (Default - /var/log)" oe_log
	set_var "     "$q_no") What will be the location of your openerp configuration file ? (Default - /etc)" oe_conf
	#set_var "     "$q_no") What will be the location of your openerp server script file to start/stop/restart? (Default - /etc/init.d/)" oe_script
#test
#echo $oe_instance
#echo $oe_user
#echo $oe_path
#echo $db_user
#echo $db_pwd
#echo $db_admin_pwd
#echo $xmlrpc_port
#echo $xmlrpcs_port
#echo $netrpc_port

#echo $install_postgres
#echo $install_plib
sudo clear
progress "5"
display "\n ---- Checking for any conflicts  ----"
sleep 1
check_existence $oe_conf"/openerp"$oe_instance"-config.conf" "Openerp Configuration"
check_existence $oe_log"/openerp"$oe_instance"/openerp"$oe_instance"-server.log" "Openerp Log"
check_existence $oe_script"/openerp_server"$oe_instance "Openerp Script"

if [ -d "$oe_path/server" ]; then
	echo "Openerp Server Directory('server') already exists as ("$oe_path"/server). !!!"
        echo "Either delete it or use some other openerp instance path to carry out openerp installation sucessfully !!!"
        echo "Please try again later."
        sleep 1
        echo "Thank you."
        echo "exiting..."
        echo ""
        exit

fi

if [ -d "$oe_path/downloads" ]; then
        echo "Download Directory('downloads') already exists as ("$oe_path"/downloads). !!!"
        echo "Either delete it or rename it to carry out openerp installation sucessfully !!!"
        echo "Please try again later."
        sleep 1
        echo "Thank you."
        echo "exiting..."
        echo ""
        exit

fi

sudo clear
progress "10"
display "\nStep 1) ---- Preparing for installation  ----"
sleep 1
sudo apt-get -qy install openssh-server denyhosts
sudo apt-get -qy update

if [ "$install_plib" == "y" ]; then
	sudo clear
	progress "20"
	display "\nStep 2) ---- Installing python libraries ----"
	sleep 1
	sudo apt-get install python-dateutil python-docutils python-feedparser python-gdata \
	python-jinja2 python-ldap python-libxslt1 python-lxml python-mako python-mock python-openid \
	python-psycopg2 python-psutil python-pybabel python-pychart python-pydot python-pyparsing \
	python-reportlab python-simplejson python-tz python-unittest2 python-vatnumber python-vobject \
	python-webdav python-werkzeug python-xlwt python-yaml python-zsi
else
	sudo clear
	display "\n---- Skipping step 2) Installation of python libraries ----"
	sleep 1
fi

sudo clear
progress "30"
display "\n---- Starting installation  ----"
display "\nStep 3) ---- Creating system user/directories ----"
sleep 1
sudo adduser --system --home=$oe_path --group $oe_user
sudo mkdir $oe_log"/openerp"$oe_instance
sudo touch $oe_log"/openerp"$oe_instance"/openerp"$oe_instance"-server.log"
sudo chown -R $oe_user: $oe_log"/openerp"$oe_instance"/openerp"$oe_instance"-server.log"

if [ "$install_postgres" == "y" ]; then
	sudo clear
	progress "40"
	display "\nStep 4) ---- Installing Postgres ----"
	sleep 1
	sudo apt-get install postgresql
	set_var "     "$q_no") Postgres user for this openerp will be ? (Default - openerp)" db_user
	sudo -H -u postgres bash -c "createuser --createdb --username postgres --no-createrole --no-superuser --pwprompt $db_user"
	set_var "Enter one more time" db_pwd
else
	display "\n Skipping step 4) Installation of Postgres "
	sleep 1
fi

sudo clear
progress "50"
display "Step 5) ---- Checking openerp user for Postgres ----"
sleep 1
#sudo -H -u postgres bash -c "createuser --createdb --username postgres --no-createrole --no-superuser $db_user"
# sudo -H -u postgres bash -c "createuser --createdb --username postgres --no-createrole --no-superuser --pwprompt $db_user"

sudo clear
progress "60"
display "\nStep 6) ---- Downloading files ----"
sleep 1
mkdir -p $oe_path/downloads
wget http://nightly.openerp.com/7.0/nightly/src/openerp-7.0-latest.tar.gz -P $oe_path/downloads/ --progress=bar

sudo clear
progress "70"
display "\nStep 7) ---- Uncompressing files ----"
sleep 1
mkdir -p $oe_path/server
tar xvf $oe_path/downloads/openerp-7.0-latest.tar.gz --directory=$oe_path/server --strip-components 1 >> $LOG

sudo clear
progress "80"
display "\nStep 8) ---- Installing files ----"
sleep 1
sudo chown -R $oe_user: $oe_path/server/*

sudo clear
progress "90"
display "\nStep 9) ---- Creating Openerp Configuration File ----"
sleep 1
create_conf

sudo clear
progress "95"
display "\nStep 10) ---- Creating Openerp Script file to start/stop/restart server ----"
sleep 1
create_script

sleep 1
display_summary
else
	echo "No arguments please..."
fi

exit 0
