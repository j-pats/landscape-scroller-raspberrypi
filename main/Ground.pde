class Ground {
  // Basic attributes
  int l_num, w_num;
  float v_space;
  ArrayList<Vertex[]> verts;
  float noiseScale = 0.004;
  float scaleFactor = 100;
  float distanceThreshold = 0.85;
  
  public Ground(int len, int wid, float space){
    this.l_num = len;
    this.w_num = wid;
    this.v_space = space;
    createVertices();
  }
  
  private float getNoiseY(float x, float z) {
    return noise(x*noiseScale, z*noiseScale, 0.0) * scaleFactor;
  }
  
  private void createVertices() {
    verts = new ArrayList<Vertex[]>();
    // creates the array of vertices
    for (int i = 0; i < this.l_num; i++) {
      Vertex vertRow[] = new Vertex[this.w_num];
      for (int j = 0; j < this.w_num; j++) {
        // creates 20x20 points
        float x = (i * VERTEX_SPACE);
        float z = (j * VERTEX_SPACE);
        float noiseVal = getNoiseY(x, z);;
        vertRow[j] = new Vertex(x, noiseVal, z);
      }
      verts.add(vertRow);
    }
  }
  
  public void drawGround(){
    for (int i = 0; i < verts.size(); i++) {
      for (int j = 0; j < this.w_num; j++) {
        stroke(184 - (verts.get(i)[j].getY() / 1.3), 0, 245, 255 - (i * (255.0 / verts.size())) );
        //if (i == verts.size() - 1) {
        //  stroke(255,0,0);
        //}
        if (i < verts.size() - 1 && j < this.w_num - 1) {
          line(verts.get(i)[j].getX(), verts.get(i)[j].getY(), verts.get(i)[j].getZ(), verts.get(i+1)[j+1].getX(), verts.get(i+1)[j+1].getY(), verts.get(i+1)[j+1].getZ());
        }
      
        if (i < verts.size() - 1 - 1) {
          line(verts.get(i)[j].getX(), verts.get(i)[j].getY(), verts.get(i)[j].getZ(), verts.get(i+1)[j].getX(), verts.get(i+1)[j].getY(), verts.get(i+1)[j].getZ());
        }
      
        if (j < this.w_num - 1) {
          line(verts.get(i)[j].getX(), verts.get(i)[j].getY(), verts.get(i)[j].getZ(), verts.get(i)[j+1].getX(), verts.get(i)[j+1].getY(), verts.get(i)[j+1].getZ());
        }
      }
    }
  }
  
  public void updateLandscapePoints(float cameraPos) {
    // check if rows need to be added
    float totalLen = Math.abs(verts.get(0)[0].getX() - verts.get(verts.size() - 1)[0].getX());
    float currLen = Math.abs(cameraPos - verts.get(verts.size() - 1)[0].getX());
    //println("Total Len: " + totalLen);
    //println("Curr Len: " + currLen);
    if (currLen  < 1500) {
      addRow();
    }
    
    // check if rows need to be deleted
    if (verts.get(0)[0].getX() < cameraPos - 200) {
      removeRow();
    }
  }
  
  private void addRow() {
    // set base value
    float furthest = verts.get(verts.size() - 1)[0].getX();
    Vertex vertRow[] = new Vertex[this.w_num];
      for (int j = 0; j < this.w_num; j++) {
        // creates 20x20 points
        float x = (furthest + VERTEX_SPACE);
        float z = (j * VERTEX_SPACE);
        float noiseVal = getNoiseY(x, z);;
        vertRow[j] = new Vertex(x, noiseVal, z);
      }
      verts.add(vertRow);
  }
  
    private void removeRow() {
    // set base value
    verts.remove(0);
  }
  
  public void ChangeScale(float value) {
    this.scaleFactor = value;
    println("Scale factor: " + scaleFactor);
    
  }
  
  public float getScale() {
    return this.scaleFactor;
  }
  
}
