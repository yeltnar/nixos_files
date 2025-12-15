#!/bin/sh /etc/rc.common

USE_PROCD=1
START=99
STOP=01

SERVICE_NAME="My Custom Startup Script"

start_service() {
    procd_open_instance
    procd_set_param command /bin/sh "/root/playin/qemu/run-image.sh"
    procd_close_instance
}

# Define the stop function (useful if you start a long-running process)
stop_service() {
    # TODO fix this stop script
    killall qemu-system-x86_64
}

# Define the restart/reload function (optional)
restart() {
    stop
    start
}

# The /etc/rc.common handles the procd boilerplate for you
