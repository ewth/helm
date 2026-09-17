#!/usr/bin/env bash

sudo apt update
rosdep update
rosdep install --from-paths src --ignore-src -r -y
colcon build --merge-install --cmake-args -DCMAKE_BUILD_TYPE=Release
