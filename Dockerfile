# =============================================================================
# .NET Development Docker Image
# =============================================================================
# Base image: Ubuntu 24.04 LTS (Noble Numbat) - supported by .NET SDK 10
# This image is designed to support multiple .NET SDK versions
# Compatible with exe.dev SSH-based container access
# =============================================================================

FROM ubuntu:24.04

LABEL org.opencontainers.image.title="dotnet-dev"
LABEL org.opencontainers.image.description=".NET Development Environment"
LABEL org.opencontainers.image.source="https://github.com/ryandanthony/dotnet-dev"
LABEL org.opencontainers.image.vendor="ryandanthony"

# exe.dev configuration - tells exe.dev which user to use for SSH
LABEL exe.dev/login-user="devuser"
SHELL ["/bin/bash", "-euxo", "pipefail", "-c"]

# =============================================================================
# Install prerequisites and dependencies
# =============================================================================
RUN DEBIAN_FRONTEND=noninteractive apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates \
    curl \
    wget \
    gnupg \
    lsb-release \
    apt-transport-https \
    # Required dependencies for .NET
    libc6 \
    libgcc-s1 \
    libicu74 \
    libssl3 \
    libstdc++6 \
    zlib1g \
    # Useful development tools
    git \
    sudo \
    && apt-get clean && rm -rf /var/lib/apt/lists/*
# =============================================================================	

RUN usermod -l devuser ubuntu && \
	groupmod -n devuser ubuntu && \
	mv /home/ubuntu /home/devuser && \
	usermod -d /home/devuser devuser && \
	usermod -aG sudo devuser && \
	echo 'devuser ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers

RUN touch /home/devuser/.hushlogin

COPY home/.profile /home/devuser/.profile
COPY home/.bash_profile /home/devuser/.bash_profile
COPY home/.bashrc /home/devuser/.bashrc
COPY home/.bash_logout /home/devuser/.bash_logout

# Create empty .bashrc.local for user customizations
RUN touch /home/devuser/.bashrc.local

# Set proper ownership for all home directory contents
RUN chown -R devuser:devuser /home/devuser

# =============================================================================
# .NET SDK Installation
# =============================================================================
# Configure environment variables for .NET
ENV DOTNET_ROOT=/usr/share/dotnet
ENV PATH="${PATH}:${DOTNET_ROOT}:${DOTNET_ROOT}/tools"

# Disable telemetry
ENV DOTNET_CLI_TELEMETRY_OPTOUT=1
# Enable invariant globalization mode (optional, can be removed if full ICU is needed)
ENV DOTNET_SYSTEM_GLOBALIZATION_INVARIANT=false

# Create .NET directory
RUN mkdir -p ${DOTNET_ROOT}

# Download and install .NET SDK 10
# Using the official install script for flexibility in installing multiple versions
RUN curl -sSL https://dot.net/v1/dotnet-install.sh -o /tmp/dotnet-install.sh \
    && chmod +x /tmp/dotnet-install.sh \
    # Install .NET SDK 10 (latest)
    && /tmp/dotnet-install.sh --channel 10.0 --install-dir ${DOTNET_ROOT} \
    # Cleanup
    && rm /tmp/dotnet-install.sh

# =============================================================================
# Additional SDK versions can be installed here
# Example: Install .NET SDK 8 (LTS)
# RUN curl -sSL https://dot.net/v1/dotnet-install.sh -o /tmp/dotnet-install.sh \
#     && chmod +x /tmp/dotnet-install.sh \
#     && /tmp/dotnet-install.sh --channel 8.0 --install-dir ${DOTNET_ROOT} \
#     && rm /tmp/dotnet-install.sh
# =============================================================================

# Verify installation
RUN dotnet --list-sdks && dotnet --list-runtimes

ENTRYPOINT ["/usr/bin/tini", "--"]
USER devuser