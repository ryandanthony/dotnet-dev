# dotnet-dev

[![Build and Publish Docker Image](https://github.com/ryandanthony/dotnet-dev/actions/workflows/build.yml/badge.svg)](https://github.com/ryandanthony/dotnet-dev/actions/workflows/build.yml)

A Docker image for .NET development based on Ubuntu 24.04 LTS with .NET SDK 10.

## Quick Start

Pull the image from GitHub Container Registry:

```bash
docker pull ghcr.io/ryandanthony/dotnet-dev:latest
```

Run the container:

```bash
docker run -it --rm ghcr.io/ryandanthony/dotnet-dev:latest
```

Mount your project directory:

```bash
docker run -it --rm -v $(pwd):/workspace ghcr.io/ryandanthony/dotnet-dev:latest bash
```

## Image Details

| Component  | Version                         |
| ---------- | ------------------------------- |
| Base Image | Ubuntu 24.04 LTS (Noble Numbat) |
| .NET SDK   | 10.0                            |

## Features

- **Ubuntu 24.04 LTS** - Long-term support base image
- **.NET SDK 10** - Latest .NET SDK with full development tools
- **Git** - Version control pre-installed
- **Multi-architecture** - Supports `linux/amd64` and `linux/arm64`

## Available Tags

| Tag           | Description                            |
| ------------- | -------------------------------------- |
| `latest`      | Latest stable release from main branch |
| `x.y.z`       | Specific semantic version              |
| `x.y`         | Latest patch version for major.minor   |
| `x`           | Latest version for major release       |
| `sha-xxxxxxx` | Specific commit build                  |

## Building Locally

Build the image locally:

```bash
docker build -t dotnet-dev:local .
```

## Versioning

This project uses [GitVersion](https://gitversion.net/) for semantic versioning. Version numbers are automatically calculated based on Git history and commit messages.

### Commit Message Conventions

To control version bumps, include these tags in your commit messages:

- `+semver: major` or `+semver: breaking` - Bump major version
- `+semver: minor` or `+semver: feature` - Bump minor version
- `+semver: patch` or `+semver: fix` - Bump patch version
- `+semver: none` or `+semver: skip` - No version bump

## CI/CD

The image is automatically built and published to GitHub Container Registry via GitHub Actions:

- **Push to main**: Publishes with `latest` tag and version tags
- **Pull requests**: Builds but does not publish (validation only)
- **Tags (v\*)**: Publishes release versions

## Adding Additional .NET SDK Versions

The Dockerfile is structured to easily add more SDK versions. Uncomment and modify the section in the Dockerfile:

```dockerfile
# Install .NET SDK 8 (LTS)
RUN curl -sSL https://dot.net/v1/dotnet-install.sh -o /tmp/dotnet-install.sh \
    && chmod +x /tmp/dotnet-install.sh \
    && /tmp/dotnet-install.sh --channel 8.0 --install-dir ${DOTNET_ROOT} \
    && rm /tmp/dotnet-install.sh
```

## License

See [LICENSE](LICENSE) file for details.
Docker file and build for a dotnet development image.
