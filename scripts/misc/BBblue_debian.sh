### FOR BEAGLEBONE BLUE with Debian Stretch

sudo sh -c 'echo "deb http://packages.ros.org/ros/ubuntu stretch main" > /etc/apt/sources.list.d/ros-latest.list'
wget https://raw.githubusercontent.com/ros/rosdistro/master/ros.key  -O - | sudo apt-key add -
sudo apt-get update
sudo apt-get upgrade
sudo apt-get install -y python-pip python-setuptools python-yaml python-distribute python-docutils python-dateutil python-six
sudo pip install rosdep rosinstall_generator wstool rosinstall

sudo apt-get install -y \
     libconsole-bridge-dev liblz4-dev checkinstall cmake \
     python-empy python-nose libbz2-dev \
     libboost-test-dev libboost-dev  libboost-program-options-dev \
     libboost-regex-dev libboost-signals-dev \
     libtinyxml-dev libboost-filesystem-dev libxml2-dev \
     libgtest-dev

sudo rosdep init
rosdep update

mkdir -p ~/catkin_ws/src
cd ~/catkin_ws/

rosinstall_generator ros_comm --rosdistro kinetic --deps --wet-only --exclude roslisp --tar > kinetic-ros_comm-wet.rosinstall
wstool init src kinetic-ros_comm-wet.rosinstall

# connect USB for swap
sudo blkid
sudo mkswap /dev/sda1
sudo swapon /dev/sda1

rosdep install --from-paths src --ignore-src --rosdistro kinetic -y -r --os=debian:stretch

sudo ./src/catkin/bin/catkin_make_isolated --install -DCMAKE_BUILD_TYPE=Release --install-space /opt/ros/kinetic

cd ~/catkin_ws
catkin_make
    
echo "source /opt/ros/kinetic/setup.sh" >> ~/.bashrc
echo "source ~/catkin_ws/devel_isolated/setup.sh" >> ~/.bashrc
source ~/.bashrc

# Create key for passwordless SSH connection to main server
ssh-keygen -t rsa -b 4096 -C "bb@beaglebone"
# Copy this to ~/.ssh/autohized_keys on main server:
cat ~/.ssh/id_rsa.pub 


### FOR BEAGLEBONE BLUE wifi conf

sudo su -
connmanctl
connmanctl> tether wifi off (not really necessary on latest images)
connmanctl> enable wifi (not really necessary)
connmanctl> scan wifi
connmanctl> services (at this point you should see your network appear along with other stuff, in my case it was "AR Crystal wifi_f45eab2f1ee1_6372797774616c_managed_psk")
connmanctl> agent on
connmanctl> connect wifi_f45...16c_managed_psk
connmanctl> quit

### END FOR BEAGLEBONE BLUE wifi conf

