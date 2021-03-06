#!/bin/sh

set +x

prerequisites()
{
    # Check if virtualization is supported
    ls /dev/kvm 2> /dev/null
    if [ $? -ne 0 ]
    then
        echo "Your system doesn't support virtualization"
        exit 1
    fi

    # Install required dependecies
    sudo yum install -y libvirt libvirt-devel libvirt-daemon-kvm qemu-kvm

    # Enable IP forwarding
    sudo sysctl net.ipv4.ip_forward=1

    # Configure libvirt to accept TCP connections
    sudo sed -i.bak -e 's/^[#]*\s*listen_tls.*/listen_tls = 0/' -e 's/^[#]*\s*listen_tcp.*/listen_tcp = 1/' -e 's/^[#]*\s*auth_tcp.*/auth_tcp = "none"/' -e 's/^[#]*\s*tcp_port.*/tcp_port = "16509"/' /etc/libvirt/libvirtd.conf

    # Configure the service runner to pass --listen to libvirtd
    sudo sed -i.bak -e 's/^[#]*\s*LIBVIRTD_ARGS.*/LIBVIRTD_ARGS="--listen"/' /etc/sysconfig/libvirtd

    # Restart the libvirtd service
    sudo systemctl restart libvirtd

    # Get active Firewall zone option
    systemctl is-active firewalld
    if [ $? -ne 0 ]
    then
        echo "Your system doesn't have firewalld service running"
        exit 1
    fi

    activeZone=$(firewall-cmd --get-active-zones | head -n 1)
    sudo firewall-cmd --zone=$activeZone --add-source=192.168.126.0/24
    sudo firewall-cmd --zone=$activeZone --add-port=16509/tcp

    # Configure default libvirt storage pool
    sudo virsh --connect qemu:///system pool-list | grep -q 'default'
    if [ $? -ne 0 ]
    then
        sudo virsh pool-define /dev/stdin <<EOF
<pool type='dir'>
  <name>default</name>
  <target>
    <path>/var/lib/libvirt/images</path>
  </target>
</pool>
EOF
    sudo virsh pool-start default
    sudo virsh pool-autostart default
    fi

    # Set up NetworkManager DNS overlay
    grep -q 'dns=dnsmasq' /etc/NetworkManager/NetworkManager.conf
    if [ $? -ne 0 ]
    then
        sudo sed -i.bak '/\[main\]/a dns=dnsmasq' /etc/NetworkManager/NetworkManager.conf
        echo server=/tt.testing/192.168.126.1 | sudo tee /etc/NetworkManager/dnsmasq.d/openshift.conf
        sudo systemctl restart NetworkManager
    fi

    # Create an entry in the /etc/host
    grep -q 'libvirt.default' /etc/hosts
    if [ $? -ne 0 ]
    then
        echo '192.168.126.1   libvirt.default' | sudo tee --append /etc/hosts
    fi
}
main()
{
	prerequisites;
}

main "$@"; exit
