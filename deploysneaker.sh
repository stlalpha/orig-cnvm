#!/bin/sh


usage()
{
echo ""
echo "Usage: $0 user@host imagename hostname ipaddress"
echo "e.g., $0 jm@server1.gonkulator.io stlalpha/myphusion sneaker01 10.100.101.100/24"
echo ""
exit 1
}

#functions / defines

export sshtarget=$1
export dsthostname=$(echo ${sshtarget} | awk -F\@ '{print $2}')
export dstusername=$(echo ${sshtarget} | awk -F\@ '{print $1}')
export cnvmrunimage=$2
export cnvmhostname=$3
export cnvmipaddr=$4
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
	echo "${GREEN}█ ${GRAY} $*${RESTORE}"
}
	error() {
		echo "${LRED}█${RED} $*${RESTORE}"
	}


#main

if  [ $# -lt 4 ] ; then
	usage
	exit 1
fi

status sshtarget = ${sshtarget}
status dsthostname = ${dsthostname}
status dstusername = ${dstusername}

status Deploying cnvm hostname: ${cnvmhostname} image: ${cnvmrunimage} ipaddr: ${cnvmipaddr}
remotecontainerid=$(ssh ${sshtarget} docker run -d --name=${cnvmhostname} ${cnvmrunimage})
status Attaching global hostname and IP ${cnvmhostname}/${cnvmipaddr}
ssh ${sshtarget} weave attach ${cnvmipaddr} ${remotecontainerid}
status Setting cnvm hostname
ssh ${sshtarget} docker exec --privileged=true ${remotecontainerid} "hostname ${cnvmhostname}"
status Success	
