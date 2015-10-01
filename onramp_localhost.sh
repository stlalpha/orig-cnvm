#!/bin/sh
#setup sneaker onramp from localhost to criu-local-c into the container network

echo "Forwarding local port 22 to criu-local-c:2222"
sudo ncat --sh-exec "ncat criu-local-c 2222" -l 22 --keep-open 2>&1 >/dev/null &
echo "Forwarding local port 80 to criu-local-c:8080"
sudo ncat --sh-exec "ncat criu-local-c:8000" -l 80 --keep-open 2>&1 >/dev/null &
