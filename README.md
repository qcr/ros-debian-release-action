# ros-debian-release-action
Composite action to run docker containers for building debians.

Supported architectures are:
- ***[Default]*** amd64
- arm64
- arm32 (armhf)*

Supported ROS distributions
- Melodic (Ubuntu 18.04 Bionic)
- ***[Default]*** Noetic (Ubuntu 20.04 Focal)

\* the arm32 (armhf) is supported, however the build time is excessive. It is recommended to only use this option where required, and default to either amd64 and/or arm64 going forward.

## Description
This action is used in conjunction with a ROS package (or workspace, containing multiple ROS packages) to build debians for each of the architectures highlighted above.

## Usage Example

The following is a standard use case of the action, which requires the preceding action(s) [checkout, setup-qemu-action] to get your package(s) and ensure emulation of the different architectures works within each docker container. A working example can be found in the [example-ros-release](https://github.com/qcr/example-ros-release) repo.

The default functionality of the action (as implemented below) will build your ROS package within a noetic amd64 container. Note that the ***runs-on*** argument can remain the latest ubuntu version, as the containers will have the specified architecture and os version.

```yaml
jobs:
  # Example release action for each architecture
  release-build-action:
    runs-on: ubuntu-latest
    name: Release-Build-Pipeline
    steps:
      # Checks-out your repository into a ws/src folder
      # NOTE: this must remain as the path for the action to work 
      - name: Checkout Package
        uses: actions/checkout@v2
        with:
          path: ws/src/${{ github.event.repository.name }}
      # Required emulation for arm architecture
      - name: Setup QEMU dependency
        uses: docker/setup-qemu-action@v1
      # Builds your packages with default architecture (amd64) and ros distribution (noetic)
      - name: Run Release Workflow
        id: build
        uses: qcr/ros-debian-release-action@master
```

Alternatively, architectures and specific ros-distros can be passed in via a strategy matrix with the required inputs (see below). In the below example, all architectures (amd64, arm64, and arm32 are built within melodic (18.04) and noetic (20.04) containers).

```yaml
jobs:
  # Example release action for each architecture and ros-distro
  release-build-action:
    runs-on: ubuntu-latest
    strategy:
      matrix:
        include:
          - ros-distro: melodic
            arch: amd64
          - ros-distro: melodic
            arch: arm64
          - ros-distro: melodic
            arch: arm32
          - ros-distro: noetic
            arch: amd64
          - ros-distro: noetic
            arch: arm64
          - ros-distro: noetic
            arch: arm32
    name: Release-Build-Pipeline
    steps:
      # Checks-out your repository into a ws/src folder 
      # NOTE: this must remain as the path for the action to work 
      - name: Checkout Package
        uses: actions/checkout@v2
        with:
          path: ws/src/${{ github.event.repository.name }}
      # Required emulation for arm architecture
      - name: Setup QEMU dependency
        uses: docker/setup-qemu-action@v1
      # Builds your packages within a different architectures/distros 
      - name: Run Release Workflow
        id: build
        uses: qcr/ros-debian-release-action@master
        with:
          architecture: ${{ matrix.arch }}
          ros-distro: ${{ matrix.ros-distro }}
```
