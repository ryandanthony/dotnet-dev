# Base image: Ubuntu 24.0424.04
FROM ubuntu:24.04

# Build arguments
ARG RELEASE
ARG LAUNCHPAD_BUILD_ARCH

# Set shell for all RUN commands
SHELL ["/bin/bash", "-euxo", "pipefail", "-c"]

# Install base system packages
RUN sed -i 's|http://archive.ubuntu.com/ubuntu/|http://mirror://mirrors.ubuntu.com/mirrors.txt|' /etc/apt/sources.list && \
    apt-get update && \
    echo 'debconf debconf/frontend select Noninteractive' | debconf-set-selections && \
    echo 'pbuilder pbuilder/mirrorsite string http://archive.ubuntu.com/ubuntu' | debconf-set-selections && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y \
      # System Services
      systemd systemd-sysv dbus-user-session \
      # Ubuntu Metapackages
      ubuntu-server ubuntu-standard \
      # Monitoring & Diagnostics
      lsof atop btop iotop ncdu \
      # Core System Utilities
      ca-certificates curl wget unzip file less tree \
      util-linux bsdmainutils psmisc sudo libcap2-bin rsync \
      # Networking
      openssh-server openssh-client \
      iproute2 net-tools iputils-ping \
      socat netcat-openbsd mitmproxy \
      # Containers
      docker.io docker-buildx docker-compose-v2 \
      && \
    apt-get remove -y pollinate ubuntu-fan && \
    setcap cap_net_raw=+ep /usr/bin/ping && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Disable and mask unnecessary systemd services to optimize for container environment
RUN rm /etc/systemd/system/multi-user.target.wants/console-setup.service \
      /etc/systemd/system/multi-user.target.wants/ModemManager.service \
      /etc/systemd/system/multi-user.target.wants/snapd.* \
      /etc/systemd/system/multi-user.target.wants/unattended-upgrades.* \
      /etc/systemd/system/multi-user.target.wants/ubuntu-advantage.service && \
    systemctl mask -- \
      getty.target \
      systemd-random-seed.service \
      iscsid.socket \
      dm-event.socket \
      man-db.timer \
      update-notifier-download.timer \
      update-notifier-motd.timer \
      atop-rotate.timer \
      dpkg-db-backup.timer \
      e2scrub_all.timer \
      etc-resolv.conf.mount \
      etc-hosts.mount \
      etc-hostname.mount \
      -.mount \
      systemd-resolved.service \
      systemd-remount-fs.service \
      systemd-sysusers.service \
      systemd-update-done.service \
      systemd-update-utmp.service \
      systemd-journal-catalog-update.service \
      modprobe@.service \
      systemd-modules-load.service \
      systemd-journal-flush.service \
      systemd-udevd.service \
      systemd-udevd-control.service \
      systemd-udevd-kernel.service \
      systemd-udev-trigger.service \
      systemd-udev-settle.service \
      systemd-hwdb-update.service \
      ubuntu-fan.service \
      ldconfig.service \
      unattended-upgrades.service \
      lxd-installer.socket \
      console-getty.service \
      keyboard-setup.service \
      systemd-ask-password-console.path \
      systemd-ask-password-wall.path \
      ssh.socket \
      plymouth.service \
      plymouth-start.service \
      plymouth-quit.service \
      plymouth-quit-wait.service \
      plymouth-read-write.service \
      plymouth-switch-root.service \
      plymouth-switch-root-initramfs.service \
      plymouth-halt.service \
      plymouth-reboot.service \
      plymouth-poweroff.service \
      plymouth-kexec.service \
      apt-daily-upgrade.timer \
      apt-daily.timer \
      plymouth-log.service && \
    systemctl disable \
      docker.service containerd.service getty.target systemd-logind.service \
      console-getty.service \
      atop.service \
      getty@.service \
      snapd.socket \
      motd-news.timer motd-news.service \
      apport.service apport-autoreport.timer apport-autoreport.path apport-forward.socket \
      snapd.snap-repair.timer snapd.snap-repair.service \
      udisks2.service \
      ufw.service \
      lvm2-lvmpolld.socket \
      systemd-ask-password-wall.service \
      systemd-ask-password-console.service \
      systemd-machine-id-commit.service \
      systemd-modules-load.service \
      systemd-sysctl.service \
      systemd-firstboot.service \
      systemd-udevd.service \
      systemd-udev-trigger.service \
      systemd-udev-settle.service \
      e2scrub_reap.service \
      systemd-update-utmp.service \
      atopacct.service \
      sysstat.service \
      systemd-hwdb-update.service \
      multipathd.service && \
    mkdir -p /etc/systemd/system.conf.d && \
    echo '[Manager]' > /etc/systemd/system.conf.d/container-overrides.conf && \
    echo 'LogLevel=info' >> /etc/systemd/system.conf.d/container-overrides.conf && \
    echo 'LogTarget=console' >> /etc/systemd/system.conf.d/container-overrides.conf && \
    echo 'SystemCallArchitectures=native' >> /etc/systemd/system.conf.d/container-overrides.conf && \
    systemctl set-default multi-user.target

# Set up devuser user (renamed from ubuntu default user)
RUN usermod -l devuser -c "dev user" ubuntu && \
    groupmod -n devuser ubuntu && \
    mv /home/ubuntu /home/devuser && \
    usermod -d /home/devuser devuser && \
    usermod -aG sudo devuser && \
    usermod -aG docker devuser && \
    sed -i 's/^ubuntu:/devuser:/' /etc/subuid /etc/subgid && \
    echo 'devuser ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers && \
    mkdir -p /var/lib/systemd/linger && \
    touch /var/lib/systemd/linger/devuser

# Set environment variable to identify this as an exeuntu image
ENV EXEUNTU=1

# Create necessary directories for devuser user
RUN mkdir -p /home/devuser /home/devuser/.config && \
    chown devuser:devuser /home/devuser /home/devuser/.config

# Copy base configuration files for devuser user
COPY --chown=devuser:devuser home/ /home/devuser/

# Install development tools
RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y \
      # Build Tools
      build-essential make \
      # Version Control & GitHub
      git gh \
      # Media Processing
      imagemagick ffmpeg \
      # Search & Text Processing
      ripgrep jq \
      # Editors
      vim neovim \
      && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Switch to devuser user
USER devuser

# Set working directory
WORKDIR /home/devuser

# Configure bash environment for devuser user
RUN echo 'export PATH="$HOME/.local/bin:$PATH"' >> /home/devuser/.bashrc && \
    echo 'export XDG_RUNTIME_DIR="/run/user/$(id -u)"' >> /home/devuser/.bashrc && \
    echo 'export XDG_RUNTIME_DIR="/run/user/$(id -u)"' >> /home/devuser/.profile

# Configure git defaults
RUN git config --global init.defaultBranch main

# Switch back to root for remaining setup
USER root

# Disable MOTD (message of the day) default messages
RUN rm -rf /etc/update-motd.d/* /etc/motd

# Copy init wrapper script
COPY init-wrapper.sh /usr/local/bin/init

# Expose ports
# 8000: Default web server port
EXPOSE 8000/tcp

# Label for login user
LABEL login-user="devuser"

# Set command to run init wrapper
CMD ["/usr/local/bin/init"]