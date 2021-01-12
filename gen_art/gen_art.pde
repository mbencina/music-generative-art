import ddf.minim.*;
import ddf.minim.analysis.*;
//import com.hamoid.*; // video lib

// new
String CSV;
Table t;

// old 

Minim minim;
AudioPlayer song;
FFT fft;

//VideoExport videoExport;

// Variables which define the "zones" of the spectrum
// For example, for bass, we only take the first 4% of the total spectrum
float specLow = 0.03; // 3%
float specMid = 0.125;  // 12.5%
float specHi = 0.20;   // 20%

// So 64% of the possible spectrum remains that will not be used.
// These values are generally too high for the human ear anyway.

// Score values for each zone
float scoreLow = 0;
float scoreMid = 0;
float scoreHi = 0;

// Previous value, to soften the reduction
float oldScoreLow = scoreLow;
float oldScoreMid = scoreMid;
float oldScoreHi = scoreHi;

// Softening value
float scoreDecreaseRate = 20;

// Cubes that appear in space
int nbCubes;
Cube[] cubes;

// Lines that appear on the sides
int nbWalls = 500;
Wall[] walls;

// circles
Circle[] circles;
int nCircles = 200;

// squares
int nWallSquares = 100;
Square[] leftSquares;
Square[] rightSquares;

void setup()
{
  // Display in 3D on the whole screen
  fullScreen(P3D);
  
  // set the song
  String songPath = "extracting/music/cvet_short.wav";  // cvet_short memories_short technicolour_beat_short breed_short november_rain_short.wav mashup.mp3
  
  CSV = "extracting/" + split(split(songPath, '.')[0], "/")[2]  + ".csv";
  //CSV = "extracting/fake.csv"; // temporary
  t = loadTable(CSV, "header");
 
  minim = new Minim(this);
  song = minim.loadFile(songPath);
  fft = new FFT(song.bufferSize(), song.sampleRate());
  
  // One cube per frequency band
  nbCubes = 40; //(int)(fft.specSize()*specHi);
  //print(nbCubes);
  cubes = new Cube[nbCubes];
  
  // As many walls as we want
  walls = new Wall[nbWalls];

  // Create all the objects
  // Create the cube objects
  for (int i = 0; i < nbCubes; i++) {
   cubes[i] = new Cube(); 
  }
  
  //Create the wall objects
  // Left walls
  for (int i = 0; i < nbWalls; i+=4) {
   walls[i] = new Wall(0, height/2, 10, height, false); 
  }
  
  // Right walls
  for (int i = 1; i < nbWalls; i+=4) {
   walls[i] = new Wall(width, height/2, 10, height, false); 
  }
  
  // Low walls
  for (int i = 2; i < nbWalls; i+=4) {
   walls[i] = new Wall(width/2, height, width, 10, true); 
  }
  
  // High walls
  for (int i = 3; i < nbWalls; i+=4) {
   walls[i] = new Wall(width/2, 0, width, 10, true); 
  }
  
  // create circles
  circles = new Circle[nCircles];
  for (int i = 0; i < nCircles; i+=2) {
    circles[i] = new Circle(0, random(100, height-100));
  }
  
  for (int i = 1; i < nCircles; i+=2) {
    circles[i] = new Circle(width, random(100, height-100));
  }
  
  // create squares
  leftSquares = new Square[nWallSquares];
  for (int i = 0; i < nWallSquares; i++) {
    leftSquares[i] = new Square(0, random(50, height-250));
  }
  
  rightSquares = new Square[nWallSquares];
  for (int i = 0; i < nWallSquares; i++) {
    rightSquares[i] = new Square(width, random(50, height-250));
  }
  
  // TODO - background bi se lahko lepo spreminju glede na mood
  //Black background
  background(0);
  
  // Start the song
  song.play(0);
  songLen = song.length()/1000.0;
  
  //videoExport = new VideoExport(this, "visualisation.mp4");
  //videoExport.setFrameRate(60);  
  //videoExport.startMovie();
}

float songLen;
int called = 0;
int guitarLineCurr = 0;
int guitarLineTransparency = 0;
int lastSecond = -3;
String currInstrument = "";
String currGenre = "";
String lastInstrument = "";
int sameInstrumentSeconds = -1;
float vocalTransparency = 0.0;
float drumsTransparency = 0.0;

