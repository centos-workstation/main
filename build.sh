#!/usr/bin/env bash

set -euox pipefail

# See https://github.com/centos-workstation/achillobator/issues/3
mkdir -m 0700 -p /var/roothome
# Fast track https://gitlab.com/fedora/bootc/base-images/-/merge_requests/71
ln -sf /run /var/run

dnf config-manager --set-enabled crb
dnf -y install https://dl.fedoraproject.org/pub/epel/epel-release-latest-10.noarch.rpm

dnf -y install centos-release-hyperscale centos-release-hyperscale-experimental
dnf -y upgrade systemd
dnf -y --allowerasing upgrade 

dnf -y install @multimedia gstreamer1-plugins-{bad-free,bad-free-libs,good,base} lame{,-libs} libjxl plymouth plymouth-system-theme

# `dnf group info Workstation` without GNOME
dnf group install -y --nobest \
  -x rsyslog* \
  -x cockpit \
  -x PackageKit \
  -x PackageKit-command-not-found \
   "Common NetworkManager submodules" \
   "Core" \
   "Fonts" \
   "Guest Desktop Agents" \
   "Hardware Support" \
   "Printing Client" \
   "Standard" \
   "Workstation product core"

# Minimal GNOME group. ("Multimedia" adds most of the packages from the GNOME group. This should clear those up too.)
# In order to reproduce this, get the packages with `dnf group info GNOME`, install them manually with dnf install and see all the packages that are already installed.
# Other than that, I've removed a few packages we didnt want, those being a few GUI applications.
dnf -y install \
  -x PackageKit \
  -x PackageKit-command-not-found \
  -x gnome-software-fedora-langpacks \
   "NetworkManager-adsl" \
   "centos-backgrounds" \
   "gdm" \
   "gnome-bluetooth" \
   "gnome-color-manager" \
   "gnome-control-center" \
   "gnome-initial-setup" \
   "gnome-remote-desktop" \
   "gnome-session-wayland-session" \
   "gnome-settings-daemon" \
   "gnome-shell" \
   "gnome-software" \
   "gnome-user-docs" \
   "gvfs-fuse" \
   "gvfs-goa" \
   "gvfs-gphoto2" \
   "gvfs-mtp" \
   "gvfs-smb" \
   "libsane-hpaio" \
   "nautilus" \
   "orca" \
   "ptyxis" \
   "sane-backends-drivers-scanners" \
   "xdg-desktop-portal-gnome" \
   "xdg-user-dirs-gtk" \
   "yelp-tools"

# This adds "[systemd] Failed Units: *" to the bashrc startup
dnf -y remove console-login-helper-messages

# This seems weirdly like a Schrödinger's issue. Removing the kernel here fails some builds and not removing it actually-
# breaks some stuff? I dont know exactly what to do here.
# FIXME: Figure out if this is necessary
# dnf remove -y $(dnf repoquery --installonly --latest-limit 1 -q)

systemctl enable gdm.service
