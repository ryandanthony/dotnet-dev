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

# exe.dev default proxy ports
EXPOSE 8000 9999

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
    && rm -rf /var/lib/apt/lists/*

# =============================================================================
# Create user for exe.dev (UID 1000 required)
# =============================================================================
# Ubuntu 24.04 has a default 'ubuntu' user with UID 1000, remove it first
RUN userdel -r ubuntu 2>/dev/null || true \
    && useradd -m -s /bin/bash -u 1000 -c "Development user" devuser \
    && echo "devuser ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

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

# =============================================================================
# exe.dev requires container to run as root (it manages SSH internally)
# The exe.dev/login-user label determines which user SSH sessions use
# =============================================================================
USER root
WORKDIR /home/devuser
