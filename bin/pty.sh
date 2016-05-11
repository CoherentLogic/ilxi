#!/bin/bash

sudo socat -d -d pty,raw,echo=0,link=/dev/ilximcon pty,raw,echo=0,link=/dev/modem &
sudo chmod 777 /dev/pts/*
