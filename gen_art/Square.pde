// Class to display the lines on the sides
class Square {
  // Minimum and maximum position Z
  float startingZ = -10000;
  float maxZ = 50;
  float maxR = 500;
  float displayTransparency = 0.0;
  int timeout = (int)random(0, 10);
  
  // Position values
  float x, y, z;
  int direction;
  float speedMultiplier;
  float rotation;
  float startR;
  
  // Constructor
  Square(float x, float y) {
    // Make the line appear at the specified location
    this.x = x;
    this.y = y;
    // Random depth
    this.z = random(startingZ, maxZ);
    
    // random direction up/down
    if (random(-1.0, 1.0) > 0) {
      this.direction = 1;
    } else {
      this.direction = -1;
    }
    
    // smaller circles are faster
    speedMultiplier = random(0.8, 1.2) * 10.0;
    this.startR = random(1.0, 1.2) * 200.0;
    
    if (x > 0) {
      this.rotation = -PI/2;
    } else {
      this.rotation = PI/2;
    }
  }
  
  float getDisplayTransparency() {
    return displayTransparency;
  }
  
  void setDisplayTransparency(float val) {
    displayTransparency = val;
    //if (val == 0.0) {
    //  timeout = 120;
    //  println("timeout set");
    //}
  }
  
  float getTimeout() {
    return timeout;
  }
  
  void setTimeout(int val) {
    timeout = val;
  }
  
  void reduceTimeout() {
    timeout -= 1;
  }
  
  // Display function
  void display(float scoreLow, float scoreMid, float scoreHi, float scoreGlobal, float drumsTransparency) {
    // Color determined by low, medium and high sounds
    // Opacity determined by the overall volume
    
    
    // First band, the one that moves according to the force
    // Transformation matrix
    pushMatrix();
    
    // Shifting
    translate(x, y, z);

    //translate(0, height/2, -500);
    // TODO tukej je ideja, da bo random band
    strokeWeight(1);
    stroke(100+scoreLow, 100+scoreMid, 100+scoreHi, ((scoreGlobal-5)/100)*(255+(z/20))*drumsTransparency*displayTransparency);
    fill(100+scoreLow, 100+scoreMid, 100+scoreHi, ((scoreGlobal-5)/1000)*(255+(z/25))*drumsTransparency*displayTransparency);
    rotateY(rotation);
    rect(0, 0, startR, startR);
    
    popMatrix();
    
    //y += direction*speedMultiplier;
    //if (y > height - startR/2.0 || y < startR/2.0) {
    //  direction *= -1;
    //}
    // Shifting Z towards us
    //z += (pow((scoreGlobal/150), 2));
    //z += scoreGlobal/150;
    //if (z >= maxZ) {
    //  z = startingZ;  
    //}
    z += scoreGlobal/150;
    if (z >= maxZ) {
      z = startingZ;  
    }
  }
}
