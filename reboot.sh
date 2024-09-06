#! /usr/bin/bash

# Activate python environment
cd ~
source scroller/bin/activate
# cd to project directory and run python script
cd ~/Projects/landscape-scroller-raspberrypi
python python_server.py &

# Run Processing sketch
cd ~
./Downloads/processing-4.3/processing-java --sketch=/home/jesse/Projects/landscape-scroller-raspberrypi/main --run &
