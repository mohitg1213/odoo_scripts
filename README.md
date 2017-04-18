# Some usefull bash scripts for ODOO

1) db_dump.sh :sparkles: :sparkles: :sparkles: **[READ BLOG](http://webkul.com/blog/openerp-db-backup-automatically)**

> Using this script, we can take backup of any Odoo database from the terminal itself. We can also setup cron on OS for        > running this script in order to take backup automatically after certain time.
For more details, check this blog :

2) oe_install.sh :sparkles: **[READ BLOG](http://webkul.com/blog/install-openerp-on-ubuntu)**

> This script enable us to install openerp (version 7) on Ubuntu with an one command line only. We need to just answer some  few needed questions after running this script , all remaining work will be done by this script all alone.
> Using this script, we can also install other Openerp instance also on the same server but with different ports.

**Steps** -
- You need to run this script with sudoer account only (i.e root), so copy this script to some path like /etc/scripts
- Give root ownership and 700 permisiion to this file.
- Execute this file as -
``` ./oe_install.sh ```
or
``` /etc/scripts/./oe_install.sh ```

3) odoo_server.sh :sparkles: :sparkles: :sparkles:

> Use this script to start/stop odoo daemon service, check status of running/stopped odoo server, forcely restart odoo        > server.

**Steps** -
- Download and put this script file on path : /etc/init.d
- Verify & Update(if needed) some fixed parameters inside this script file like: DAEMON, CONFIGFILE, PIDFILE
- Change permission & onwership of this file as:
``` sudo chmod 755 /etc/init.d/odoo-server
    sudo chown root: /etc/init.d/odoo-server ```
- Usage: /etc/init.d/odoo-server {start|stop|restart/reload|status|force-restart|force-stop}

**TIPS**: 
- [x] Using 'status', we can find information of all runnning odoo daemon servers.
- [x] Using 'force-stop/force-restart', we can kill all running odoo daemon forcefully, and can start fresh odoo-server daemon.
- [x] start/stop will not allow more than one process per daemon.
