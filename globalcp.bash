#!/bin/bash
#for i in jm@criu-local ubuntu@criu-aws-saopaulo jm@criu-google-belgium jm@criu-digitalocean-singapore azureuser@criu-azure-japan ; do echo " " ; echo "$i"; scp $* $i:.; done
for i in $(cat targets) ; do echo " " ; echo "$i"; scp $* $i:.; done
