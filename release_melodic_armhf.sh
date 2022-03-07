echo "Running Release Pipeline..."
echo "Ros distro is $INPUT_ROS_DISTRO"

# Install Required dependencies
echo "Getting Required Libraries..."
# Add qcr repos for any specific package dependencies
apt-key adv --keyserver hkp://keyserver.ubuntu.com --recv-key 5B76C9B0
sh -c 'echo "deb [arch=$(dpkg --print-architecture)] https://packages.qcr.ai $(lsb_release -sc) main" > /etc/apt/sources.list.d/qcr-latest.list'
apt -y update 

echo "Running in bionic..."
apt install -y python-pip python-dev python-bloom python-stdeb dh-make git wget fakeroot

# Debugging output of cmake build (not required)
echo "cmake upgrade not required..."
echo "Sanity check of existing cmake version:"
cmake --version

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
