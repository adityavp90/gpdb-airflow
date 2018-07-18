#!/usr/bin/env bash

echo "127.0.0.1 $(cat ~/orig_hostname)" >> /etc/hosts
service sshd start
su gpadmin -l -c "/usr/local/bin/run.sh"
/bin/bash