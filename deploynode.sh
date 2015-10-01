#!/bin/bash

set -e

usage()
{
echo ""
echo "Usage: $0 user@host network/mask"
echo "e.g., $0 jm@server1.gonkulator.io 10.100.101.0/24"
echo ""
exit 1
}

#functions / defines

targets=($(cat targets))
export sshtarget=$1
export dsthostname=$(echo ${sshtarget} | awk -F\@ '{print $2}')
export dstusername=$(echo ${sshtarget} | awk -F\@ '{print $1}')
export clusternetwork=$2
export debug=$3
export clusternetworknocidr=$(echo ${clusternetwork} | awk -F\/ '{print $1}')
export clusternetworkcidr=$(echo ${clusternetwork} | awk -F\/ '{print $2}')
export clusternetworknolastoctet=$(echo ${clusternetworknocidr} | awk -F. '{print $1"."$2"."$3"."}')
export PID=$$

##colors
RESTORE=$(echo '\033[0m')
RED=$(echo '\033[00;31m')
GREEN=$(echo '\033[00;32m')
YELLOW=$(echo '\033[00;33m')
BLUE=$(echo '\033[00;34m')
MAGENTA=$(echo '\033[00;35m')
PURPLE=$(echo '\033[00;35m')
CYAN=$(echo '\033[00;36m')
DARKGRAY=$(echo '\033[00;90m')
LIGHTGRAY=$(echo '\033[00;37m')
LRED=$(echo '\033[01;31m')
LGREEN=$(echo '\033[01;32m')
LYELLOW=$(echo '\033[01;33m')
LBLUE=$(echo '\033[01;34m')
LMAGENTA=$(echo '\033[01;35m')
LPURPLE=$(echo '\033[01;35m')
LCYAN=$(echo '\033[01;36m')
WHITE=$(echo  '\033[01;37m')
##colors



	status() {
	#echo "${GREEN}█ ${GRAY} $*${RESTORE}"
	echo "[o] $*"
}
	error() {
		#echo "${LRED}█${RED} $*${RESTORE}"
		echo "[!] ERROR: $*"
	}





#main

if  [ $# -lt 2 ] ; then
	usage
	exit 1
fi

if [ ${clusternetworkcidr} -ne 24 ] ; then
	error Sorry - currently only support /24 networks
	exit 1
fi

if [ ${debug} = debug ] ; then
	status sshtarget = ${sshtarget}
	status dsthostname = ${dsthostname}
	status dstusername = ${dstusername}
	status clusternetwork = ${clusternetwork}
	status clusternetworkcidr = ${clusternetworkcidr}
	status clusternetworknocidr = ${clusternetworknocidr}
	status clusternetworknolastoctet = ${clusternetworknolastoctet}
fi

######

export OCTET=1

for i in ${targets[@]}; do
status Starting weave on $(echo $i | awk -F\@ '{print $2}')
#ssh ${i} "weave launch --ipalloc-range ${clusternetwork}"
ssh ${i} "weave launch" 
status Connecting $(echo $i | awk -F\@ '{print $2}') to CLAN
ssh ${i} "weave expose ${clusternetworknolastoctet}${OCTET}/24"
status Copying teleport script to $(echo $i | awk -F\@ '{print $2}'):.
scp teleport.sh ${i}:.
((OCTET++))

done

status Interconnecting nodes...
for i in ${targets[@]}; do
	if [ ${i} != "${targets[0]}" ] ; then
	status Connecting $(echo ${targets[0]} | awk -F \@ '{print $2}') to $(echo $i | awk -F\@ '{print $2}')
	#dont even ask - yes this is the most portable system resolver based fix i could come up with overnight
	ssh ${targets[0]} weave connect $(ping -t1 -c1 $(echo $i | awk -F\@ '{print $2}') | grep PING | awk '{print $3}' | sed s/[\)\(\:]//g)
	#ssh ${targets[0]} weave connect $(echo $i | awk -F\@ '{print $2}')
	else
	status "Skipping self..."
	fi
	done



