/* 
Langton's Ant
Written by Jimmie Rodgers 9/16/15

This is a simple two dimentional turring machine.
The "ant" will move left if the square is empty, or
right if the square is full. The now vacant square
will be toggled on/off. This version allows you
to set different colors for the ants, and they will
leave a colored space behind.

I was inspired to write this from a Numberphile video:
https://www.youtube.com/watch?v=NWBToaXK5T0

You can check the wiki page here:
https://en.wikipedia.org/wiki/Langton%27s_ant

Change varialbes below to play around with settings. Once running
the following keys work:

space = advances generationJump generations
a     = toggles autoAdvance
s     = saves the current frame
v     = fills in all blank space till voidThreshold is met
n     = new grid, clears the grid of all colors, but leave the ants
r     = randomizes ant coordinates and directions, does not clear the grid
+     = multiplies the generationJump by 10
-     = divides the generationJump by 10

*/

// Set the following variables to change program settings.
int xSize           = 960;  // number of blocks wide
int ySize           = 540;  // number of blocks tall
int blockSize       = 2;    // size of each block
boolean worldWrap   = true; // whether the ants wrap around or just "bounce" off the walls
int numAnts         = 7;    // number of ants you want
long generationJump = 100;  // the number of generations that will jump between frames
                            // set it to 1 to show every one, or very high for crazy images at high res
                            // high generationJump can take significant processing time

boolean autoAdvance    = true;  // whether the frame advances automatically. Otherwise you have to press space
boolean randomColors   = false; // random colors[] will be chosen, overides sequenceColors
boolean sequenceColors = true;  // colors will be assigned sequentially (ROYGBIV is first in the set)
boolean showGrid       = false; // better for smaller resolutions and large block sizes 
boolean border         = false; // creates a one block wide border around the image
boolean fillVoid       = false; // keeps running generations till there is no space larger than voidThreshold
int voidThreshold      = 100;   // maximum number of sequential blank spaces before it runs a generation
                                // if you set voidThreshold too low, it will never stop running for large grids

boolean autoSave = false; // will auto save each frame in the sketch directory
String fileName  = "ants_#####.jpeg"; // the ##s will be replaced by frameCount
int maxFrames    = 10000; // these can get big for larger resolutions, so be careful

// colors are all in RGB hex values
int[] colors = {
  #FF0000, #FFA500, #FFFF00, #008000, #0000FF, #4B0082, #8A2BE2, // rainbow colors
  #FF1493, #00FFFF, #008080, #FF00FF, #7FFF00, #FFD700, #00BFFF  // pink, cyan, teal, magenta, chartreuse, gold, sky blue  
};

int fillColor   = #FFFFFF;     // default fill the ants leave behind
int backColor   = #000000;     // default background color
int defAntColor = #FF0000;     // default ant color, only used if neither random or sequential is selected above
int background  = #909090;     // boarder around the grid if enabled
int gridColor   = #202020;     // the grid line color if enabled

// these set the ant directions, don't mess with them.
final byte up    = 0;
final byte right = 1;
final byte down  = 2;
final byte left  = 3;

// creates the grid and the ants
int grid[][] = new int[xSize][ySize];
Ant[] ants = new Ant[numAnts];

void settings(){
  // settings() is new in 3.0+, but this sets the frame size depending on whether you want a border
  if (border) size((xSize*blockSize + 2*blockSize), (ySize*blockSize + 2*blockSize));
  else size((xSize*blockSize), (ySize*blockSize));
}

