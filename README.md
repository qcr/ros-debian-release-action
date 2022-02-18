# ros-debian-release-action
Composite action to run docker containers for building debians.

Supported architectures are:
- amd64
- arm64
- arm32 (armhf)

## Description
This action is used in conjunction with a ROS package (or workspace, containing multiple ROS packages) to build debians for each of the architectures highlighted above.

## Usage Example

The following is a standard use case of the action, which requires the preceeding action(s) [checkout, setup-qemu-action] to get your package(s) and ensure emulation of the different architectures works within each docker container. Note that the architectures can be passed in via a strategy matrix with the required input strings.

The main input argument is the architecture, as demonstrated below. However, the ros-distro can also be passed in (defaulted to noetic).

```yaml
jobs:
  # Example release action for each architecture
  release-build-action:
    runs-on: ubuntu-latest
    strategy:
      matrix:
        include:
          - arch: 'amd64'
          - arch: 'arm64'
          - arch: 'arm32'
    name: Release-Build-Pipeline
    # Steps represent a sequence of tasks that will be executed as part of the job
    steps:
      # Checks-out your repository into a workspace/src folder 
      - name: Checkout Package
        uses: actions/checkout@v2
        with:
          path: ws/src/${{ github.event.repository.name }}
      - name: Setup QEMU dependency
        uses: docker/setup-qemu-action@v1
      # Builds your packages within a different architectures (in matrix above)
      - name: Run Release Workflow
        id: build
        uses: qcr/ros-debian-release-action@master
        with:
          architecture: ${{ matrix.arch }}
```
