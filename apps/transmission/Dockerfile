#-------------------------------------------------------------------------------
# Pull Base Image
#-------------------------------------------------------------------------------
FROM registry.access.redhat.com/ubi8:latest AS BUILDER

#-------------------------------------------------------------------------------
# Define build arguments
#-------------------------------------------------------------------------------
ARG BUILDROOT="/root/build"
ARG UTILS="transmission-create \
transmission-daemon transmission-edit \
transmission-remote transmission-show"

#-------------------------------------------------------------------------------
# Stage Builder Script.
#-------------------------------------------------------------------------------
COPY builder.sh /tmp/
RUN chmod 755 /tmp/builder.sh

#-------------------------------------------------------------------------------
# Install Builder Script Dependencies.
#-------------------------------------------------------------------------------
RUN dnf -y install \
/usr/*bin/mkdir /usr/*bin/readlink /usr/*bin/grep /usr/*bin/file /usr/*bin/realpath \
/usr/*bin/echo /usr/*bin/rsync /usr/*bin/ldd /usr/*bin/awk /usr/*bin/sort

#-------------------------------------------------------------------------------
# Enable EPEL Repository.
#-------------------------------------------------------------------------------
RUN dnf -y install \
https://dl.fedoraproject.org/pub/epel/epel-release-latest-8.noarch.rpm

#-------------------------------------------------------------------------------
# Install Transmission daemon
#-------------------------------------------------------------------------------
RUN dnf -y install transmission-daemon

#-------------------------------------------------------------------------------
# Pull dependencies from requested utilities.
#-------------------------------------------------------------------------------
RUN /tmp/builder.sh "${BUILDROOT}" "${UTILS}"

#-------------------------------------------------------------------------------
# Pull Base Image.
#-------------------------------------------------------------------------------
FROM registry.access.redhat.com/ubi8/ubi-micro:latest
ARG BUILDROOT="/root/build"

#-------------------------------------------------------------------------------
# Copy Artifacts to Base Image.
#-------------------------------------------------------------------------------
COPY --from=BUILDER ${BUILDROOT}/ /
COPY --from=BUILDER /usr/share/doc/transmission-common/ /usr/share/doc/transmission-common/
COPY --from=BUILDER /usr/share/transmission/ /usr/share/transmission/