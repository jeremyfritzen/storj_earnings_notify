# Storj Earnings Notify
Notify Storj V3 earnings estimation via Pushbullet

## Prerequisites
Python is required to run this script.
This script must be run by a user authorized to run Docker commands.

This script was developed and tested on Debian 9.
It should work on other Debian-based Linux distribution.

### Information
The Docker container will be stopped while the script will copy the required files for earning calculation.
Even if this doesn't seem to be necessary, it's better to do it to make sure it won't affect the node consistency.

## Configuration
1. Make sure the script is executable: ```chmod +x storj_payments.sh```
2. Fill-in the required USER PARAMETERS in the storj_payments.sh script.

3. Configure daily notifications
	* ``` sudo crontab -e ```
	* Then add the following line, replacing "path_to_the_script" by the appropriate absolute path: ``` 0 7 * * * /path_to_the_script/storj_payments.sh ```

## Usage
Earnings for current month:
```
./storj_payments.sh
```

Earnings for previous months:
```
./storj_payments.sh 2019-05
```