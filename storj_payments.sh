#!/bin/bash -e

# -u option: exits if error on unset variables
# -e option: exits if any commands exits non-zero

# This script will evaluate the amount to be paid for being a Storage Node on Storj Network and send a pushbullet notification about it.
# The script is based on storj_earnings script by ReneSmeekes.
# This script has been developed by Jeremy Fritzen. Thank you for sharing and keeping author name in it.

# Use this script with a user authorized to run Docker commands.

###############################################
############## SCRIPT PARAMETERS ##############
###############################################

# Do not change these variables

SCRIPT_DIR=$(cd $( dirname ${BASH_SOURCE[0]}) && pwd )
DATE=$(date +%Y-%m-%d-%H-%M)

##############################################
############## SCRIPT EXECUTION ##############
##############################################

for conf_file in `ls $SCRIPT_DIR/*.conf`
do
	. $conf_file

	TEMP_DIR=$SCRIPT_DIR/$CONTAINER_NAME/infodbcopy

	[[ -d $SCRIPT_DIR/$CONTAINER_NAME/infodbcopy ]] || mkdir -p $SCRIPT_DIR/$CONTAINER_NAME/infodbcopy
	[[ -d $SCRIPT_DIR/$CONTAINER_NAME/history ]] || mkdir -p $SCRIPT_DIR/$CONTAINER_NAME/history


	[[ `docker ps --format '{{.Names}}'` == *$CONTAINER_NAME* ]] || continue
	docker stop -t 300 $CONTAINER_NAME

	cp $STORAGE_DIR/bandwidth.db $TEMP_DIR/
	cp $STORAGE_DIR/storage_usage.db $TEMP_DIR/
	cp $STORAGE_DIR/piece_spaced_used.db $TEMP_DIR/
	cp $STORAGE_DIR/reputation.db $TEMP_DIR/
	cp $STORAGE_DIR/heldamount.db $TEMP_DIR/

	docker start $CONTAINER_NAME

	python $SCRIPT_DIR/storj_earnings/earnings.py $TEMP_DIR $1 | tee $SCRIPT_DIR/$CONTAINER_NAME/history/payment-$DATE

	earnings=$(awk '/^TOTAL/ {print $8,$9}' $SCRIPT_DIR/$CONTAINER_NAME/history/payment-$DATE)

	if [ "$PUSHBULLET_DEVICE" -eq "" ]; then
		curl -s -u $PUSHBULLET_KEY: -X POST https://api.pushbullet.com/v2/pushes \
		--header 'Content-Type: application/json' \
		--data-binary '{"type": "note", "title": "'"$STORAGENODE_NAME"'", "body": "'"Gains potentiels à date pour le mois en cours : $earnings"'"}'
	else
		curl -s -u $PUSHBULLET_KEY: -X POST https://api.pushbullet.com/v2/pushes \
		--header 'Content-Type: application/json' \
		--data-binary '{"type": "note", "title": "'"$STORAGENODE_NAME"'", "body": "'"Gains potentiels à date pour le mois en cours : $earnings"'", "device_iden": "'"$PUSHBULLET_DEVICE"'"}'
	fi

done


exit 0
