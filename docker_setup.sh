#!/bin/bash

set -e

echo "Setting up and Running Container..."
echo "Make a mount point for workspace (if not available)"
if [ ! -d ws ]; then
  mkdir -p ws;
fi
mount_point_path=$(realpath ws/)

ls -la $ACTION_PATH

# Only copy dependencies for arm32/armhf
# Bug in cmake that needs cmake-3.20 and greater AND an update to the bootstrap script (missing in standard cmake-3.20)
# This is why a pre-built cmake-3.20 is included for specifically building armhf debs successfully
# Also copy across action release workflow (specific if required) to required mount point
if [[ $INPUT_ARCH == 'arm32' ]]
then
    echo "Copy the action entrypoint into the mounted folder"
    cp $ACTION_PATH/release_armhf.sh $mount_point_path/release.sh
    echo "Copy the pre-built dependencies (i.e., cmake-3.20 version) for installation in container"
    rsync -aPv $ACTION_PATH/dependencies $mount_point_path
else
    echo "Copy the action entrypoint into the mounted folder"
    cp $ACTION_PATH/release_std.sh $mount_point_path/release.sh
fi

# Set to default
IMAGE=amd64

# Select correct image to run 
echo "Running Docker Container for Release..."
if [[ $INPUT_ARCH == 'amd64' ]]
then
    echo "AMD 64 RELEASE Confirmed"
    IMAGE=amd64
elif [[ $INPUT_ARCH == 'arm64' ]]
then 
    echo "ARM 64 RELEASE Confirmed"
    IMAGE=arm64v8
elif [[ $INPUT_ARCH == 'arm32' ]]
then 
    echo "ARM 32 RELEASE Confirmed"
    IMAGE=arm32v7
else
    echo "UNKNOWN ARCH - Exiting Gracefully"
    exit -1
fi

echo "Sanity Check INPUT_ROS_DISTRO: $INPUT_ROS_DISTRO"
echo "Sanity Check IMAGE: $IMAGE"

# Run container
docker run \
    -e INPUT_ROS_DISTRO=$INPUT_ROS_DISTRO \
    -v $mount_point_path:/docker_ws \
    --rm -t $IMAGE/ros:$INPUT_ROS_DISTRO docker_ws/release.sh

echo "Container Completed Builds Successfully"
echo "Enter Mount Point to Get debs..."
cd $mount_point_path/release-tools-ros/target
# Check for debs
if [ -f *.deb ]; then
    # Debs found, so set to output
    file_arr=(./*.deb)
    echo "Number of debs: ${#file_arr[@]}"
    file_num=${#file_arr[@]}
    counter=1
    for f in "${file_arr[@]}"; do 
        realpath_file=$(realpath $f)
        echo "$realpath_file"
        list+=\"$realpath_file\"
        if [ $counter != $file_num ]
        then
            echo "counter is $counter and file num is $file_num"
            echo "adding comma"
            list+=','
        fi
        ((counter=counter+1))
    done
    echo "list: [$list]"
    echo "::set-output name=files::[$list]"
else
    echo "No debs found..."
fi