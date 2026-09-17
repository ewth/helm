#!/usr/bin/env bash

source /ws/vrx_ws/install/setup.bash
ros2 launch vrx_gz competition.launch.py world:=sydney_regatta
