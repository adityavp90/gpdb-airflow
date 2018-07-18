#!/usr/bin/env bash

echo root:pivotal | chpasswd
yum install -y unzip which tar more util-linux-ng passwd openssh-clients openssh-server ed m4 tk libgomp wget gcc g++
yum clean all
