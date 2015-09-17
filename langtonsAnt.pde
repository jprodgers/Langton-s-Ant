/* 
Langton's Ant

This is a simple two dimentional turring machine.
The "ant" will move left if the square is empty, or
right if the square is full. The now vacant square
will be toggled on/off. This version allows you
to set different colors for the ants, and they will
leave a colored space or a default color.

I was inspired to write this from a Numberphile video:
https://www.youtube.com/watch?v=NWBToaXK5T0

You can check the wiki page here:
https://en.wikipedia.org/wiki/Langton%27s_ant

Simply change the size of the grid and the number of ants
you would like to play around a bit.

Written by Jimmie Rodgers 9/16/15
Released under Public Domain

*/

int xSize = 100;             // number of blocks wide
int ySize = 50;              // number of blocks tall
int blockSize = 20;          // size of each block
boolean worldWrap = true;    // whether the ants wrap around
                             // or just "bounce" off the walls
int numAnts = 100;           // number of ants you want
int grid[][] = new int[xSize][ySize];
Ant[] ants = new Ant[numAnts];

boolean randomColors = true;

int[] colors = {
  #DF0101, #FF8000, #FFFF00, #04B404, #0101DF, #BF00FF
};

// colors are all in RGB hex values
int fillColor = #FFFFFF;     // the fill the ants leave behind
int backColor = #000000;     // default background color
int defAntColor = #FF0000;   // default ant color
int background = #909090;    // the boarder around the grid
int gridColor = #909090;     // the grid line color

// these all help with setting the ant directions
final byte up = 0;
final byte right = 1;
final byte down = 2;
final byte left = 3;

void setup() {
  size((xSize*blockSize + 2*blockSize), (ySize*blockSize + 2*blockSize));
  zeroGrid();
  showGrid();
  for (int i = 0; i < numAnts; i++) {
    int tempColor = int(random(colors.length));
    if (randomColors) ants[i] = new Ant(colors[tempColor], #FFFFFF);
    else ants[i] = new Ant();
  }
}

void draw() {
  clear();
  background(background);
  showGrid();
  for (int i = 0; i < numAnts; i++) {
    ants[i].show();
    ants[i].move();
  }
}

void showGrid() {
  stroke(gridColor);
  for (int x = 0; x < xSize; x++) {
    for (int y = 0; y < ySize; y++) {
      if (grid[x][y] == 0) fill(backColor); 
      else fill(grid[x][y]);
      rect(x*blockSize + blockSize, y*blockSize + blockSize, blockSize, blockSize);
    }
  }
}

void zeroGrid() {
  for (int x = 0; x < xSize; x++)
    for (int y = 0; y < ySize; y++)
      grid[x][y] = 0;
}

class Ant {
  int antX;
  int antY;
  int antDirection; 
  int antColor;
  int antFill;
  
  // a default ant starts at a random position and direction
  Ant () {
    antColor = defAntColor;
    antFill = fillColor;
    antX = int(random(xSize));
    antY = int(random(ySize));
    antDirection = int(random(4));
  }

  Ant (int tempX, int tempY, int dirTemp) {
    antColor = defAntColor;
    antFill = fillColor;
    antX = tempX;
    antY = tempY;
    antDirection = dirTemp;
  }

  Ant (int tempFillColor, int tempAntColor) {
    antColor = tempAntColor;
    antFill = tempFillColor;
    antX = int(random(xSize));
    antY = int(random(ySize));
    antDirection = int(random(4));
  }  

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

  void show() {
    fill(antColor);
    ellipse(antX*blockSize + blockSize*1.5, antY*blockSize + blockSize*1.5, blockSize, blockSize);
  }
}
