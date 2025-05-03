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

















