#!/bin/bash

echo "Hello, World, v2" > index.html
nohup busybox -f -p ${server_port} &
