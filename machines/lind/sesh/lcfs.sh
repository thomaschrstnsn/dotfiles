#! /usr/bin/env bash

function mount_lcfs()
{
    osascript <<EOF
mount volume "smb://vmlcfs01/Kubernetes"
EOF
}

mount_lcfs

tmux send-keys "y" Enter
