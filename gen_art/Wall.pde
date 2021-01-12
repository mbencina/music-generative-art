// Class to display the lines on the sides
class Wall {
  // Minimum and maximum position Z
  float startingZ = -10000;
  float maxZ = 50;
  
  // Position values
  float x, y, z;
  float sizeX, sizeY;
  
  boolean displayForceBand;
  float multiplier, speedMultiplier;
  
  // Constructor
  Wall(float x, float y, float sizeX, float sizeY, boolean displayForceBand) {
    // Make the line appear at the specified location
    this.x = x;
    this.y = y;
    // Random depth
    this.z = random(startingZ, maxZ);  
    
    // We determine the size because the walls on the floors have a different size than those on the sides
    this.sizeX = sizeX;
    this.sizeY = sizeY;
    
    this.displayForceBand = displayForceBand;
    multiplier = 1.0;
    speedMultiplier = 1.0;
    if (!displayForceBand) {
      multiplier = random(0.5, 3);
      speedMultiplier = random(0.8, 1.2);
    }
  }
  
  // Display function
  void display(float scoreLow, float scoreMid, float scoreHi, float intensity, float scoreGlobal, int sameInsSec) {
    // Color determined by low, medium and high sounds
    // Opacity determined by the overall volume
    color displayColor = color(scoreLow*0.67, scoreMid*0.67, scoreHi*0.67, scoreGlobal);
    
    // Make the lines disappear in the distance to give an illusion of fog
    fill(displayColor, ((scoreGlobal-5)/1000)*(255+(z/25)));
    noStroke();
    
    // First band, the one that moves according to the force
    // Transformation matrix
    if (displayForceBand) {
      pushMatrix();
      
      // Shifting
      translate(x, y, z);
      
      // Enlargement
      if (intensity > 100) intensity = 100;
      scale(sizeX*(intensity/100), sizeY*(intensity/100), 20);
      
      // Create the "box"
      box(1);
      popMatrix();
    }
    
    // Second band, the one that is always the same size
    displayColor = color(scoreLow*0.5, scoreMid*0.5, scoreHi*0.5, scoreGlobal);
    fill(displayColor, (scoreGlobal/5000)*(255+(z/25))*multiplier);
    // Transformation matrix
    pushMatrix();
    
    // Shifting
    translate(x, y, z);
    
    // Enlargement
    scale(sizeX, sizeY, 10);
    
    // Create the "box"
    box(1);
    popMatrix();
    
    // Shifting Z towards us
    z += (pow((scoreGlobal/150), 2))*speedMultiplier;
    
    if (z >= maxZ) {
      z = startingZ;  
    }
  }
}
