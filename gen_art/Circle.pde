// Class to display the lines on the sides
class Circle {
  // Minimum and maximum position Z
  float startingZ = -10000;
  float maxZ = 50;
  float maxR = 500;
  float startR;
  
  // Position values
  float x, y, z;
  int direction;
  float speedMultiplier;
  float rotation;
  
  // Constructor
  Circle(float x, float y) {
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
    this.startR = random(0.5, 2.0) * 300.0 / speedMultiplier;
    
    if (x > 0) {
      this.rotation = -PI/2;
    } else {
      this.rotation = PI/2;
    }
  }
  
  // Display function
  void display(float scoreLow, float scoreMid, float scoreHi, float scoreGlobal, float vocalTransparency) {
    // Color determined by low, medium and high sounds
    // Opacity determined by the overall volume
    
    // First band, the one that moves according to the force
    // Transformation matrix
    pushMatrix();
    
    // Shifting
    translate(x, y, z);

    strokeWeight(1);
    stroke(100+scoreLow, 100+scoreMid, 100+scoreHi, ((scoreGlobal-5)/100)*(255+(z/20))*vocalTransparency);
    fill(100+scoreLow, 100+scoreMid, 100+scoreHi, ((scoreGlobal-5)/1000)*(255+(z/25))*vocalTransparency);
    rotateY(rotation);
    circle(0, 0, startR);
    
    popMatrix();
    
    y += direction*speedMultiplier;
    if (y > height - startR/2.0 || y < startR/2.0) {
      direction *= -1;
    }
    
    // Shifting Z towards us
    z += scoreGlobal/150;
    if (z >= maxZ) {
      z = startingZ;  
    }
  }
}
