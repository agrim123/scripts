#! /bin/bash

# to check which one has free space.
df -h

sudo su

# First create a file.
# 1GB swap
dd if=/dev/zero of=/home/swap1 bs=1024 count=1024000

# Make this file owned by the root user
chown root:root /home/swap1

# allow only root to read and write to it
chmod 0600 /home/swap1

# Turn it into a swap file
mkswap /home/swap1

# Activate the new swap space without rebooting
swapon /home/swap1

# Add it to the fstab file so it works on reboot
echo "/home/swap1 none swap sw 0 0" >> /etc/fstab

# Check the new space is being used typing this
swapon --show
