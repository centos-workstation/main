#!/usr/bin/env bash

set -euox pipefail

# See https://github.com/centos-workstation/achillobator/issues/3
mkdir -m 0700 -p /var/roothome
# Fast track https://gitlab.com/fedora/bootc/base-images/-/merge_requests/71
ln -sf /run /var/run

dnf config-manager --set-enabled crb

dnf -y install https://dl.fedoraproject.org/pub/epel/epel-release-latest-10.noarch.rpm
dnf -y install centos-release-hyperscale centos-release-hyperscale-experimental

for pkg in kernel kernel-core kernel-modules kernel-modules-core kernel-modules-extra ; do rpm --erase $pkg --nodeps ; done
dnf -y install kernel kernel-core kernel-modules{,-core,-extra}

dnf -y --allowerasing upgrade 

dnf -y install @multimedia gstreamer1-plugins-{bad-free,bad-free-libs,good,base} lame{,-libs} libjxl

dnf group install -y --nobest Workstation

# dnf remove -y $(dnf repoquery --installonly --latest-limit 1 -q)

systemctl enable gdm.service
