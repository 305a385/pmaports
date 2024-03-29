#!/bin/sh
# shellcheck disable=SC1091
. ./init_functions.sh
. /usr/share/misc/source_deviceinfo
NBD_PORT=9999
NBD_IP=172.16.42.2
NBD_BLOCK_SIZE=${deviceinfo_rootfs_image_sector_size:-512}

setup_usb_network
start_unudhcpd

show_splash "Waiting for netboot...\\nhttps://postmarketos.org/netboot"

# Attempt to load the kernel module if CONFIG_BLK_DEV_NBD=m
modprobe nbd

# Check that we actually have nbd0 available, otherwise show an error screen.
if [ ! -b /dev/nbd0 ]; then
	echo "Failed to get /dev/nbd0, stopping."
	show_splash "ERROR: Failed to initialise netboot\\nhttps://postmarketos.org/netboot"
	pmos_loop_forever
fi

while ! busybox nbd-client $NBD_IP $NBD_PORT /dev/nbd0 -b "$NBD_BLOCK_SIZE"; do
	echo "Connection attempt not successful, continuing..."
	sleep 1
done

echo "Connected to $NBD_IP!"

mount_subpartitions
