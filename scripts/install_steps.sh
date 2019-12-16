sudo apt-get update
sudo apt-get install -y vim git python-pip net-tools

#====================================
cat << EOF >> ~/.bashrc
### Added by cassandra_ros provision
export HISTCONTROL=ignoredups:erasedups
export HISTSIZE=100000
export HISTFILESIZE=100000
shopt -s histappend

# Save and reload the history after each command finishes
export PROMPT_COMMAND="history -a; history -c; history -r; $PROMPT_COMMAND"

alias cassandra-tunnel='ssh -L 9160:localhost:9160 agustin@rosnet.hopto.org'
alias cassandra-tunnel2='ssh -L 29160:localhost:9160 agustin@rosnet.hopto.org'
alias vnc-tunnel='ssh rosnet.hopto.org -L 5900:localhost:5900 "x11vnc -display :0 -noxdamage"'
###
EOF
#====================================


## Choose VIM
#sudo update-alternatives --config editor


# Install ROS

sudo sh -c 'echo "deb http://packages.ros.org/ros/ubuntu $(lsb_release -sc) main" > /etc/apt/sources.list.d/ros-latest.list'
sudo apt-key adv --keyserver 'hkp://keyserver.ubuntu.com:80' --recv-key C1CF6E31E6BADE8868B172B4F42ED6FBAB17C654
sudo apt-get update
sudo apt-get install -y ros-melodic-desktop-full
sudo apt-get install -y python-rosinstall python-rosinstall-generator python-wstool build-essential

sudo rosdep init
rosdep update

echo "source /opt/ros/melodic/setup.bash" >> ~/.bashrc
source ~/.bashrc

mkdir -p ~/catkin_ws/src
cd ~/catkin_ws/
catkin_make

echo "source ~/catkin_ws/devel/setup.bash" >> ~/.bashrc
source ~/.bashrc


# Install Cassandra

echo "deb http://www.apache.org/dist/cassandra/debian 311x main" | sudo tee -a /etc/apt/sources.list.d/cassandra.sources.list
curl https://www.apache.org/dist/cassandra/KEYS | sudo apt-key add -
sudo apt-get update
sudo apt-get install -y cassandra

sudo systemctl stop cassandra

# To enable Thrift RPC (needed by cassandra_ros)
sudo sed -i 's/start_rpc: false/start_rpc: true/g' /etc/cassandra/cassandra.yaml

# To change partitioner to ByteOrdered (needed by cassandra_ros)
sudo mkdir -p /var/lib/cassandra2
sudo chown -R cassandra:cassandra /var/lib/cassandra2

sudo sed -i 's/lib\/cassandra/lib\/cassandra2/g' /etc/cassandra/cassandra.yaml
sudo sed -i 's/partitioner: org.apache.cassandra.dht.Murmur3Partitioner/partitioner: org.apache.cassandra.dht.ByteOrderedPartitioner/g' /etc/cassandra/cassandra.yaml

sudo systemctl start cassandra


# Dependency for ARToolkit/ar_tools
sudo apt-get install -y libv4l-dev

### ??? sudo apt-get install -y ros-melodic-uvc-camera

# Install cassandra_ros and dependency project

cd ~/catkin_ws/src
# Cassandra ROS project
git clone https://github.com/guriandoro/cassandra_ros.git
# Converts between Python dictionaries and JSON to rospy messages. (needed by cassandra_ros)
git clone https://github.com/uos/rospy_message_converter.git
# AR Tools
git clone https://github.com/ar-tools/ar_tools.git
cd ..
catkin_make


# Install python packages

pip install pycassa 
pip install cql

# To avoid connection errors from pycassa module
pip install thrift==0.9.3

sudo apt-get install -y python-qt4

# USB Camera module for ROS
sudo apt-get install -y ros-melodic-usb-cam

## Install ARToolkit examples
## Warning: skip on environments with low disk space
#cd /home/agustin/catkin_ws/src/ar_tools/ar_pose/demo/
#./setup_demos
#roslaunch ar_pose demo_single.launch

# Launch master node -- will launch in fg
roscore

# Check topics
rosnode list

# Test cassandra_ros deployment

roslaunch cassandra_ros recordCamera.launch
roslaunch cassandra_ros replayCamera.launch
roslaunch cassandra_ros deleteCamera.launch

