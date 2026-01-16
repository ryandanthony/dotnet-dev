# =============================================================================
# .NET Development Docker Image
# =============================================================================
# Base image: Ubuntu 24.04 LTS (Noble Numbat) - supported by .NET SDK 10
# This image is designed to support multiple .NET SDK versions
# =============================================================================

FROM ubuntu:24.04

LABEL org.opencontainers.image.title="dotnet-dev"
LABEL org.opencontainers.image.description=".NET Development Environment"
LABEL org.opencontainers.image.source="https://github.com/ryandanthony/dotnet-dev"
LABEL org.opencontainers.image.vendor="ryandanthony"

# Prevent interactive prompts during package installation
ENV DEBIAN_FRONTEND=noninteractive

# =============================================================================
# Install prerequisites and dependencies
# =============================================================================
RUN apt-get update && apt-get install -y --no-install-recommends \
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
    && rm -rf /var/lib/apt/lists/*

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

# Set working directory
WORKDIR /workspace

# Default command
CMD ["dotnet", "--info"]
