#!/bin/bash

declare -A org_array
declare -A org_int_array
counter=0

SyncArrays () {
org_array=$int_ip_arr

readarray -d $'\n' -t org_int_array_1 <<< "$arr"
for val in ${newarr[@]};
do
org_array[$val]=${int_ip_arr[$val]}

echo "ADDED"
echo $org_array[$val]
done
}

while true 
do
sleep 3
arr="$(ls /sys/class/net/)"
declare -A int_ip_arr
configuration=$(ifconfig)
readarray -d $'\n' -t newarr <<< "$arr"

for val in ${newarr[@]};
do 
ip=$(ifconfig $val | grep -o -P '(?<=inet ).*(?= netmask)')
subnet=$(ifconfig $val | grep -o -P '(?<=netmask ).*(?= broadcast)')
broadcast=$(ifconfig $val | grep -o -P '(?<=broadcast ).*')
int_specs=""
int_specs+=$ip
int_specs+=" , "
int_specs+=$subnet
int_specs+=" , "
int_specs+=$broadcast
int_ip_arr+=$val
int_ip_arr[$val]=$int_specs

done

if [ $counter == 0 ] ;
then 
SyncArrays
echo "Array Is Coppiedddd"
counter=1
fi

if [ $counter -gt 0 ] ;
then
STATUS="" 
STATUS_CHANGED=1
STATUS_VAR=0


for int in ${newarr[@]};
do
IFS=' , ' 
read -ra spec_array <<< ${int_ip_arr[$int]}
read -ra org_spec_array <<< ${org_array[$int]}

if [[ ${org_spec_array[0]} == ${spec_array[0]} ]] ;
then echo "Clean IP configurations!"
echo ${spec_array[0]}
else echo "Bad IP Configurations!!!"

STATUS+="Bad IP: ${spec_array[0]} | "
STATUS_VAR=1
echo ${org_spec_array[0]}
fi
if [[ ${org_spec_array[1]} == ${spec_array[1]} ]] ;
then echo "Clean Subnet configurations!"
echo ${org_spec_array[1]}
else echo "Bad Subnet Configurations!!!"

STATUS+="Bad Subnet: ${spec_array[1]} | "
STATUS_VAR=1
fi
if [[ ${org_spec_array[2]} == ${spec_array[2]} ]] ;
then echo "Clean BroadCast configurations!"
echo ${org_spec_array[2]}
else echo "Bad BroadCast Configurations!!!"

STATUS+="Bad BroadCast: ${spec_array[2]} | "
STATUS_VAR=1
fi
done
fi
echo "Status var is: $STATUS_VAR"
echo $STATUS
if [[ $STATUS_VAR -gt 0 ]] ;
then zenity --question --text="Your Network configurations is modified\n$STATUS\nDo you allow this changes? If no you have 5 minutes to reset it." --width=300
CONTINUE=$?

fi
if [[ $CONTINUE == 1  ]] ;
then 

for int in ${newarr[@]};
do
IFS=' , ' 
read -ra org_spec_array <<< ${org_array[$int]}
echo "|$int| |${org_spec_array[0]}| |${org_spec_array[1]}|"
echo <your_password> | sudo -S ifconfig "$int" "${org_spec_array[0]}" netmask "${org_spec_array[1]}"
done

int_ip_arr=$org_array

readarray -d $'\n' -t org_int_array_1 <<< "$arr"
for val in ${newarr[@]};
do
int_ip_arr[$val]=${org_array[$val]}

echo $org_array[$val]
done

else 
SyncArrays
fi

if [ "${#newarr[@]}" == "${#org_int_array_1[@]}" ] ;
then echo "The Number of interfaces is correct!"
else echo "The Number of interfaces is incorrect!"
zenity --question --text="Your Network Interfaces number is changed\nDo you accept this changes?"
CONTINUE_2=$?
fi
if [[ $CONTINUE_2 == 1 ]] ;
then notify-send "Interface not accepted!\nThe System will reboot!"
echo <your_password> | sudo -S reboot
else 
SyncArrays
fi

int_ip_arr=()
STATUS=""
STATUS=0
done

