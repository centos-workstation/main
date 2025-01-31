ARG MAJOR_VERSION="${MAJOR_VERSION:-stream10}"

FROM ghcr.io/ublue-os/config:latest@sha256:f136ef45a6fb050d6abeb1541e6e0e00ac5962c2ed78b3aeda20030d85c8ce10 AS config
FROM quay.io/centos-bootc/centos-bootc:$MAJOR_VERSION


#Install codecs, Workstation, EPEL, CRB, etc.
COPY build.sh /tmp/build.sh
RUN --mount=type=bind,from=config,src=/rpms,dst=/tmp/rpms chmod +x /tmp/build.sh && \
    /tmp/build.sh && \
    dnf clean all && \
    ostree container commit && \
    bootc container lint
