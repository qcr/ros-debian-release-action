#!/usr/bin/bash

echo "Running Release Pipeline..."
echo "Ros distro is $INPUT_ROS_DISTRO"

# Install Required dependencies
echo "Getting Required Libraries..."
# Add qcr repos for any specific package dependencies
apt-key adv --keyserver hkp://keyserver.ubuntu.com --recv-key 5B76C9B0
sh -c 'echo "deb [arch=$(dpkg --print-architecture)] https://packages.qcr.ai $(lsb_release -sc) main" > /etc/apt/sources.list.d/qcr-latest.list'
apt -y update 
apt install -y python3-pip python3-dev python3-bloom python3-stdeb dh-make git wget fakeroot systemd
# Symbolic link python command to python3 (default behaviour)
ln -s /usr/bin/python3 /usr/local/bin/python

# TEMP - testing systemctl run
echo "Running /usr/sbin/init"
ls -la /usr/sbin/
exec /usr/sbin/init
echo "Testing systemctl..."
systemctl --version

# Source the ROS workspace
echo "Source ROS workspace"
source /opt/ros/$INPUT_ROS_DISTRO/setup.sh

echo "Enter docker mounted workspace folder for releasing package(s)"
cd /docker_ws

echo "Clone release tools action from QCR repos"
git clone https://github.com/qcr/release-tools-ros.git
cd release-tools-ros
# This is the docker ws/src/<package>/release-tools-ros
ln -s ../src src
echo "running release script"
./release
echo "COMPLETED RELEASE PIPELINE"
