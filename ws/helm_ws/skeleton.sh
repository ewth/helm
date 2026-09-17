#!/usr/bin/env bash

source /opt/ros/jazzy/setup.bash
source /ws/vrx_ws/install/setup.bash

cd /ws/helm_ws/src || exit

ros2 pkg create helm_msgs --build-type ament_cmake --license MIT --dependencies geometry_msgs action_msgs

for pkg in guidance control allocation mission; do
  ros2 pkg create helm_${pkg} --build-type ament_cmake --license MIT --node-name ${pkg}_node --dependencies rclcpp helm_msgs
done

ros2 pkg create helm_hardware --build-type ament_cmake --license MIT --node-name vrx_thruster_node --dependencies rclcpp helm_msgs std_msgs

ros2 pkg create helm_localisation --build-type ament_cmake --license MIT --dependencies robot_localization
ros2 pkg create helm_bringup --build-type ament_cmake --license MIT
mkdir -p helm_localisation/{launch,config} helm_bringup/{launch,config}
