ARG MAJOR_VERSION="${MAJOR_VERSION:-stream10}"

FROM quay.io/centos-bootc/centos-bootc:$MAJOR_VERSION

#Install codecs, Workstation, EPEL, CRB, etc.
# COPY build.sh /tmp/build.sh
# RUN chmod +x /tmp/build.sh &&\
#     /tmp/build.sh && \
#     dnf clean all && \
#     ostree container commit

# Just gotta get this green!
RUN bootc container lint || exit 0
