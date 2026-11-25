#!/bin/bash

read -p "Enter SSH key name: " SSH_KEY_NAME
read -p "Enter IP: " IP
read -p "Enter port: " PORT

ssh-copy-id -i ~/.ssh/"$SSH_KEY_NAME" -p "$PORT" root@"$IP"
