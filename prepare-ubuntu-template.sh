#!/bin/bash

new_hostname=“ubuntu-$RANDOM”

sudo apt update -y
sudo apt upgrade -y
sudo apt dist-upgrade -y

sudo apt install qemu-guest-agent -y
sudo systemctl enable qemu-guest-agent

sudo aa-remove-unknown
sudo apt-get purge --auto-remove apparmor

sudo touch /etc/cloud/cloud-init.disabled

sudo truncate -s 0 /etc/machine-id

sudo echo '[Unit]
Description=Regenerate SSH host keys
Before=ssh.service
ConditionFileIsExecutable=/usr/bin/ssh-keygen

[Service]
Type=oneshot
ExecStartPre=-/bin/dd if=/dev/hwrng of=/dev/urandom count=1 bs=4096
ExecStartPre=-/bin/sh -c "/bin/rm -f -v /etc/ssh/ssh_host__key"
ExecStart=/usr/bin/ssh-keygen -A -v
ExecStartPost=/bin/systemctl disable reset_ssh_host_keys
ExecStartPost=/bin/apt update -y
ExecStartPost=/bin/apt upgrade -y
ExecStartPost=/sbin/reboot

[Install]
WantedBy=multi-user.target' >/etc/systemd/system/reset_ssh_host_keys.service

sudo systemctl daemon-reload
sudo systemctl enable reset_ssh_host_keys

sudo hostnamectl set-hostname $new_hostname

cat /dev/null >~/.bash_history
history -c

sudo poweroff
