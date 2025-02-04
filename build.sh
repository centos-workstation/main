#!/usr/bin/env bash

set -euox pipefail

# See https://github.com/centos-workstation/achillobator/issues/3
mkdir -m 0700 -p /var/roothome
# Fast track https://gitlab.com/fedora/bootc/base-images/-/merge_requests/71
ln -sf /run /var/run

# Enable the same compose repos during our build that the centos-bootc image
# uses during its build.  This avoids downgrading packages in the image that
# have strict NVR requirements.
curl --retry 3 -Lo /etc/yum.repos.d/compose.repo https://gitlab.com/redhat/centos-stream/containers/bootc/-/raw/c10s/cs.repo
sed -r \
    -e 's@\[rhel-10-for-\$basearch-@[@' \
    -e 's@-rpms\]@-compose]@' \
    -e 's@- (BaseOS|AppStream)@& - Compose@' \
    -e 's@/usr/share/distribution-gpg-keys/centos/RPM-GPG-KEY-CentOS-Official@/etc/pki/rpm-gpg/RPM-GPG-KEY-centosofficial-SHA256@' \
    -i /etc/yum.repos.d/compose.repo

# RPMS from Ublue-os config
dnf -y install /tmp/rpms/ublue-os-{udev-rules,luks}.noarch.rpm

dnf config-manager --set-enabled crb
dnf -y install https://dl.fedoraproject.org/pub/epel/epel-release-latest-10.noarch.rpm

dnf -y install @multimedia gstreamer1-plugins-{bad-free,bad-free-libs,good,base} lame{,-libs} libjxl plymouth plymouth-system-theme fwupd

# `dnf group info Workstation` without GNOME
dnf group install -y --nobest \
  -x rsyslog* \
  -x cockpit \
  -x cronie* \
  -x crontabs \
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
   "gnome-calculator" \
   "gnome-color-manager" \
   "gnome-control-center" \
   "gnome-disk-utility" \
   "gnome-initial-setup" \
   "gnome-remote-desktop" \
   "gnome-session-wayland-session" \
   "gnome-settings-daemon" \
   "gnome-shell" \
   "gnome-software" \
   "gnome-system-monitor" \
   "gnome-text-editor" \
   "gnome-tweaks" \
   "gnome-user-docs" \
   "gvfs-fuse" \
   "gvfs-goa" \
   "gvfs-gphoto2" \
   "gvfs-mtp" \
   "gvfs-smb" \
   "libsane-hpaio" \
   "loupe" \
   "nautilus" \
   "orca" \
   "ptyxis" \
   "sane-backends-drivers-scanners" \
   "xdg-desktop-portal-gnome" \
   "xdg-user-dirs-gtk" \
   "yelp-tools"

# Some RPMs to match uBlue Silverblue Main.
dnf -y install \
   "distrobox" \
   "google-noto-sans-balinese-fonts" \
   "google-noto-sans-cjk-fonts" \
   "google-noto-sans-javanese-fonts" \
   "google-noto-sans-sundanese-fonts" \
   "ffmpeg-free" \
   "fuse" \
   "htop" \
   "openssl" \
   "nvtop" \
   "vim"

# This adds "[systemd] Failed Units: *" to the bashrc startup
dnf -y remove console-login-helper-messages

systemctl enable gdm.service
systemctl enable fwupd.service

# The compose repos we used during the build are point in time repos that are
# not updated, so we don't want to leave them enabled.
dnf config-manager --set-disabled baseos-compose,appstream-compose

# enable systemd-resolved for proper name resolution
systemctl enable systemd-resolved.service
