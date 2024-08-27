import oscP5.*;
import netP5.*;

OscP5 oscP5;

// Define storeage for the analog values and a changed flag
int analog0, analog1;
boolean newAnalogValue;
// Define max value: 3.3v/5v * 2^15 = 26400
int maxAnalogValue = 26400;

// vertex constants
float VERTEX_SPACE = 20.0;
int NUM_VERTEX_W = 120;
int NUM_VERTEX_L = 40;
// main objects
Ground g;
// movement value
float movement;
float movementRate;
// camera values
float eyeX, eyeY, eyeZ;
float posX, posY, posZ;

// Sketch limits
float minSpeed = 0.0f;
float maxSpeed = 50.0f;
float maxScale = 750.0f;
float minScale = 100.0f;


void setup() {
  size(800,480,P3D);
  fill(204);
  
  // Create ground
   g = new Ground(NUM_VERTEX_L, NUM_VERTEX_W, VERTEX_SPACE);
  
  oscP5 = new OscP5(this, 13575);
  newAnalogValue = false;
}

void draw() {
  lights();
  background(0);
  // Print if new analog value received
  if (newAnalogValue) {
    println("Analog0 = " + analog0);
    println("Analog1 = " + analog1);
    newAnalogValue = false;
  }
  //float w = (analog0 / (float)maxValue) * maxSize;
  //float h = (analog1 / (float)maxValue) * maxSize;
  
  // draw orientation arrows
  // X = RED
  stroke(255,0,0);
  line(0,0,0,50,0,0);
  // Y = GREEN
  stroke(0,255,0);
  line(0,0,0,0,50,0);
  // Z = BLUE
  stroke(0,0,255);
  line(0,0,0,0,0,50);
  
  // set camera values
  eyeX = (mouseX - width/2) + movement;
  eyeY = -mouseY + 100;
  eyeZ = (NUM_VERTEX_W * VERTEX_SPACE) / 2;
  posX = (8 * VERTEX_SPACE) + movement;
  posY = 0.0;
  posZ = (NUM_VERTEX_W * VERTEX_SPACE) / 2;
  
  // set camera position
  camera(eyeX, eyeY, eyeZ, posX, posY, posZ, 0.0, 1.0, 0.0);

  // update land with new camera position
  g.updateLandscapePoints(posX);
  
  // draw landscape
  stroke(255);
  g.drawGround();
  
  movement += movementRate;
  
}

// Message event
void oscEvent(OscMessage msg) {

  if (msg.checkAddrPattern("/analog0") == true) {
    // Analog0 value
    analog0 = msg.get(0).intValue();
    newAnalogValue = true;
    // adjust speed
    movementRate = (analog0 / maxAnalogValue) * (maxSpeed - minSpeed);
  } else if (msg.checkAddrPattern("/analog1") == true) {
    // Analog1 value
    analog1 = msg.get(0).intValue();
    newAnalogValue = true;
    // adjust scale
    g.ChangeScale((analog0 / maxAnalogValue) * (maxSpeed - minSpeed));
  }
  //msg.print();  
}

void keyPressed(KeyEvent event) {
  if (keyCode == 'W') {
    movementRate = min(movementRate + 1.0, maxSpeed);
  } else if (keyCode == 'S'){
  movementRate = max(movementRate - 1.0, minSpeed);
  } else if (keyCode == 'A') {
    g.ChangeScale(min(g.getScale() + 25.0f, maxScale));
  } else if (keyCode == 'D') {
    g.ChangeScale(max(g.getScale() - 25.0f, minScale));
  }
}
