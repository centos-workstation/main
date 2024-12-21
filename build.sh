#!/usr/bin/env bash

set -euox pipefail

# See https://github.com/centos-workstation/achillobator/issues/3
mkdir -m 0700 -p /var/roothome
# Fast track https://gitlab.com/fedora/bootc/base-images/-/merge_requests/71
ln -sf /run /var/run

dnf config-manager --set-enabled crb
dnf -y install https://dl.fedoraproject.org/pub/epel/epel-release-latest-10.noarch.rpm

dnf -y install @multimedia gstreamer1-plugins-{bad-free,bad-free-libs,good,base} lame{,-libs} libjxl plymouth plymouth-system-theme

dnf group install -y --nobest Workstation 

#update and cleanup
dnf upgrade -y
dnf remove -y $(dnf repoquery --installonly --latest-limit 1 -q)

systemctl enable gdm.service
