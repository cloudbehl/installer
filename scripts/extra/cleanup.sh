#!/bin/sh

cd $GOPATH/src/github.com/openshift/installer/
bin/openshift-install destroy cluster --dir=cluster
scripts/maintenance/virsh-cleanup.sh
rm -rf cluster/
rm -rf ~/.cache/openshift-install/
