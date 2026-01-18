FROM ghcr.io/boldsoftware/exeuntu:main

LABEL org.opencontainers.image.title="dotnet-dev"
LABEL org.opencontainers.image.description=".NET Development Environment"
LABEL org.opencontainers.image.source="https://github.com/ryandanthony/dotnet-dev"
LABEL org.opencontainers.image.vendor="ryandanthony"

# exe.dev configuration - tells exe.dev which user to use for SSH
LABEL exe.dev/login-user="devuser"

# exe.dev default proxy ports
EXPOSE 8000 9999

# exe.dev requires this environment variable for SSH authentication
ENV EXEUNTU=1

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
    libc6 \
    libgcc-s1 \
    libicu74 \
    libssl3 \
    libstdc++6 \
    zlib1g \
    git \
    && rm -rf /var/lib/apt/lists/*

# =============================================================================
# .NET SDK Installation
# =============================================================================
ENV DOTNET_ROOT=/usr/share/dotnet
ENV PATH="${PATH}:${DOTNET_ROOT}:${DOTNET_ROOT}/tools"
ENV DOTNET_CLI_TELEMETRY_OPTOUT=1
ENV DOTNET_SYSTEM_GLOBALIZATION_INVARIANT=false

RUN mkdir -p ${DOTNET_ROOT}

# Install .NET SDK 10
RUN curl -sSL https://dot.net/v1/dotnet-install.sh -o /tmp/dotnet-install.sh \
    && chmod +x /tmp/dotnet-install.sh \
    && /tmp/dotnet-install.sh --channel 10.0 --install-dir ${DOTNET_ROOT} \
    && rm /tmp/dotnet-install.sh

# Verify installation
RUN dotnet --list-sdks && dotnet --list-runtimes

USER root
WORKDIR /home/devuser
