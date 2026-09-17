# Helm

Autonomous USV project.

## Note

This is being developed to run inside a Docker container, utilising a NVIDIA GPU on the host for rendering.

Some specifics might not translate perfectly.

Apologies for the very sparse readme - more to come!

## Docker Container

* Build: `docker compose build`
* Start: `docker compose up -d`
* Enter: `docker compose exec helm bash`

Everything should be run from within the container.

## Building

1. Build VRX: `ws/vrx_ws/build.sh`
2. Build Helm: `ws/helm_ws/build.sh`

View the Bash scripts for more details.
