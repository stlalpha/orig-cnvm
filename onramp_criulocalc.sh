#!/bin/sh
#setup sneaker onramp from criu-local-c into the container network


#sudo ncat --sh-exec "ncat ${dsthost} ${dstport}" -l ${lclport} --keep-open
echo "Forwarding local port 2222 to 10.100.101.100:22"
sudo ncat --sh-exec "ncat 10.100.101.100 22" -l 2222 --keep-open 2>&1 >/dev/null &
echo "Forwarding local port 8000 to 10.100.101.100:8080"
sudo ncat --sh-exec "ncat 10.100.101.100 8080" -l 8000 --keep-open 2>&1 >/dev/null &
