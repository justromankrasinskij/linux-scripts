#!/bin/bash

read -p "Enter SSH key name: " SSH_KEY_NAME
read -p "Enter file location (on this computer): " FILE_LOCATION
read -p "Enter IP: " IP
read -p "Enter port: " PORT

FILE_NAME=$(basename ${FILE_LOCATION})

scp -i ~/.ssh/"$SSH_KEY_NAME" -P "$PORT" "$FILE_LOCATION" root@"$IP":~/"$FILE_NAME"
