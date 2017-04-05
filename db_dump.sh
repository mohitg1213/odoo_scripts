#!/bin/bash
##############################################################################
##############################################################################
## A script for ODOO Database Backup
#    Original Author: 
#    Mohit Chandra (mohit@webkul.com)
#    Webkul Software Pvt. Ltd.
##############################################################################
##############################################################################
#fixed parameters:
date=$(date +"%Y-%m-%d_%H:%M:%S")
db='variant_multi'
backup_path="/var/pgdump"
filename="$backup_path/${db}_$date"

# Stop ODOO Server
        /etc/init.d/openerp-server stop

# Taking Dump of selected DB
sudo -H -u postgres bash -c "pg_dump --format=c  --no-owner $db>$filename"

# Start OpenERP Server
/etc/init.d/openerp-server start

exit 0
