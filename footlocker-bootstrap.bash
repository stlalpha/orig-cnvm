#!/bin/bash
#footlocker-host-bootstrap.sh jm@gonkulator.io 8/22/2015
# Adam Thornton 30 September 2015

#functions

status() {
	echo "[*] $*"
}

get_targets() {
    echo "Enter target machines in form user@host; blank line when done."
    while true ; do
	read line
	l=$(echo $line | sed -e 's/^\s+//' | sed -e 's/\s+$//')
	if [ -z "${l}" ]; then
	    break
	fi
	set +e
	echo ${l} | grep -q '@'
	rc=$?
	set -e
	if [ "x${rc}" != "x0" ]; then
	    echo "[X] Targets must be entered in form user@host."
	    continue
	fi
	targets=("${targets[@]}" ${l})
    done
}

DOCKER_INSTALLED=~/.DOCKER_INSTALLED
SNEAKERCLONED=~/.SNEAKER_CLONED
set -e

if [ ! -f "${DOCKER_INSTALLED}" ]; then
#you need git - install it first
sudo apt-get install git -y
sudo apt-get install docker.io -y
#flag that docker is installed now
sudo service docker start 
touch ~/.DOCKER_INSTALLED
fi

if [ ! -f "${SNEAKERCLONED}" ]; then
clonesrc="git@github.com:stlalpha/cnvm.git"
git clone ${clonesrc}
cd cnvm
#flag that you cloned the cnvm dir
touch ~/.SNEAKER_CLONED
fi


set +e
groups | grep -q docker
rc=$?
set -e
#if [ "x${rc}" != "x0" ] && [ -z "${JUSTADDED}" ]; then
if [ "x${rc}" != "x0" ] ; then
    echo "**************************"
    echo "Have to log you out in order to get you in the docker group."
    echo "Please log in again and installation will continue."
    echo "**************************"
    sudo usermod -aG docker $(logname)
    touch ~/.BOOTSTRAP_LOGOUT_FLAG
    cat <<EOF >> ~/.bash_profile
#!/bin/bash
if [ -f ~/.BOOTSTRAP_LOGOUT_FLAG ]; then 
    rm ~/.BOOTSTRAP_LOGOUT_FLAG && cat ~/.profile > ~/.bash_profile
    echo "[o] Enter target footlocker hosts (including this one)"
    echo "[o] Format is: username@host e.g., jm@172.16.157.135"
    cd cnvm && ./footlocker-bootstrap.bash

fi
EOF
    kill -HUP $PPID
    exit 
fi

declare -a targets
get_targets
now=$(date +%Y%m%d%H%M%s)
if [ -f targets ]; then
    mv targets targets.${now}
fi
printf "%s\n" "${targets[@]}" > targets
while true ; do
    echo "Will this be the master node [Y|N]?"
    read line
    master=$(echo $line | sed -e 's/^\s+//' | sed -e 's/\s+$//' | cut -c 1 | tr [:upper:] [:lower:] )
    if [ ${master} == "y" ] || [ ${master} == "n" ]; then
	break
    fi
done

#prep host packages
set +e
status Preparing host packages...
sudo apt-get update -y
sudo apt-get upgrade -y
sudo apt-get install -y build-essential libprotobuf-dev libprotobuf-c0-dev protobuf-c-compiler protobuf-compiler python-protobuf curl
set -e
#make the dirz
status Criu download and build...
mkdir -p ~/development/src
cd ~/development/src

#grab criu and build it and install it
git clone https://github.com/gonkulator/criu.git 
cd ~/development/src/criu
make
sudo make install-criu

#grab docker and install it
#status Base docker download and build...this takes a bit of time...
#cd ~
#curl -sSL https://get.docker.com/ | sh 

#Go experimental
status Experimental docker download and build....this takes more time...
cd ~/development/src
git clone https://github.com/gonkulator/docker.git 
cd ~/development/src/docker
git checkout fix-restore-network-cr-combined-1.9 
make DOCKER_EXPERIMENTAL=1 binary 
#stop the docker service
sudo service docker stop 
#copy new binary
sudo install -m 0755 bundles/1.9.0-dev/binary/docker /usr/bin/docker
#start new docker
sudo service docker start 
#install weave
cd ~/development/src
mkdir -p weave
cd weave
status Installing weave...
curl -L git.io/weave -o weave
sudo install -m 0755 weave /usr/local/bin/weave
sync
sleep 2
mkdir -p ~/sneakers
if [ ${master} == "y" ]; then 
    status Master node: setting up .bash_profile to execute sneaker deployment on reboot...
    cat <<EOF >> ~/.bash_profile
if [ -f ~/UNCONFIGURED ]; then 
    cd cnvm && ./deploynode.sh foo 10.100.101.0/24 && ./deploysneaker.sh ${targets[0]} stlalpha/myphusion:stockticker sneaker01.gonkulator.io 10.100.101.111/24 && cd - && rm ~/UNCONFIGURED && rm ~/.SNEAKERCLONED && rm ~/.DOCKER_INSTALLED && cat ~/.profile > ~/.bash_profile
fi
EOF
    touch ~/UNCONFIGURED
fi
status Footlocker bootstrap complete!
status Log back in to auto-deploy the first cnvm!
status Rebooting node....
sudo reboot
