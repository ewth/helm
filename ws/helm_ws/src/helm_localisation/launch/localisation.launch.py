import os

from ament_index_python.packages import get_package_share_directory
from launch import LaunchDescription
from launch_ros.actions import Node


def generate_launch_description():
    cfg = get_package_share_directory("helm_localisation")
    return LaunchDescription(
        [
            Node(
                package="robot_localization",
                executable="navsat_transform_node",
                name="navsat_transform",
                output="screen",
                parameters=[os.path.join(cfg, "config", "navsat_transform.yaml")],
                remappings=[
                    ("gps/fix", "/wamv/sensors/gps/gps/fix"),
                    ("imu", "/wamv/sensors/imu/imu/data"),
                ],
            ),
            Node(
                package="robot_localization",
                executable="ekf_node",
                name="ekf_filter_node",
                output="screen",
                parameters=[os.path.join(cfg, "config", "ekf.yaml")],
                remappings=[("imu/data", "/wamv/sensors/imu/imu/data")],
            ),
        ]
    )
