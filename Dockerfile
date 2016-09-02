# =============================================================================
# 
# CentOS-7.2.1511 - base
# 
# =============================================================================
FROM centos:7.2.1511

MAINTAINER John Headley <keoni84@gmail.com>

ENV container docker
RUN (cd /lib/systemd/system/sysinit.target.wants/; for i in *; do [ $i == systemd-tmpfiles-setup.service ] || rm -f $i; done) \
	&& rm -f /lib/systemd/system/multi-user.target.wants/* \
	&& rm -f /etc/systemd/system/*.wants/* \
	&& rm -f /lib/systemd/system/local-fs.target.wants/* \
	&& rm -f /lib/systemd/system/sockets.target.wants/*udev* \
	&& rm -f /lib/systemd/system/sockets.target.wants/*initctl* \
	&& rm -f /lib/systemd/system/basic.target.wants/* \
	&& rm -f /lib/systemd/system/anaconda.target.wants/*

# -----------------------------------------------------------------------------
# Import the RPM GPG keys for Centos Mirrors
# -----------------------------------------------------------------------------
RUN rpm --import http://mirror.centos.org/centos/RPM-GPG-KEY-CentOS-7

# -----------------------------------------------------------------------------
# Base Install
# -----------------------------------------------------------------------------
RUN rpm --rebuilddb \
	&& yum -y install \
	vim-enhanced \
	sudo \
	ntp \
	openssh \
	openssh-server \
	openssh-clients \
	lsof \
	iproute \
	cronie \
	gcc \
	glibc \
	glibc-common \
	gd \
	gd-devel \
	net-snmp \
	openssl-devel \
	perl-IO-Socket-SSL \
	perl-devel \
	perl-JSON \
	perl-HTML \
	perl-XML-Simple \
	wget \
	unzip \
	make \
	python-setuptools \
	python-setuptools-devel \
	&& rm -rf /var/cache/yum/* \
	&& yum clean all

# -----------------------------------------------------------------------------
# Copy files into place
# -----------------------------------------------------------------------------
ADD epel-release-7-8.noarch.rpm /tmp/

# -----------------------------------------------------------------------------
# Import epel Repository
# -----------------------------------------------------------------------------
RUN rpm -ivh /tmp/epel-release-7-8.noarch.rpm

# -----------------------------------------------------------------------------
# Install sshpass
# -----------------------------------------------------------------------------
RUN rpm --rebuilddb \
	&& yum -y install sshpass perl-Nagios-Plugin \
	&& yum -y erase epel-release-7-8 \
	&& rm -rf /var/cache/yum/* \
	&& rm -rf /tmp/epel-release-7-8.noarch.rpm \
	&& yum clean all

# -----------------------------------------------------------------------------
# Set timezone to UTC
# -----------------------------------------------------------------------------
RUN ln -sf /usr/share/zoneinfo/UTC /etc/localtime

# -----------------------------------------------------------------------------
# Configure SSH UseDNS
# -----------------------------------------------------------------------------
RUN sed -i \
	-e 's~^#UseDNS yes~UseDNS no~g' \
	/etc/ssh/sshd_config

# -----------------------------------------------------------------------------
# Expose port 22
# -----------------------------------------------------------------------------
EXPOSE 22

# -----------------------------------------------------------------------------
# Expose volumes
# -----------------------------------------------------------------------------
VOLUME [ "/sys/fs/cgroup" ]

# -----------------------------------------------------------------------------
# Command to init
# -----------------------------------------------------------------------------
CMD ["/usr/sbin/init"]