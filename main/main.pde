import oscP5.*;
import netP5.*;

OscP5 oscP5;

// Define storeage for the analog values and a changed flag
int analog0, analog1;
boolean newAnalogValue;
// Define max value: 3.3v/5v * 2^15 = 26400
int maxAnalogValue = 26400;

// vertex constants
int VERTEX_SPACE = 20;
int NUM_VERTEX_W = 50;
int NUM_VERTEX_H = 40;
int GRID_OFFSET = (VERTEX_SPACE * NUM_VERTEX_W) / 2;

// noise attributes
float noiseScale = 0.004;
float zOffset = 0.0;

// adjustable attributes
float movementSpeed = 0.005;
float scaleFactor = 25;

// min/max values
float maxScale = 400;
float minScale = 25;
float minSpeed = 0;
float maxSpeed = 0.05;

Vertex[][] verts;

void setup() {
  size(800,480,P3D);
  fill(204);
  oscP5 = new OscP5(this, 13575);
  newAnalogValue = false;
  // now create the vertex array
  createVertices();
}

void draw() {
  lights();
  background(0);
  
    // set camera position
  //camera(GRID_OFFSET + 50 + (mouseX - width/2), -mouseY + 100, (NUM_VERTEX_H * VERTEX_SPACE), // eyeX, eyeY, eyeZ
  //       GRID_OFFSET, 0.0, (NUM_VERTEX_H * VERTEX_SPACE) - (8 * VERTEX_SPACE), // centerX, centerY, centerZ
  //       0.0, 1.0, 0.0); // upX, upY, upZ
  // output camera positions for locking down
  println("eyex:" + (GRID_OFFSET + 50 + (mouseX - width/2)) + "eyey:" + (-mouseY + 100) + "eyez:" + (NUM_VERTEX_H * VERTEX_SPACE));
  println("centerz:" + ((NUM_VERTEX_H * VERTEX_SPACE) - (8 * VERTEX_SPACE)));
    camera(500, -70, 800, // eyeX, eyeY, eyeZ
         GRID_OFFSET, 0.0, 640, // centerX, centerY, centerZ
         0.0, 1.0, 0.0);
         
         
  stroke(0,0,255);
  
  for (int i = 0; i < NUM_VERTEX_W; i++) {
    for (int j = 0; j < NUM_VERTEX_H; j++) {
      // creates 20x20 points
      //verts[i][j].drawVertex();
      if (i < NUM_VERTEX_W - 1 && j < NUM_VERTEX_H - 1) {
        line(verts[i][j].getX(), verts[i][j].getY(), verts[i][j].getZ(), verts[i+1][j+1].getX(), verts[i+1][j+1].getY(), verts[i+1][j+1].getZ());
      }
      
      if (i < NUM_VERTEX_W - 1) {
        line(verts[i][j].getX(), verts[i][j].getY(), verts[i][j].getZ(), verts[i+1][j].getX(), verts[i+1][j].getY(), verts[i+1][j].getZ());
      }
      
      if (j < NUM_VERTEX_H - 1) {
        line(verts[i][j].getX(), verts[i][j].getY(), verts[i][j].getZ(), verts[i][j+1].getX(), verts[i][j+1].getY(), verts[i][j+1].getZ());
      }
    }
  }
  
  // adnance the noise offset
  zOffset = zOffset - movementSpeed;
  
  updateVertices();
}

// Message event
void oscEvent(OscMessage msg) {

  if (msg.checkAddrPattern("/analog0") == true) {
    // Analog0 value
    analog0 = msg.get(0).intValue();
    newAnalogValue = true;
    movementSpeed = (analog0 / maxAnalogValue) * (maxSpeed - minSpeed);
  } else if (msg.checkAddrPattern("/analog1") == true) {
    // Analog1 value
    analog1 = msg.get(0).intValue();
    newAnalogValue = true;
    scaleFactor = (analog1 / maxAnalogValue) * (maxScale - minScale);
  }
  //msg.print();  
}

  void updateVertices() {
  // creates the array of vertices
  for (int i = 0; i < NUM_VERTEX_W; i++) {
    for (int j = 0; j < NUM_VERTEX_H; j++) {
      // creates all points
      float x = (i * VERTEX_SPACE);
      float z = (j * VERTEX_SPACE);
      float noiseVal = getNoiseY(x, z);
      verts[i][j].setY(noiseVal);
    }
  }
}

void createVertices() {
  verts = new Vertex[NUM_VERTEX_W][NUM_VERTEX_H];
  // creates the array of vertices
  for (int i = 0; i < NUM_VERTEX_W; i++) {
    for (int j = 0; j < NUM_VERTEX_H; j++) {
      // creates 20x20 points
      float x = (i * VERTEX_SPACE);
      float z = (j * VERTEX_SPACE);
      float noiseVal = getNoiseY(x, z);
      verts[i][j] = new Vertex(x, noiseVal, z);
    }
  }
}

float getNoiseY(float x, float z) {
  return noise(x*noiseScale, z*noiseScale + zOffset, 0.0) * scaleFactor;
}
