![image](https://github.com/user-attachments/assets/2272dd3d-30b6-4ee0-a4ed-d81ceee2f5de)<h1 align="center">
Kernel-based Virtual Machine
</h1>  




<p align="center">  
  <img src="https://img.shields.io/badge/-Virtualization-blue?style=flat" />  
  <img src="https://img.shields.io/badge/-KVM-red?style=flat" />  
</p>  



<p align="center">
  <img src="https://github.com/user-attachments/assets/e742266a-6bbc-4566-8ffc-f6a92995bec4" width="150" />
</p>

<hr/>

# Introduction
KVM (Kernel-based Virtual Machine) is an open-source virtualization infrastructure for the Linux kernel that transforms it into a type-1 hypervisor.


### ✅ Advantages
- **Scalability**: Supports large-scale virtualization deployments
- **Cost-effective**: Open-source solution with no licensing fees
- **Security**: Integrates with Linux security features including SELinux
- **Thin Provisioing**: Kvm works with thin provisioing in the aspect of disks file as snap below

<br/>

![image](https://github.com/user-attachments/assets/26a80bfc-f6d0-43a8-ab15-38853e4eaab2)

<br/>

- **Live and Offline Migration**: Supports both live and offline VM migration, this feature helps when any maintenance is planned on the KVM host
- **Resource `Overcommitment`**: Enables allocation of more virtual resources than physically available

<br/>

> **Note:**  
> Overcommitting in KVM (Kernel-based Virtual Machine) refers to the practice of allocating more virtualized resources to guest virtual machines than are physically available on the host system. This is possible because most VMs don't use 100% of their allocated resources at all times.



**Benefits of `Overcommitting`**:
- Improved hardware utilization
- Reduced infrastructure costs
- Flexible resource allocation

**Risks of `Overcommitting`**:
- Potential performance degradation if all VMs demand full resources simultaneously
- Potential for VM crashes or host instability if overcommitment is too aggressive
- Requires careful monitoring and management
- Not ideal for performance-sensitive workloads

##

### ⚠️ Limitations
- Requires specific processor extensions (Intel VT-x or AMD-V)
- Advanced networking can be complex
- Enterprise features may need additional tooling


<hr/>


# Hypervisor Comparison

### Type 1 Hypervisor (Bare-Metal)
Runs directly on the host's hardware to control the hardware and manage guest OSes.

**Examples:**
- XEN
- IBM LPARs
- ESXi

### Type 2 Hypervisor (Hosted)
Runs as a software layer on top of a host operating system.

**Examples:**
- VMware Workstation
- VirtualBox

### Key Differences

| Feature          | Type 1 Hypervisor          | Type 2 Hypervisor          |
|------------------|---------------------------|---------------------------|
| **Performance**  | High (direct hardware)  | Moderate (host overhead) |
| **Latency**      | Low                       | Higher                    |
| **Use Cases**    | Servers, Cloud            | Dev/Testing               |
| **Deployment**   | Enterprise infrastructure | Local machines            |
| **Use env**   | Best for production workloads | Best for development environments           |


<br/>



> **Note:**  
> KVM is a type 1 hypervisor if you consider the OS as a hypervisor layer but in the meanwhile this OS can mange other apps, in this aspect you can consider the KVM as a type 2 hypervisor

<br/>

<hr/>

# Important Terminology for KVM

<br/>

| Term          | Description                                                                 |
|---------------|-----------------------------------------------------------------------------|
| **Host**      | Physical server that hosts guest VMs                                        | 
| **VM**        | Guest virtual machine created on a KVM host                                 | 
| **Virt-manager** | Graphical tool for managing VMs                                         | 
| **Virt-install** | CLI tool for installing guest VMs                                       | 
| **Libvirtd**  | Background service that manages KVM virtualization                          |

<br/>

<hr/>

# KVM Installation

> **Note:**  
> KVM is typically installed directly on a Linux OS, but for testing purposes, we set it up inside a virtual machine running on VMware Workstation under Windows. This creates a two-layer virtualization setup ... yes, it might sound crazy, but it provides valuable hands-on experience with KVM and deepens your understanding of nested virtualization.

## Prerequestes
- Two hard disks
- Two NICs
- Enough CPU and Memory

<br/>

<p align="center">
  <img src="https://github.com/user-attachments/assets/61c0e644-9bf6-4ca7-8ed3-ffd96baf1856" width="650" />
</p>

## Installation Steps
Check cpu info if it supports the vmx or svm for virtualization:

```bash
grep -E --color=auto 'vmx|svm|0xc0f' /proc/cpuinfo
```

If there is no output, check the virtualize Intel VT option in processor, VM setting  

![image](https://github.com/user-attachments/assets/38cbfa86-72f0-45cf-99d0-add0b33c9f25)

Configure repos in Centos:
```bash
sudo vi /etc/yum.repos.d/CentOS-Base.repo
```
Edit the baseurl and hash the mirror:
```bash
baseurl=http://vault.centos.org/7.9.2009/os/$basearch/
#mirrorlist=http://mirrorlist.centos.org/?release=7&arch=$basearch&repo=os&infra=stock
```
After editing use this commands:
```bash
sudo yum clean all
sudo yum makecache
sudo yum update
```
Install these packages:
```bash
yum install virt-install qemu-kvm libvirt libvirt-python libquestfs-tools virt-manager -y
```
Enable the libvirtd daemon:
```bash
systemctl enable --now libvirtd
```
Reboot the kvm-host:
```bash
systemctl reboot
```
Ensure the kernel modules for kvm are loaded:
```bash
modinfo kvm_intel
modinfo kvm
```
Configure the network in the kvm-host
> **Note:**  
> Libvirtd and it's services create a virtual bridge interface virbr0 with network 192.168.122.0/24 and create a nic virbr0-nic

- edit this file: /etc/sysconfig/network-scripts/ifcfg-<interface-name>:
```bash
TYPE=Ethernet
BOOTPROTO=none
NAME=<interface-name>
ONBOOT=yes
BRIDGE=virbr0
```
- create this file: /etc/sysconfig/network-scripts/ifcfg-virbr0:
```bash
TYPE=BRIDGE
DEVICE=virbr0
BOOTPROTO=none
ONBOOT=yes
IPADDR=<Natting-ip-in-your-system>
NETMASK=255.255.255.0
GATWAY=<your-gateway-in-your-system>
```
Enable forwarding:
```bash
echo net.ipv4.ip_forward = 1 > /usr/lib/sysctl.d/60-libvirtd.conf
/sbin/sysctl -p /usr/lib/sysctl.d/60-libvirtd.conf
```
Configure the firewalld:
```bash
firewall-cmd --permanent --direct --passthrough ipv4 -I FORWARD -i bridge0 -j ACCEPT
firewall-cmd --permanent --direct --passthrough ipv4 -I FORWARD -o bridge0 -j ACCEPT
firewall-cmd --reload
```
List the interfaces of the kvm-host:
```bash
virsh net-list
```
Edit the default interface:
```bash
virsh net-dumpxml default
virsh net-edit default
```
Create storage pool for storing th VM images:
```bash
vgcreate lab-kvm-storage /dev/sdb
lvcreate -l +100%FREE -n lab-kvm-lv lab-kvm-storage
mkfs.xfs /dev/mapper/lab--kvm--storage-lab--kvm--lv
```
Add the following entry in /etc/fstab:
```bash
echo "/dev/mapper/lab--kvm--storage-lab--kvm--lv   /var/lib/libvirt/images    xfs    defaults 0  0" >> /etc/fstab
mount –a
```
Create storage pool and start it, By default the libvirt use directory /var/lib/libvirt/images on a host as an initial file system storage pool:
```bash
virsh pool-define-as lab-kvm-storagepool  --type dir --target /var/lib/libvirt/images
virsh pool-autostart lab-kvm-storagepool
virsh pool-start  lab-kvm-storagepool
virsh pool-list
```
To see detailed info about pool:
```bash
virsh pool-list --all --details
```
Check if the guest OS is supported by kvm or not:
```bash
osinfo-query os
```
## To create vm with command line
> **Note:**  
> In kvm termenology .. domain is equal to vm
> 
<img src="https://github.com/user-attachments/assets/f127ff4d-9968-4b3d-ba83-c8c78e7c2495" width="650" />

<br/>

Copy the iso from windows to vm in vmware workstation:
```bash
scp "E:\Linux ISO\CentOS-7-x86_64-Minimal-2009.iso" root@<ip-of-kvm-host:/
```
Change the permissions in iso:
```bash
chmod 755 name-of-the-iso-file
```
Use virt-manager to create vm in GUI:
```bash
virt-manager
```
Choose ur customize resoure but choose the network virbr0

<br/>

## And then… heywalla
<p align="center">
    <img src="https://github.com/user-attachments/assets/132c2cc9-68e9-45f6-b50d-d800186e0734" width="700" />
</p>

<hr/>

# Understanding QEMU

QEMU (Quick Emulator) is a critical component in the KVM (Kernel-based Virtual Machine) virtualization stack.
Here's a detailed explanation:
## QEMU's Role in KVM
QEMU is an open-source machine emulator and virtualizer that works alongside KVM to provide complete virtualization solutions. In the KVM context
- Hardware Emulation: QEMU provides device emulation (CPU, memory, storage, network devices, etc.)
- User-space Component: While KVM operates in kernel space, QEMU runs in user space handling I/O and device emulation
- Management Interface: QEMU offers tools and interfaces to manage virtual machines

## How QEMU and KVM Work Together
The typical architecture looks like this:
`Guest OS → KVM (kernel module) → QEMU (user space) → Host OS Hardware`
- KVM handles the CPU and memory virtualization (via kernel modules)
- QEMU handles the emulation of all other hardware components

## Features of QEMU in KVM

### Device Emulation:
- Emulates standard PC hardware (PIIX3/4 IDE, PS/2 mouse/keyboard, etc.)
- Can emulate various network cards, sound cards, and other peripherals

### Dynamic Translation:
- Translates guest CPU instructions to host instructions
- When used with KVM, most instructions run natively on hardware

## To create a KVM virtual machine using QEMU:
```bash
qemu-system-x86_64 -enable-kvm -m 2048 -hda /path/to/disk.img -cdrom /path/to/iso.iso
```
> **Note:**  
> In modern Linux distributions, you'll typically interact with QEMU through higher-level tools like libvirt and virt-manager rather than directly with QEMU commands.

## Conclusion
- Kvm is the hypervisor
- Qemu is the command line interface for managing the vms
- Libvirt is the graphical user interface for managing the vms
- All of them are collection of software you should make sure they are installed in ur host

<hr/>

# Manage Guest VMs

List all running VMs:
```bash
virsh list:
```
List all VMs:
```bash
virsh list --all
```
Start the VM:
```bash
virsh start <VM-id or Name>
```
Stop the VM:
```bash
virsh shutdown <VM-id or Name>
```
Reboot the VM:
```bash
virsh reboot <VM-id or Name>
```
Suspend VM:
```bash
virsh suspend <VM-id or Name>
```
Resume VM:
```bash
virsh resume <VM-id or Name>
```
Destroy VM:
```bash
virsh shutdown <VM-id or Name>
virsh undefine <VM-id or Name>
virsh destroy <VM-id or Name>
```
Enter guest's console:
```bash
virsh console <VM-id or Name>
```
Exit guest's console:
```bash
Ctrl + Alt
```
To enable  autostart of the VM with the host:
```bash
virsh autostart <VM-id or Name>
```
To disable autostart of the VM with the host:
```bash
virsh autostart --disable <VM-id or Name>
```
To get the more info about specific VM (configuration of the vm):
```bash
virsh dominfo <VM-id or Name>
```
To show the uuid for the VM:
```bash
virsh domuid <VM-id or Name>
```
## Configuration of the VM using virt-manager
![image](https://github.com/user-attachments/assets/17ff08a4-d2cc-4ae0-9fcc-c07873def83e)



> **Note:**
> - Qemu stands for quick emulator
> - Qcow2 stands for qemu copy-on-write 
> - And this file represent the disk image var/lib/libvirt/images/target_vm.qcow2, it contains the entire vm' disk (OS, apps, files)


# Clone VM 

From virt-manager click on the vm and it shutoff Or from command line
```bash
Virsh shutdown vm
Virt-clone –original source-vm  --name  target-vm  -f  /var/lib/libvirt/images/target_vm.qcow2
```




