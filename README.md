# OpenShift Installer With Libvirt

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
* Fedora 29(https://github.com/cloudbehl/installer/issues/3#issue-417796475) 
* 16GB Ram
* 8Vcpu's
* 100GB HardDisk(make sure ROOT(/) has minimum 50GB available.)


## Installing packages in system and Creating a cluster

### Using Fedora 29 VM
If you are using a clean fedora 29 VM. Then you can run Below script to setup everything for you and questions mentioned  https://github.com/cloudbehl/installer#create-an-openshift-cluster

```
$ wget https://raw.githubusercontent.com/cloudbehl/installer/installer-0.9/scripts/extra/setup.sh
$ chmod +x setup.sh
$ ./setup.sh
```

OR


### Install git

`$ yum install git -y`

### Setting up GO and GOPATH(if GO is not present)

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
$ export TF_VAR_libvirt_master_memory=4096 TF_VAR_libvirt_master_vcpu=4
$ bin/openshift-install create cluster
```

```
NOTE:
You could add ‘--log-level debug’ for a bit more information on progress.
You could use ‘--dir <dir>’ to save the config and logs to a specific dir.
```
```
? Platform libvirt

? Libvirt Connection URI qemu+tcp://192.168.122.1/system

? Base Domain tt.testing

? Cluster Name test1

? Pull Secret [? for help] `'{"auths":{"cloud.openshift.com"}}` # This is demo Pull Secret. please copy your pull from https://try.openshift.com/ and paste it
```

Example output:

```sh
INFO Waiting 20m0s for the openshift-console route to be created...
INFO Install complete!
INFO Run 'export KUBECONFIG=/path/to/auth/kubeconfig' to manage the cluster with 'oc', the OpenShift CLI.
INFO The cluster is ready when 'oc login -u kubeadmin -p 5char-5char-5char-5char' succeeds (wait a few minutes).
INFO Access the OpenShift web-console here: https://console-openshift-console.apps.${CLUSTER_NAME}.${BASE_DOMAIN}:6443
INFO Login to the console with user: kubeadmin, password: 5char-5char-5char-5char
```

### Clean Setup
`
./$HOME/go/src/github.com/openshift//scripts/extra/cleanup.sh
`