void setup() {
  zeroGrid();
  showGrid();
  // actually creates the ants
  for (int i = 0; i < numAnts; i++) {
    int tempColor = int(random(colors.length));
    if (randomColors) ants[i] = new Ant(colors[tempColor], #FFFFFF);
    else if (sequenceColors) ants[i] = new Ant(colors[i], #FFFFFF);
    else ants[i] = new Ant();
  }
  if (fillVoid) intoTheVoid(); // fills the initial frame up if that option is selected
}

void draw() {
  clear();
  background(background);
  if (autoAdvance) advanceGenerations();
  showGrid(); 
  for (int i = 0; i < numAnts; i++) ants[i].show(); // I have no idea why it wants this here instead of in showGrid()
  if (autoSave) if (frameCount <= maxFrames) saveFrame(fileName);
}

void keyPressed() {
  if (key == 's') saveFrame(fileName);
  if (key == ' ') advanceGenerations();
  if (key == 'a') autoAdvance = !autoAdvance;
  if (key == 'n') zeroGrid();
  if (key == '+') generationJump *= 10;
  if (key == '-') {
    generationJump /= 10;
    if (generationJump < 1) generationJump = 1;
  }
  if (key == 'v') intoTheVoid();
  if (key == 'r') for (int i = 0; i < numAnts; i++) ants[i].randomDirection();
}  

// will advance all ants generationJump generations of movement
void advanceGenerations(){
  for (int count = 0; count < generationJump; count++) {
    for (int i = 0; i < numAnts; i++) {
      ants[i].move();
    }
  }
}

// this will keep calling advanceGenerations() till there are fewer than voidThreshold blank spaces
void intoTheVoid(){
  int count = 0;
  while (true){
    for (int x = 0; x < xSize; x++) {
      for (int y = 0; y < ySize; y++) {
        if (grid[x][y] == 0) count++;
        else if (grid[x][y] > 0) count = 0;
        if (count > voidThreshold) {
          advanceGenerations();
          count = 0;
         }
      }
      count = 0;
    }
    if (count < voidThreshold) break;
    else count = 0;
  }
}

// displays the grid
void showGrid() {
  if (showGrid) stroke(gridColor);
  else noStroke();
  for (int x = 0; x < xSize; x++) {
    for (int y = 0; y < ySize; y++) {
      if (grid[x][y] == 0) fill(backColor); 
      else fill(grid[x][y]);
      if (border) rect(x*blockSize + blockSize, y*blockSize + blockSize, blockSize, blockSize);
      else rect(x*blockSize, y*blockSize, blockSize, blockSize);
    }
  }
}

// clears all colored spaces, but does nothing to the ants
void zeroGrid() {
  for (int x = 0; x < xSize; x++)
    for (int y = 0; y < ySize; y++)
      grid[x][y] = 0;
}

// the Ant will follow the basic Lanton's Ant rules when asked nicely.
class Ant {
  int antX;        // current X location of the Ant
  int antY;        // current Y location of the Ant
  int antDirection;// where the Ant is currently looking, though maybe not what
  int antColor;    // the color the Ant displays when being shown
  int antFill;     // the color the Ant leave behind in a blank space
  
  // a default ant starts at a random position and direction
  Ant () {
    antColor = defAntColor;
    antFill = fillColor;
    antX = int(random(xSize));
    antY = int(random(ySize));
    antDirection = int(random(4));
  }

  // 3 ints, and you've set location and direction
  Ant (int tempX, int tempY, int dirTemp) {
    antColor = defAntColor;
    antFill = fillColor;
    antX = tempX;
    antY = tempY;
    antDirection = dirTemp;
  }
  
  // 2 ints, and you've set what color the Ant fills in, and what color the Ant is when shown
  Ant (int tempFillColor, int tempAntColor) {
    antColor = tempAntColor;
    antFill = tempFillColor;
    antX = int(random(xSize));
    antY = int(random(ySize));
    antDirection = int(random(4));
  }  

  // the Ant will move according to the Langton's Ant rules.
  void move() {
    if (antDirection == up) {
      if (grid[antX][antY] == 0) {
        antDirection = left;
        grid[antX][antY] = antFill;
        antX--;
      } else {
        antDirection = right;
        grid[antX][antY] = 0;
        antX++;
      }
    } else if (antDirection == right) {
      if (grid[antX][antY] == 0) {
        antDirection = up;
        grid[antX][antY] = antFill;
        antY--;
      } else {
        antDirection = down;
        grid[antX][antY] = 0;
        antY++;
      }
    } else if (antDirection == down) {
      if (grid[antX][antY] == 0) {
        antDirection = right;
        grid[antX][antY] = antFill;
        antX++;
      } else {
        antDirection = left;
        grid[antX][antY] = 0;
        antX--;
      }
    } else if (antDirection == left) {
      if (grid[antX][antY] == 0) {
        antDirection = down;
        grid[antX][antY] = antFill;
        antY++;
      } else {
        antDirection = up;
        grid[antX][antY] = 0;
        antY--;
      }
    }

    // if worldWrap is enabled, the Ant will pop over to the other side. Otherwise it will turn about-face when hitting a wall
    if (worldWrap) {
      if (antX < 0) antX = xSize-1;
      else if (antX > xSize-1) antX = 0;
      if (antY < 0) antY = ySize-1;
      else if (antY > ySize-1) antY = 0;
    } else {  
      if (antX < 0) {
        antX = 0;
        antDirection = right;
      } else if (antX > xSize-1) {
        antX = xSize-1;
        antDirection = left ;
      }
      if (antY < 0) {
        antY = 0;
        antDirection = down;
      } else if (antY > ySize-1) {
        antY = ySize-1;
        antDirection = up;
      }
    }
  }
  
  // shows the current location of the Ant
  void show() {
    fill(antColor);
    if (border) ellipse(antX*blockSize + blockSize*1.5, antY*blockSize + blockSize*1.5, blockSize, blockSize);
    else ellipse(antX*blockSize + blockSize*0.5, antY*blockSize + blockSize*0.5, blockSize, blockSize);
  }
  
  // moves the Ant to a random location and direction. It may be disoriented, but it's an Ant, so I doubt it cares too much.
  void randomDirection(){
    antX = int(random(xSize));
    antY = int(random(ySize));
    antDirection = int(random(4));
  }
}