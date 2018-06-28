#!/bin/bash

app_path='/home/pi/apps/git/swamp-api'
house_temp_call='/usr/bin/python therm.py -t'
set_cool_temp_call='/usr/bin/python therm.py -s'
therm_mode_call='/usr/bin/python therm.py -m'
fan_status_call='/usr/bin/python therm.py -f'

cd $app_path

while true; do

	house_temp=$($house_temp_call)
	set_cool_temp=$($set_cool_temp_call)
	therm_mode=$($therm_mode_call)
	fan_status=$($fan_status_call)

	if [ "$therm_mode" == "3" ]
	then
		echo "Cooling Requested"
		echo "Requested Temp:" $set_cool_temp
		if [ "$fan_status" == "True" ]
		then
			echo "House Fan On"
			temp_diff=$(( $house_temp - $set_cool_temp ))
			echo "Temp Difference:" $temp_diff
			if (( $temp_diff < 2  ))
			then
				echo "Low Cool"
				curl -X GET 192.168.3.234/swamp/low-cool
			elif (( $temp_diff > 1  ))
			then
				echo "High Cool"
                                curl -X GET 192.168.3.234/swamp/high-cool
			fi
		else
			echo "Swamp Cooler not needed to cool"
			curl -X GET 192.168.3.234/swamp/off
		fi
	else
		echo "Swamp Cooler Off"
		curl -X GET 192.168.3.234/swamp/off
	fi
	echo "Current Temp:" $house_temp
	sleep 30
done
