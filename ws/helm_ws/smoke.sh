#!/usr/bin/env bash

# Very rudimentary smoke test

colcon build --symlink-install
source install/setup.bash
ros2 pkg list | grep helm_
ros2 run helm_control control_node
