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
```shell
user@host1~$ wget -qO- https://raw.github.com/stlalpha/cnvm/footlocker-bootstrap.bash | sh
```
