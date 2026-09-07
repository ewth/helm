# Helm dev container: ROS2 Jazzy, Gazebo Harmonic
FROM osrf/ros:jazzy-desktop-full

ARG USERNAME=dev
ARG UID=1000
ARG GID=1000
ENV DEBIAN_FRONTEND=noninteractive

RUN curl -sSL https://packages.osrfoundation.org/gazebo.gpg -o /usr/share/keyrings/pkgs-osrf-archive-keyring.gpg \
    && echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/pkgs-osrf-archive-keyring.gpg] http://packages.osrfoundation.org/gazebo/ubuntu-stable $(lsb_release -cs) main" \
    > /etc/apt/sources.list.d/gazebo-stable.list

RUN apt-get update && apt-get install -y --no-install-recommends \
    sudo git build-essential cmake gdb ccache \
    python3-colcon-common-extensions python3-rosdep python3-vcstool \
    ros-jazzy-ros-gz \
    ros-jazzy-robot-localization \
    mesa-utils vim less iputils-ping \
    nano \
    ros-jazzy-rqt ros-jazzy-rqt-common-plugins \
    # Additional vrx reqs
    python3-sdformat14 ros-jazzy-xacro ros-jazzy-ros-gz-interfaces \
    && rm -rf /var/lib/apt/lists/*

RUN (userdel -r ubuntu 2>/dev/null || true) \
    && groupadd -g ${GID} ${USERNAME} \
    && useradd -m -u ${UID} -g ${GID} -s /bin/bash ${USERNAME} \
    && echo "${USERNAME} ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/${USERNAME} \
    && chmod 0440 /etc/sudoers.d/${USERNAME}

ENV NVIDIA_VISIBLE_DEVICES=all
ENV NVIDIA_DRIVER_CAPABILITIES=all
ENV QT_X11_NO_MITSHM=1

USER ${USERNAME}
WORKDIR /ws
RUN echo 'source /opt/ros/jazzy/setup.bash' >> ~/.bashrc \
    && mkdir -p ~/.cache/ccache ~/.gz

CMD ["bash"]
