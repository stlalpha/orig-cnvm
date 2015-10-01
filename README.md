# cnvm

<b>C</b>loud <b>N</b>ative <b>V</b>irtual <b>M</b>achine

cnvm is a cloud native virtual machine.  That is, a virtual machine that is as portable as a container.

This is very experimental.  We are adding functionality all the time.  Please help us make it better!

The Cloud Native VM platform allows you to deploy Virtual Machines that are:
 
- Vendor-Agnostic
- Cloud-Agnostic
- Agile (dynamic, fluid, etc.)
- Software Defined (compute, networking, storage, etc.)
- Persistent
- Identical
- Secure
- Open and Shared
 

**Want to setup a N-node test environment?**



1.  Create N number of Ubuntu 15.04 vm's somewhere
   - They must be able to see each other over the network on port 22/tcp and 6783/tcp and 6783/udp

2.  Pick a non-root username to use for the installation (in our example the username will be "user")
   - This user must be in the sudoers file
   - You need to generate (or use one that you already have) an ssh keypair and put the public key in each hosts ~/.ssh/authorized\_keys file

3. Choose one of your machines to be the "master" node.  This is the machine that you will launch the cnvm's from.

4. Log into the master node as "user" and execute:
   
    user@host1~$ wget -qO- https://raw.github.com/stlalpha/cnvm/footlocker-bootstrap.bash | sh
    

5. Follow the prompts.  You will be logged out twice.  Once after docker is installed to get you into the right groups and a second time after the bootstrap configuation is complete

6. When you log back in after docker bootstrap is installed - you will be prompted to answer whether or not this is the master node.  Answer "y".  It will then ask you to enter your targets.  This is where you enter all of the nodes in your setup.  If you only have two (your master and another) you enter them both here.  If you have 5 (your master and 4 more) you enter all of those here.  The format is one entry per line, and its username@host.  In our example I enter:
    
    user@172.17.135.138
    user@172.17.135.139
    

7. The process will now install and configure the remaining software

8. While this is running, please log into each of the additional nodes as your user (again, in our example, "user") and execute:
    
    user@hostX~$ wget -qO- 'https://raw.github.com/stlalpha/cnvm/footlocker-bootstrap.bash | sh
    

9. Follow the prompts - you will be logged out twice.  Once after docker is installed to get you into the right groups and a second time after the bootstrap configuation is complete

10. When you log back in after docker bootstrap is installed - you will be prompted to answer whether or not this is the master node.  Answer "n"

11. The process will now install and configure the remaining software.  This takes about 15 minutes per node.  You can run them all in parallel if you would like.

12. When the process completes, it will log you out from both the master and any nodes.

13. When the master process has completed and all of the other nodes have completed - you are done with the build process, and ready to deploy your first cnvm.

14. Log back into the master node - and it will automatically launch the first cnvm.  When completed, it will be available for connection at 10.100.101.111.  From the master node:
    
    user@masternode~$ ssh user@10.100.101.111
    The password is 'password'
    

15. Open a second ssh session to the master node.  And teleport (hot migrate) it to one of the other nodes.  To do this simply:
    user@masternode~$ cd cnvm
    user@masternode~$ ./teleport.sh sneaker01.gonkulator.io user@targethost:/home/user/sneakers
-Where "targethost" is another one of your non-master nodes that you would like the cnvm to move to
