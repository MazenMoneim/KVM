#!/bin/bash

# KVM Installation and Configuration Script for CentOS 7


# Important Notes:

# Run as root: This script must be executed with root privileges.

# Storage Pool Warning: The storage pool creation assumes /dev/sdb is available. Modify this if you want to use a different disk.

# Network Configuration: The script automatically detects your main network interface and its IP configuration, but you should verify this.

# Manual Steps: Some steps like editing the default network with virsh net-edit default are not automated as they might require custom configuration.

# Reboot: The script will prompt for a reboot at the end, which is recommended.

# Backups: The script creates backups of important configuration files before modifying them.




# Function to check CPU virtualization support
check_cpu_virtualization() {
    echo "Checking CPU virtualization support..."
    if grep -E --color=auto 'vmx|svm|0xc0f' /proc/cpuinfo; then
        echo "CPU virtualization support detected."
    else
        echo "ERROR: No CPU virtualization support detected."
        echo "Please enable Intel VT-x/AMD-V in BIOS and VM settings."
        exit 1
    fi
}

# Function to configure CentOS repositories
configure_repos() {
    echo "Configuring CentOS repositories..."
    sudo cp /etc/yum.repos.d/CentOS-Base.repo /etc/yum.repos.d/CentOS-Base.repo.bak
    sudo sed -i 's/^mirrorlist=/#mirrorlist=/g' /etc/yum.repos.d/CentOS-Base.repo
    sudo sed -i 's/^#baseurl=/baseurl=/g' /etc/yum.repos.d/CentOS-Base.repo
    sudo sed -i 's|^baseurl=.*|baseurl=http://vault.centos.org/7.9.2009/os/$basearch/|g' /etc/yum.repos.d/CentOS-Base.repo
    
    echo "Cleaning and rebuilding yum cache..."
    sudo yum clean all
    sudo yum makecache
    sudo yum update -y
}

# Function to install required packages
install_packages() {
    echo "Installing KVM and virtualization packages..."
    sudo yum install -y virt-install qemu-kvm libvirt libvirt-python libguestfs-tools virt-manager
}

# Function to enable and start libvirtd
enable_libvirtd() {
    echo "Enabling and starting libvirtd service..."
    sudo systemctl enable --now libvirtd
}

# Function to check KVM kernel modules
check_kvm_modules() {
    echo "Checking KVM kernel modules..."
    modinfo kvm_intel || echo "kvm_intel module not loaded"
    modinfo kvm || echo "kvm module not loaded"
}

# Function to configure network
configure_network() {
    echo "Configuring network bridge..."
    
    # Get active network interface
    INTERFACE=$(ip route | grep default | awk '{print $5}')
    if [ -z "$INTERFACE" ]; then
        echo "Could not determine default network interface"
        exit 1
    fi
    
    # Get current IP info
    IPADDR=$(ip -o -4 addr show $INTERFACE | awk '{print $4}' | cut -d'/' -f1)
    GATEWAY=$(ip route | grep default | awk '{print $3}')
    NETMASK="255.255.255.0"
    
    if [ -z "$IPADDR" ] || [ -z "$GATEWAY" ]; then
        echo "Could not determine IP address or gateway"
        exit 1
    fi
    
    # Backup existing config
    sudo cp /etc/sysconfig/network-scripts/ifcfg-$INTERFACE /etc/sysconfig/network-scripts/ifcfg-$INTERFACE.bak
    
    # Create bridge config
    sudo bash -c "cat > /etc/sysconfig/network-scripts/ifcfg-$INTERFACE" <<EOF
TYPE=Ethernet
BOOTPROTO=none
NAME=$INTERFACE
DEVICE=$INTERFACE
ONBOOT=yes
BRIDGE=virbr0
EOF
    
    # Create virbr0 config
    sudo bash -c "cat > /etc/sysconfig/network-scripts/ifcfg-virbr0" <<EOF
TYPE=BRIDGE
DEVICE=virbr0
BOOTPROTO=none
ONBOOT=yes
IPADDR=$IPADDR
NETMASK=$NETMASK
GATEWAY=$GATEWAY
EOF
    
    echo "Network bridge configuration complete."
}

# Function to enable IP forwarding
enable_ip_forwarding() {
    echo "Enabling IP forwarding..."
    sudo bash -c "echo 'net.ipv4.ip_forward = 1' > /usr/lib/sysctl.d/60-libvirtd.conf"
    sudo /sbin/sysctl -p /usr/lib/sysctl.d/60-libvirtd.conf
}

# Function to configure firewall
configure_firewall() {
    echo "Configuring firewall..."
    sudo firewall-cmd --permanent --direct --passthrough ipv4 -I FORWARD -i virbr0 -j ACCEPT
    sudo firewall-cmd --permanent --direct --passthrough ipv4 -I FORWARD -o virbr0 -j ACCEPT
    sudo firewall-cmd --reload
}

# Function to list and configure virtual networks
configure_virtual_networks() {
    echo "Listing virtual networks..."
    virsh net-list
    
    echo "You can manually edit the default network with:"
    echo "  virsh net-edit default"
}

# Function to create storage pool (requires manual disk specification)
create_storage_pool() {
    echo "WARNING: This function assumes /dev/sdb is available for LVM"
    echo "Please modify the script if you want to use a different disk"
    
    read -p "Do you want to create storage pool on /dev/sdb? (y/n) " choice
    case "$choice" in
        y|Y )
            echo "Creating storage pool..."
            sudo vgcreate lab-kvm-storage /dev/sdb
            sudo lvcreate -l +100%FREE -n lab-kvm-lv lab-kvm-storage
            sudo mkfs.xfs /dev/mapper/lab--kvm--storage-lab--kvm--lv
            
            echo "Adding entry to /etc/fstab..."
            sudo mkdir -p /var/lib/libvirt/images
            sudo bash -c "echo '/dev/mapper/lab--kvm--storage-lab--kvm--lv   /var/lib/libvirt/images    xfs    defaults 0  0' >> /etc/fstab"
            sudo mount -a
            
            echo "Defining storage pool..."
            sudo virsh pool-define-as lab-kvm-storagepool --type dir --target /var/lib/libvirt/images
            sudo virsh pool-autostart lab-kvm-storagepool
            sudo virsh pool-start lab-kvm-storagepool
            
            echo "Storage pool created:"
            virsh pool-list --all --details
            ;;
        * )
            echo "Skipping storage pool creation."
            ;;
    esac
}

# Function to check supported guest OS
check_supported_os() {
    echo "Checking supported guest OS..."
    osinfo-query os || echo "osinfo-query not available"
}

# Main execution
main() {
    # Check if running as root
    if [ "$(id -u)" -ne 0 ]; then
        echo "This script must be run as root"
        exit 1
    fi
    
    check_cpu_virtualization
    configure_repos
    install_packages
    enable_libvirtd
    check_kvm_modules
    configure_network
    enable_ip_forwarding
    configure_firewall
    configure_virtual_networks
    create_storage_pool
    check_supported_os
    
    echo ""
    echo "KVM installation and configuration complete."
    echo "You should reboot the system now."
    read -p "Reboot now? (y/n) " choice
    case "$choice" in
        y|Y ) systemctl reboot ;;
        * ) echo "Please reboot when convenient." ;;
    esac
}

# Execute main function
main