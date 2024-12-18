#!/usr/bin/env bash

set -euox pipefail

dnf config-manager --set-enabled crb
dnf -y install https://dl.fedoraproject.org/pub/epel/epel-release-latest-10.noarch.rpm

dnf -y install @multimedia gstreamer1-plugins-{bad-*,good-*,base} lame*

dnf -y install @workstation

dnf -y install btrfs-progs
