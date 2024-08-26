import oscP5.*;
import netP5.*;

OscP5 oscP5;

// Define storeage for the analog values and a changed flag
int analog0, analog1;
boolean newAnalogValue;
// Define max value: 3.3v/5v * 2^15 = 26400
int maxSize = 200;
int maxValue = 26400;

void setup() {
  size(200,200);
  background(0);
  noStroke();
  fill(255);
  rectMode(CENTER);
  
  oscP5 = new OscP5(this, 13575);
  newAnalogValue = false;
}

void draw() {
  background(0);
  // Print if new analog value received
  if (newAnalogValue) {
    println("Analog0 = " + analog0);
    println("Analog1 = " + analog1);
    newAnalogValue = false;
  }
  float w = (analog0 / (float)maxValue) * maxSize;
  float h = (analog1 / (float)maxValue) * maxSize;
  print(analog0);
  //print(analog1);
  fill(255);
  rect(100,100,w, h);
}

// Message event
void oscEvent(OscMessage msg) {

  if (msg.checkAddrPattern("/analog0") == true) {
    // Analog0 value
    analog0 = msg.get(0).intValue();
    newAnalogValue = true;
  } else if (msg.checkAddrPattern("/analog1") == true) {
    // Analog1 value
    analog1 = msg.get(0).intValue();
    newAnalogValue = true;
  }
  //msg.print();  
}
