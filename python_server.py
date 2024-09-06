import board
import busio
import adafruit_ads1x15.ads1115 as ADS
from adafruit_ads1x15.analog_in import AnalogIn
import time
from pythonosc import udp_client
import argparse

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
oldValue0 = channel0.value
oldValue1 = channel1.value

# Send inital values
# Converted digital value: channelX.value
# Analog voltage: channelX.voltage
client.send_message("/analog0", channel0.value)
client.send_message("/analog1", channel1.value)

while True:
    #Read converted values from ADS1115
    value0 = channel0.value
    value1 = channel1.value

    #If value changed send as OSC message
    if abs(oldValue0 - value0) > 3:
        # Send new value A0
        client.send_message("/analog0", value0)
        oldValue0 = value0
        print("Analog Value 0: ", value0)

    if abs(oldValue1 - value1) > 3:
        # Send new value A1
        client.send_message("/analog1", value1)
        oldValue1 = value1
        print("Analog Value 1: ", value1)
    
    # Delay sampling time (~30 times second)
    time.sleep(0.032)