void draw()
{
  // Advance the song. We draw () for each "frame" of the song ...
  fft.forward(song.mix);
  called++;
  
  // update curr second and get curr instrument and genre
  int currSecond = (song.position() / 1000) - 2;  // start from -2 so the indexes work out
  if (currSecond != lastSecond) {
    lastSecond = currSecond;
    int rowIx = currSecond;
    if (currSecond < 0)
      rowIx = 0;
    if (currSecond >= t.getRowCount())
      rowIx -= 1;
    
    lastInstrument = currInstrument;
    TableRow row = t.getRow(rowIx);
    currInstrument = row.getString("instrument");
    if (currInstrument.equals(lastInstrument)) {
      sameInstrumentSeconds += 1;
      //println(sameInstrumentSeconds);
    } else {
      sameInstrumentSeconds = 0;
    }
    currGenre = row.getString("genre");
    //println(currInstrument);
  }
  
  
  // exit program when the song stops
  if (!song.isPlaying()) {
    // stop recording
    print("avg frames: ", (float)called/songLen);
    //videoExport.endMovie();
    exit();
  }
  
  // Calculate the "scores" (power) for three categories of sound
  // First, save the old values
  oldScoreLow = scoreLow;
  oldScoreMid = scoreMid;
  oldScoreHi = scoreHi;
  // Reset the values
  scoreLow = 0;
  scoreMid = 0;
  scoreHi = 0;
  // Calculate the new "scores"
  for(int i = 0; i < fft.specSize()*specLow; i++)
    scoreLow += fft.getBand(i);
  for(int i = (int)(fft.specSize()*specLow); i < fft.specSize()*specMid; i++)
    scoreMid += fft.getBand(i);
  for(int i = (int)(fft.specSize()*specMid); i < fft.specSize()*specHi; i++)
    scoreHi += fft.getBand(i);
  // Slow down the descent.
  if (oldScoreLow - scoreDecreaseRate > scoreLow)
    scoreLow = oldScoreLow - scoreDecreaseRate;
  if (oldScoreMid - scoreDecreaseRate > scoreMid)
    scoreMid = oldScoreMid - scoreDecreaseRate;
  if (oldScoreHi - scoreDecreaseRate > scoreHi)
    scoreHi = oldScoreHi - scoreDecreaseRate;
  // Volume for all frequencies at this time, with higher sounds more prominent.
  // This allows the animation to go faster for higher pitched sounds, which are more noticeable
  float scoreGlobal = 0.66*scoreLow + 0.8*scoreMid + 1*scoreHi;  // 0-1500 roughly
  // Subtle background color
  background(scoreLow/100, scoreMid/100, scoreHi/100);
  
  float genreIntensityMultiplier = 1.0;
  if (currGenre.equals("pop_rock")) {
    genreIntensityMultiplier = 1.1;
  } else if (currGenre.equals("ambient")) {
    genreIntensityMultiplier = 0.5;
  } else if (currGenre.equals("electronic")) {
    genreIntensityMultiplier = 1.2;
  }

  for(int i = 0; i < nbCubes; i++)
  {
    // Value of the frequency band
    float bandValue = fft.getBand(i);
    //println(bandValue);
    
    // The color is represented as: red for bass, green for mid sounds, and blue for highs.
    // The opacity is determined by the volume of the tape and the overall volume.
    cubes[i].display(scoreLow, scoreMid, scoreHi, bandValue*genreIntensityMultiplier, scoreGlobal);
  }
  
  // Multiply the height by this constant
  float dist = -25;
  float heightMult = 2;
  
  // adjust strings transparency and guitar variables
  if (!currInstrument.equals("guitar") && guitarLineTransparency > 0) {
    guitarLineTransparency -= 2.5;
  } else if (currInstrument.equals("guitar") && guitarLineTransparency < 100) { // guitar is playing again
    guitarLineTransparency = 100;
    guitarLineCurr = 0;
  }
  if (guitarLineCurr > -10000) {
    guitarLineCurr -= 25;
  }
  
  // For each band
  for(int i = 1; i < fft.specSize(); i++)
  {
    // Value of the frequency band, we multiply the bands further away so that they are more visible.
    float bandValue = fft.getBand(i)*(1 + (i/25)); //<>//

    //drawEdges(bandValue*heightMult, i, dist); // TODO try this out!
    
    // draw guitar strings
    if (guitarLineCurr <= dist*i && guitarLineTransparency > 0) {
      float transparency = 255-i*1.2;
      if (!currInstrument.equals("guitar")) {
        transparency = guitarLineTransparency;
      }
      stroke(100+scoreLow, 100+scoreMid, 100+scoreHi, transparency);
      strokeWeight(5);
      // left lines
      line(0, height*0.3, dist*(i-1), 
           0, height*0.3, dist*i);
      line(0, height*0.4, dist*(i-1), 
           0, height*0.4, dist*i);
      line(0, height/2, dist*(i-1), 
           0, height/2, dist*i);
      line(0, height*0.6, dist*(i-1), 
           0, height*0.6, dist*i);
      line(0, height*0.7, dist*(i-1), 
           0, height*0.7, dist*i);
      // right lines
      line(width, height*0.3, dist*(i-1), 
           width, height*0.3, dist*i);
      line(width, height*0.4, dist*(i-1), 
           width, height*0.4, dist*i);
      line(width, height/2, dist*(i-1), 
           width, height/2, dist*i);
      line(width, height*0.6, dist*(i-1), 
           width, height*0.6, dist*i);
      line(width, height*0.7, dist*(i-1), 
           width, height*0.7, dist*i);
    }
  }
 
  // transparency for circles
  if (!currInstrument.equals("vocal") && vocalTransparency > 0) {
    vocalTransparency -= 0.025;
  } else if (currInstrument.equals("vocal") && vocalTransparency < 1) { // vocals are singing again
    vocalTransparency += 0.025;
  }
  // draw circles
  if (vocalTransparency > 0) {
    for(int i = 0; i < nCircles; i++) {
      circles[i].display(scoreLow, scoreMid, scoreHi, scoreGlobal, vocalTransparency);
    }
  }
  
  // Walls rectangles
  for(int i = 0; i < nbWalls; i++)
  {
    // We assign each wall a band, and we send it its strength.
    float intensity = fft.getBand(i%((int)(fft.specSize()*specHi)));
    walls[i].display(scoreLow, scoreMid, scoreHi, intensity, scoreGlobal, sameInstrumentSeconds);
  }
  
  // transparency for squares
  if (!currInstrument.equals("drums") && drumsTransparency > 0) {
    drumsTransparency -= 0.025;
  } else if (currInstrument.equals("drums") && drumsTransparency < 1) { // vocals are singing again
    drumsTransparency += 0.025;
  }
  // draw squares
  if (drumsTransparency > 0) {
    // left squares
    int displayM = (int)(nWallSquares * 0.2); // display only 20% of the squares
    for (int i = 0; i < nWallSquares; i++) {
      if (leftSquares[i].getDisplayTransparency() > 0) {
        leftSquares[i].display(scoreLow, scoreMid, scoreHi, scoreGlobal, drumsTransparency);
        leftSquares[i].setDisplayTransparency(leftSquares[i].getDisplayTransparency() - 0.05);
        if (leftSquares[i].getDisplayTransparency() < 0.05) {
          leftSquares[i].setTimeout((int)random(10, 40));
        }
        displayM -= 1;
      } else if (leftSquares[i].getTimeout() > 0) {
        leftSquares[i].reduceTimeout();
      } else if (random(0, 1) > 0.7 && displayM > 0) {
        leftSquares[i].setDisplayTransparency(1.0);
        leftSquares[i].display(scoreLow, scoreMid, scoreHi, scoreGlobal, drumsTransparency);
        leftSquares[i].setDisplayTransparency(0.95);
      }
    }
    // right squares
    displayM = (int)(nWallSquares * 0.2); // display only 20% of the squares
    for (int i = 0; i < nWallSquares; i++) {
      if (rightSquares[i].getDisplayTransparency() > 0) {
        rightSquares[i].display(scoreLow, scoreMid, scoreHi, scoreGlobal, drumsTransparency);
        rightSquares[i].setDisplayTransparency(rightSquares[i].getDisplayTransparency() - 0.05);
        if (rightSquares[i].getDisplayTransparency() < 0.05) {
          rightSquares[i].setTimeout((int)random(10, 40));
        }
        displayM -= 1;
      } else if (rightSquares[i].getTimeout() > 0) {
        rightSquares[i].reduceTimeout();
      } else if (random(0, 1) > 0.7 && displayM > 0) {
        rightSquares[i].setDisplayTransparency(1.0);
        rightSquares[i].display(scoreLow, scoreMid, scoreHi, scoreGlobal, drumsTransparency);
        rightSquares[i].setDisplayTransparency(0.95);
      }
    }
  }
  //videoExport.saveFrame();
  //saveFrame(); // TODO to probaj
}












