#!/bin/bash
if [ "$1" == "" ]
then
echo "You forgot an IP address"
#echo "Please enter like './ping_check.sh X.X.X'"

else
counter=0
ping_value=""
for ip in `seq 1 254`; 
do
ping_value=$(ping -c 1 $1.$ip | grep "64 bytes" | cut -d " " -f 4 | tr -d ":")

if [[ "$ping_value" != "" ]] 
then
((counter++))
echo $counter
echo $ping_value
fi
done
fi

