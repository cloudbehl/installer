#!/bin/sh

yum install git -y

yum install go -y
mkdir -p $HOME/go/src/github.com/openshift/
echo "export GOPATH=$HOME/go"
cd $HOME/go/src/github.com/openshift/

git clone https://github.com/cloudbehl/installer.git -b installer-0.9

cd installer/ && ./scripts/maintenance/install-deps.sh

TAGS=libvirt hack/build.sh

mkdir -p cluster
bin/openshift-install --log-level=debug --dir=cluster create cluster
