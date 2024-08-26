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
oldAnalogValue0 = channel0.value
oldAnalogValue1 = channel1.value

# send inital values
client.send_message("/analog0", channel0.value)
client.send_message("/analog1", channel1.value)

# Loop to read analog inputs
while True:
    #print("Analog Value 1: ", channel1.value, "Voltage 1: ", channel1.voltage)

    #Get analog values from ADS1115
    analogValue0 = channel0.value
    analogValue1 = channel1.value

    #If analog value changed send as OSC message
    if abs(oldAnalogValue0 - analogValue0) > 3:
        #Send new value A0
        client.send_message("/analog0", analogValue0)
        oldAnalogValue0 = analogValue0
        print("Analog Value 0: ", analogValue0)


    if abs(oldAnalogValue1 - analogValue1) > 3:
        #Send new value A1
        client.send_message("/analog1", analogValue1)
        oldAnalogValue1 = analogValue1
        print("Analog Value 1: ", analogValue1)

    # Delay sampling time (s)
    time.sleep(0.032)
