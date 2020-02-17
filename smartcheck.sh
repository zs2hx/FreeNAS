#!/bin/bash
## Version 1.0 20200217
## install the smartctl package first! apt-get install smartctl
## PDJ credit to:
## https://gist.github.com/tommybutler/7592005
## https://www.ixsystems.com/community/threads/one-or-more-devices-has-experienced-an-unrecoverable-error.69236/
## suggestion for Zabbix environment 
## https://github.com/v-zhuravlev/zbx-smartctl

# Install:
# 1. Paste the contents of this file: vi smartcheck.sh
# 2. Make executable: chmod 755 smartcheck.sh

# Run:
# ./smartcheck.sh

#Expected result:
#Found: /dev/ada0
#        Checking.
#        Result: PASSED. Temperature: 33
#Found: /dev/ada1
#        Checking.
#        Result: PASSED. Temperature: 43
#Found: /dev/ada2
#        Checking.
#        Result: PASSED. Temperature: 42

# PDJ breaks on freenas
# if sudo true
# then
#    true
#else
#   echo 'Root privileges required'
#   exit 1
# fi

#Adjust for your own environment
for drive in /dev/ada[0-9]
do
    printf "Found: $drive\n"

    if [ ! -e $drive ]; then printf "\tSkipping.\n"; continue ; fi

    printf "\tChecking.\n"

    result=$(
    smartctl -a $drive 2>/dev/null
    )
	#Debug
    #printf "$result"
	
	# 190 Airflow_Temperature_Cel 0x0022   065   054   045    Old_age   Always       -       35 (Min/Max 26/35)
	# 194 Temperature_Celsius     0x0022   035   046   000    Old_age   Always       -       35 (0 18 0 0 0)
	# SMART overall-health self-assessment test result: PASSED

    status=$(
    echo  "$result" |
    grep '^SMART overall' |
	sed -e 's/[[:space:]]*$//' | #remove traling space
    awk '{ print $6 }'
    )
	
	temp=$(
    echo  "$result" |
    grep 'Temperature_Celsius' |
	sed -e 's/[[:space:]]*$//' | #remove traling space
    awk '{ print $10 }'
    )
	
    [ "$status" == "" ] && smart='unavailable'

	printf "\tResult: $status. Temperature: $temp\n"
done