void drawEdges(float bandValue, int i, float dist)
{
  // Distance between each line point, negative because on dimension z
  float halfDist = -dist/1.0;
  
  // Select the color according to the strengths of the different types of sounds
  fill(100+scoreLow, 100+scoreMid, 100+scoreHi, 255-i);
  noStroke();
  
  // lower left edge
  beginShape();
  vertex(0, height, dist*i+halfDist);
  vertex(0, height-(bandValue), dist*i);
  vertex(bandValue*0.2, height-(bandValue)*0.2, dist*i);
  vertex(bandValue, height, dist*i);
  endShape(CLOSE);
  
  // lower right edge
  beginShape();
  vertex(width, height, dist*i+halfDist);
  vertex(width, height-(bandValue), dist*i);
  vertex(width-bandValue*0.2, height-(bandValue)*0.2, dist*i);
  vertex(width-bandValue, height, dist*i);
  endShape(CLOSE);
  
  // top left edge
  beginShape();
  vertex(0, 0, dist*i+halfDist);
  vertex(0, (bandValue), dist*i);
  vertex(bandValue*0.2, (bandValue)*0.2, dist*i);
  vertex(bandValue, 0, dist*i);
  endShape(CLOSE);

  // top right edge
  beginShape();
  vertex(width, 0, dist*i+halfDist);
  vertex(width, (bandValue), dist*i);
  vertex(width-bandValue*0.2, (bandValue)*0.2, dist*i);
  vertex(width-bandValue, 0, dist*i);
  endShape(CLOSE);
}
