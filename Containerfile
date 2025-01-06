ARG MAJOR_VERSION="${MAJOR_VERSION:-stream10}"

FROM ghcr.io/ublue-os/config:latest@sha256:72c994ea9c6cccf726378afc84ca51598f6dfa93d545e5b7dafc42ce3c04ede9 AS config
FROM quay.io/centos-bootc/centos-bootc:$MAJOR_VERSION


#Install codecs, Workstation, EPEL, CRB, etc.
COPY build.sh /tmp/build.sh
RUN --mount=type=bind,from=config,src=/rpms,dst=/tmp/rpms chmod +x /tmp/build.sh && \
    /tmp/build.sh && \
    dnf clean all && \
    ostree container commit && \
    bootc container lint
