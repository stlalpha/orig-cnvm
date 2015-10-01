# cnvm

<b>C</b>loud <b>N</b>ative <b>V</b>irtual <b>M</b>achine

cnvm is a cloud native virtual machine.  That is, a virtual machine that is as portable as a container.

The Cloud Native VM platform allows you to deploy Virtual Machines that are:
 
·      Vendor-Agnostic
·      Cloud-Agnostic
·      Agile (dynamic, fluid, etc.)
·      Software Defined (compute, networking, storage, etc.)
·      Persistent
·      Identical
·      Secure
·      Open and Shared
 
Vendor-Agnostic:
 
Cloud Native VMs can be deployed on any hypervisor or bare metal provider.  VMware, Microsoft HyperV, Xen, KVM.  You choose one, some, or all, cnvms are not restricted to any vendor’s hypervisor or bare metal offering.
 
Cloud-Agnostic:
 
Cloud Native VMs can be deployed into any cloud provider.  Choose between cloud providers like: Amazon, Google, Microsoft Azure, VCloud Air, cnvms are not restricted to any cloud provider or by a cloud provider’s proprietary features.

Agile:
 
Cloud Native VMs are mobile.  Migrate cnvms between  private and public clouds.  For example, cnvms running on VMware in your East Coast datacenter, can be migrated to your VMware cluster running in your West Coast datacenter or they be moved from your datacenter to an Amazon AWS cloud presence. 
 
Migrations done with cnvms can be performed without powering it off.  They are migrated live (see a video of this capability here).
 
Today, vendors offer offer VM migrations to like-for-like hypervisors as a licensed feature, but cnvms provide the same capability without the like-for-like restrictions.  Public to private, Public to Public, HyperV to Xen to VMware, and every combination in between.  You have the choice.
Take snapshots of your running cnvms and restore them when/where you like. 
 
Software Defined Infrastructure:
 
The cnvm platform allows you to logically define and link software defined compute, storage, and networking.  Use them to create global networks stretching your network elastically into the providers of your choice.
 
In the diagram below we see several types of public and private cloud resources.  Despite the actual local networking and configurations, the cnvm platform performs as if it was on a local network.  

Persistent:

Global networking allows a cnvm to maintain the same IP address and hostname, regardless of where it currently resides.  Migrating a cnvm to another provider doesn’t require changes to the firewall or load balancer configurations.  When you execute your Disaster Recovery (DR) tests, you won’t have to spend hours reconfiguring your environments to point to the “new” DR addresses, because the addresses remain the same.

Identical:

Templatize your application stack within cnvms and run the same images on the developer’s machine that you run in production, eliminate software disparity between the environments.  Run them on whatever virtualization or cloud provider you prefer – and you know that it’s going to function the same.
Take snapshots of your running cnvms and restore them when/where you like.  Your warm-standby DR datacenter is no longer needed.

Forensically recreate a production issue for troubleshooting – take a snapshot of your running Amazon Cloud cnvms and restore them inside your physical datacenter for detailed root cause analysis and problem resolution.
 
Secure:
 
Define security controls on the cnvm and global networks ensuring their consistent application because of the features mentioned above.
 
Open and Shared:
 
Cloud Native VMs are open-source.  Intentionally open to avoid affinity for a particular infrastructure or cloud vendor ecosystem.  Being shared open-source allows them to be customized for use cases that are yet to be realized.

Cloud Native VMs are currently utilizing features and functionality from the following open source projects:

Linux 
Runc
CRIU
Weave
Docker
