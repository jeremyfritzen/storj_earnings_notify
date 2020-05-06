#!/bin/bash -e

# This script will evaluate the amount to be paid for being a Storage Node on Storj Network and send a pushbullet notification about it.
# The script is based on storj_earnings script by ReneSmeekes.
# This script has been developed by Jeremy Fritzen. Thank you for sharing and keeping author name in it.

# Use this script with a user authorized to run Docker commands.

#############################################
############## USER PARAMETERS ##############
#############################################

#Parameters to be set by the user
# Directories must be specified without "/" at the end.

STORAGE_DIR="" # Absolute storage node directory path (where required files are stored, such as bandwidth.db)
CONTAINER_NAME="" # Docker container name of the storage node
STORAGENODE_NAME="" # Friendly name of the stroage node. Chose the one you want to be used in your notifications. 
PUSHBULLET_KEY="" # Pushbullet API key
PUSHBULLET_DEVICE="" # OPTIONAL - Pushbullet ID device on which the notification will be sent. If not specified, the notification will be sent to all devices.



###############################################
############## SCRIPT PARAMETERS ##############
###############################################

# Do not change these variables

SCRIPT_DIR=$(cd $( dirname ${BASH_SOURCE[0]}) && pwd )
TEMP_DIR=$SCRIPT_DIR/infodbcopy
DATE=$(date +%Y-%m-%d-%H-%M)



##############################################
############## SCRIPT EXECUTION ##############
##############################################

docker stop -t 300 $CONTAINER_NAME

cp $STORAGE_DIR/bandwidth.db $TEMP_DIR/
cp $STORAGE_DIR/storage_usage.db $TEMP_DIR/
cp $STORAGE_DIR/piece_spaced_used.db $TEMP_DIR/
cp $STORAGE_DIR/reputation.db $TEMP_DIR/
cp $STORAGE_DIR/heldamount.db $TEMP_DIR/

docker start $CONTAINER_NAME

python $SCRIPT_DIR/storj_earnings/earnings.py $TEMP_DIR $1 | tee $SCRIPT_DIR/history/payment-$DATE

earnings=$(awk '/^Total/ {print $6,$7}' $SCRIPT_DIR/history/payment-$DATE)

if [ "$PUSHBULLET_DEVICE" -eq "" ]; then
	curl -s -u $PUSHBULLET_KEY: -X POST https://api.pushbullet.com/v2/pushes \
	--header 'Content-Type: application/json' \
	--data-binary '{"type": "note", "title": "'"$STORAGENODE_NAME"'", "body": "'"Gains potentiels à date pour le mois en cours : $earnings"'"}'
else
	curl -s -u $PUSHBULLET_KEY: -X POST https://api.pushbullet.com/v2/pushes \
	--header 'Content-Type: application/json' \
	--data-binary '{"type": "note", "title": "'"$STORAGENODE_NAME"'", "body": "'"Gains potentiels à date pour le mois en cours : $earnings"'", "device_iden": "'"$PUSHBULLET_DEVICE"'"}'
fi

exit 0
