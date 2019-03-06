#!/bin/sh

cd $GOPATH/src/github.com/openshift/installer/
TAGS=libvirt hack/build.sh
mkdir -p cluster
bin/openshift-install --log-level=debug --dir=cluster create cluster
