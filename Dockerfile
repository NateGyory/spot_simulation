FROM osrf/ros:noetic-desktop-full

ARG DEBIAN_FRONTEND=noninteractive

RUN apt-get update && \
  apt-get install -y \
  python3-rosdep \
  python3-rosinstall \
  python3-rosinstall-generator \
  python3-vcstool \
  build-essential \
  python3-catkin-tools \
  git


RUN rosdep init; rosdep update

RUN echo "source /opt/ros/noetic/setup.bash" >> /root/.bashrc

RUN mkdir -p /catkin_ws/src/
WORKDIR /catkin_ws

SHELL ["/bin/bash", "-c"] 
COPY ./setup.bash /setup.bash
COPY ./ros_pkgs.repos /ros_pkgs.repos

RUN vcs import --recursive ./src --input /ros_pkgs.repos

RUN cd /catkin_ws && \
  rosdep install --from-paths src --ignore-src -r -y
  
RUN cd /catkin_ws/src/robots && \
    ./install_descriptions

RUN source /opt/ros/noetic/setup.bash && \
  cd /catkin_ws && \
  catkin build && \ 
  source /catkin_ws/devel/setup.bash && \
  catkin build

RUN chmod +x /setup.bash

CMD ["tail", "-f", "/dev/null"]
#CMD /setup.bash
