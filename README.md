# Some usefull bash scripts for ODOO

1) db_dump.sh

Using this script, we can take backup of any Odoo database from the terminal itself. We can also setup cron on OS for running this script in order to take backup automatically after certain time.
For more details, check this blog :

BLOG - http://webkul.com/blog/openerp-db-backup-automatically

2) oe_install.sh

BLOG - http://webkul.com/blog/install-openerp-on-ubuntu

This script enable us to install openerp (version 7) on Ubuntu with an one command line only. We need to just answer some few needed questions after running this script , all remaining work will be done by this script all alone.
Using this script, we can also install other Openerp instance also on the same server but with different ports.

Steps -

1) You need to run this script with sudoer account only (i.e root), so copy this script to some path like /etc/scripts

2) Give root ownership and 700 permisiion to this file.

3) Execute this file as -

./oe_install.sh 

or

/etc/scripts/./oe_install.sh

