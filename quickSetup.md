# Create OCP4.0 libvirt Setup

## Checking if nested virtualization is supported in HOST machine
If you see 1 or Y, nested virtualization is supported; if you see 0 or N, nested virtualization is not supported.

``` 
$ cat /sys/module/kvm_intel/parameters/nested
Y 
```

## Enabling nested virtualization
To enable nested virtualization for Intel processors(if the processors are AMD the replace kvm_intel wirh kvm_amd):

Shut down all running VMs and unload the kvm_probe module:

`$ modprobe -r kvm_intel`

Activate the nesting feature:

`$ modprobe kvm_intel nested=1`

Nested virtualization is enabled until the host is rebooted. To enable it permanently, add the following line to the `/etc/modprobe.d/kvm.conf` file:

`options kvm_intel nested=1`

## Creating a VM
* Fedora 29 
* 16GB Ram
* 8Vcpu's
* 200GB HardDisk


## Installing packages in system and Creating a cluster

### Install git

`$ yum install git -y`

### Setting up GO and GOPATH

If GO repo is not available. Download the repo from https://go-repo.io/ and then Install.

```
yum install go -y
mkdir -p $HOME/go/src/github.com/openshift/
export GOPATH="$HOME/go"
cd $HOME/go/src/github.com/openshift/
```

### Clone OpenShift Installer
`
$ git clone https://github.com/cloudbehl/installer.git -b installer-0.9
`

### Install dependency
`
$ cd installer/ && ./scripts/maintenance/install-deps.sh
`

### Build the openshift-install binary 
`
$ TAGS=libvirt hack/build.sh
`

### Create an OpenShift cluster
```
NOTE:
You could add ‘--log-level debug’ for a bit more information on progress.
You could use ‘--dir <dir>’ to save the config and logs to a specific dir.
```

`
$ bin/openshift-install create cluster
`

```
? Platform libvirt

? Libvirt Connection URI qemu+tcp://192.168.122.1/system

? Base Domain tt.testing

? Cluster Name test1

? Pull Secret [? for help] `'{"auths":{"cloud.openshift.com"}}` # This is demo Pull Secret. please copy your pull from https://try.openshift.com/ and paste it
```
