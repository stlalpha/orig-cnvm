#!/bin/sh
#teleport a cnvm, yo.
#jim@gonkulator.io 8/21/2015
#pubbranch test

	set -e
#load and export the ssh -o StrictHostKeyChecking=no-agent and all the priv keys

#	eval `ssh-agent` 2>&1 >/dev/null
#	ssh-add ~/keys/* 2>/dev/null

#	vestigal cruft from when I took the container to snapshot as $1 - will remove once we get the GUI nailed up -jm
#	export container=$1

export cnvmname=$1
export container=$(docker inspect $(docker ps | grep ${cnvmname} | awk '{print $1}') | head -3 | grep Id | awk '{print $2}' | sed s/\"//g | sed s/\,//g)
export cnvmweaveipaddr=$(weave ps | grep $(docker inspect ${cnvmname} | grep \"Hostname\": | awk '{print $2}' | awk -F\" '{print $2}') | awk '{print $3}')
export dst=$2
export hosty=$(echo ${dst} | awk -F: '{print $1}')
export dsty=$(echo ${dst} | awk -F: '{print $2}')
export dstuser=$(echo ${dst} | awk -F@ '{print $1}')
export PID=$$

##test 2
#functions / defines

##colors
if [ -t 1 ]; then
    ncolors=$(tput colors)
    if [ -n "${ncolors}" ] && [ ${ncolors} -gt -1 ]; then
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
    fi
fi
##colors

	status() {
	#echo "${PURPLE}[${LGREEN}-${PURPLE}]${CYAN} $*${RESTORE}"
	echo "${GREEN}█${GRAY} $*${RESTORE}"
#	echo "o $* "
}
	error() {
		#echo "${PURPLE}[${LRED}!${PURPLE}]${LRED} $*${RESTORE}"
		echo "${LRED}█${RED} $*${RESTORE}"
#	echo "- $*"
	}

	remote_ok() {
	status Checking remote landing-zone...
	testit=$(ssh -o StrictHostKeyChecking=no ${hosty} whoami)
	if [ $testit != "$dstuser" ] ; then 
		error You dont have remote ssh -o StrictHostKeyChecking=no rights! Bailing....
		exit 100
	fi
	tesit2=$(ssh -o StrictHostKeyChecking=no ${hosty} "ls -la ${dsty} 2>1 | grep -v cannot| wc -l")
	if [ $tesit2 -lt 1 ] ; then
		error REMOTE Target directory doesn\'t exist. Bailing!
		exit 100
	fi
	status Remote landing zone OK
}

	sanitize_it() {
		status Sanitizing ${hosty}
		#echo "rm -rf ~/sneakers/*" | ssh ${hosty} $(< /dev/fd/0) 2>&1 > /dev/null
		#echo "docker kill \$(docker ps | grep -v weave | grep -v CONTAINER | awk '{print \$1}')" | ssh ${hosty} $(< /dev/fd/0)
		#echo "docker rm \$(docker ps -a | grep -v weave | grep -v CONTAINER | awk '{print \$1}')" | ssh ${hosty} $(< /dev/fd/0)
		#echo "docker rmi \$(docker images | grep -v weaveworks | grep -v REPO |  awk '{print \$3}')" | ssh ${hosty} $(< /dev/fd/0)
	}

	snapshot() {
	        
	        status Setting up local landing-zone...
	        mkdir -p /home/$(whoami)/sneakers/${container}.$$
	        IMAGEDIR=/home/$(whoami)/sneakers/${container}.$$
	        status Checkpointing sneaker ${GRAY}${container}
	        docker checkpoint --image-dir=${IMAGEDIR} --work-dir=/tmp ${container} >/dev/null
	        status Checkpoint success...
	        #Get rid of the "/" in the image name because its a pain in the ass to deal with on the cmdline
	        SOURCEIMAGE=$(docker inspect ${container} | grep \"Image\": | tail -1 | awk '{print $2}' | sed s/\"//g | sed s/,//g | sed s/\\//-/g)
	        DESTIMAGE=${IMAGEDIR}/${SOURCEIMAGE}-$$.tar.gz
	        export DESTIMAGE
	        status Registering sneaker image...
	        docker commit $1 $SOURCEIMAGE-$$ >/dev/null
	    	status Streaming sneaker image...
	    	docker save $SOURCEIMAGE-$$ | gzip - | ssh -o StrictHostKeyChecking=no -C ${hosty} "gzip -dc | docker load"
	    	status Streaming sneaker image COMPLETE
	}

	teleport() {
		
		status Transferring machine state information....
		scp -o StrictHostKeyChecking=no -r $1 $2 > /dev/null
		status Machine state information transfer COMPLETE
		status Creating remote surrogate...
		REMOTESNEAKER=$(ssh -o StrictHostKeyChecking=no ${hosty} docker create --name=${cnvmname} ${SOURCEIMAGE}-${PID}) 
		ssh -o StrictHostKeyChecking=no ${hosty} docker start ${REMOTESNEAKER} >/dev/null
		ssh -o StrictHostKeyChecking=no ${hosty} docker kill ${REMOTESNEAKER} >/dev/null
		status Remote surrogate creation  ${REMOTESNEAKER}  COMPLETE 
		status Restoring instance run state...
		ssh -o StrictHostKeyChecking=no ${hosty} docker restore --work-dir=/tmp --image-dir=${dsty}/${container}.${PID} --force ${REMOTESNEAKER} >/dev/null
		status Instance run state restoration  COMPLETE
		status Updating remote native IP addr and routes
		REMOTEIPADDR=$(ssh -o StrictHostKeyChecking=no ${hosty} docker inspect ${REMOTESNEAKER} | grep IPAddress\" | sed s/\"//g | sed s/,//g | awk '{print $2}')
		ssh -o StrictHostKeyChecking=no ${hosty} docker exec --privileged=true ${REMOTESNEAKER} ifconfig eth0 ${REMOTEIPADDR} up 
		ssh -o StrictHostKeyChecking=no ${hosty} "docker exec --privileged=true ${REMOTESNEAKER} route add -net 0.0.0.0 netmask 0.0.0.0 gw 172.17.42.1 || /bin/true" 2>&1 >/dev/null
		status Updating remote native IP addr and routes COMPLETE
		status Bringing up Weave sneaker-LAN.....
		#yes - the below is actually necessary if you want weave to create the arp entry
		ssh -o StrictHostKeyChecking=no ${hosty} weave attach ${cnvmweaveipaddr} ${REMOTESNEAKER} 2>/dev/null
		ssh -o StrictHostKeyChecking=no ${hosty} weave detach ${cnvmweaveipaddr} ${REMOTESNEAKER} 2>/dev/null
		ssh -o StrictHostKeyChecking=no ${hosty} weave attach ${cnvmweaveipaddr} ${REMOTESNEAKER} 2>/dev/null
		status Weave sneaker-LAN ONLINE
		status Instance teleportation COMPLETE
		status New sneaker id: ${REMOTESNEAKER}
		status New native IP ADDR: ${REMOTEIPADDR}
		status Weave SLAN IP ADDR: ${cnvmweaveipaddr}
	}


	#main
	

	status Checking remote site
	remote_ok
	status Sanitizing site
	sanitize_it

	status Snapshotting sneaker: ${container}
	
	snapshot ${container}
	
	status Teleporting sneaker: ${container}
	
	teleport ${IMAGEDIR} ${dst}
	
	status Cleaning up...
	docker rm ${container}
	status DONE
