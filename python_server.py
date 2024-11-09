import board
import busio
import adafruit_ads1x15.ads1115 as ADS
from adafruit_ads1x15.analog_in import AnalogIn
import time
from pythonosc import udp_client
import argparse
import os
import numpy as np
from collections import deque

# Initialize the I2C interface
i2c = busio.I2C(board.SCL, board.SDA)

# Create an ADS1115 object
ads = ADS.ADS1115(i2c)

# Define the analog input channels
channel0 = AnalogIn(ads, ADS.P0)
channel1 = AnalogIn(ads, ADS.P1)

# Parser arguments
parser = argparse.ArgumentParser()
parser.add_argument("--ip", default="127.0.0.1", help="IP of OSC server")
parser.add_argument("--port", type=int, default=13575, help="Port OSC Server is listening on")
args = parser.parse_args()

# Setup OSC client
client = udp_client.SimpleUDPClient(args.ip, args.port)

# Save original analog integer values
lastSentValue0 = channel0.value
lastSentValue1 = channel1.value

# Setup channel deques - initialized to store all 
deque0 = deque(lastSentValue0) * 10
deque1 = deque(lastSentValue1) * 10

print(deque0)
print(deque1)

# Send inital values
# Converted digital value: channelX.value
# Analog voltage: channelX.voltage
client.send_message("/analog0", lastSentValue0)
client.send_message("/analog1", lastSentValue1)

while True:
    #Read converted values from ADS1115
    newValue0 = channel0.value
    newValue1 = channel1.value

    # If value not extreme, add to deque
    if newValue0 * lastSentValue0 > 0 and abs(newValue0 - lastSentValue0) < 250:
        deque0.appendleft(newValue0)
        deque0.pop()

        # check read value against average
        avg0 = np.average(deque0)
        if abs(avg0 - lastSentValue0) > 5:
            # Send message with value, wake up screen
            client.send_message("/analog0", avg0)
            lastSentValue0 = avg0
            os.system('xset dpms force on')
            print("Sent value 0: ", avg0)


    # If value not extreme, add to deque
    if newValue1 * lastSentValue1 > 0 and abs(newValue1 - lastSentValue1) < 250:
        deque1.appendleft(newValue1)
        deque1.pop()

        # check read value against average
        avg1 = np.average(deque1)
        if abs(avg1 - lastSentValue1) > 5:
            # Send message with value, wake up screen
            client.send_message("/analog1", avg1)
            lastSentValue1 = avg1
            os.system('xset dpms force on')
            print("Sent value 1: ", avg1)

    
    # Delay sampling time (~30 times second)
    time.sleep(0.032)
