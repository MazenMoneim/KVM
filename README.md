<h1 align="center">Kernel-based Virtual Machine</h1>  
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
- **Live and Offline Migration**: Supports both live and offline VM migration, this feature helps when any maintenance is planned on the KVM host
- **Resource `Overcommitment`**: Enables allocation of more virtual resources than physically available

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
Check cpu info if it supports the vmx or svm for virtualization

```bash
grep -E --color=auto 'vmx|svm|0xc0f' /proc/cpuinfo
```

If there is no output, check the virtualize Intel VT option in processor, VM setting  

![image](https://github.com/user-attachments/assets/38cbfa86-72f0-45cf-99d0-add0b33c9f25)

Configure repos in Centos
```bash
sudo vi /etc/yum.repos.d/CentOS-Base.repo
```
Edit the baseurl and hash the mirror
```bash
baseurl=http://vault.centos.org/7.9.2009/os/$basearch/
#mirrorlist=http://mirrorlist.centos.org/?release=7&arch=$basearch&repo=os&infra=stock
```
After editing use this commands
```bash
sudo yum clean all
sudo yum makecache
sudo yum update
```
Install these packages
```bash
yum install virt-install qemu-kvm libvirt libvirt-python libquestfs-tools virt-manager -y
```
Enable the libvirtd daemon
```bash
systemctl enable --now libvirtd
```
Reboot the kvm-host
```bash
systemctl reboot
```
Ensure the kernel modules for kvm are loaded
```bash
modinfo kvm_intel
modinfo kvm
```












