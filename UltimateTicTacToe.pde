color divBorder, usualBorder, playerOneC, playerTwoC, tieColor, unplayableColor, bgPOne, bgPTwo, mainMenuC;
boolean playerOnePlaying;
int areaNum, divInterval, baseSquareValue, tieValue, playableGrid, endWinner;
float areaWidth, areaHeight, delta, gameOverTime;
float GAME_OVER_END_TIME = 2;
int[] endGrid;
PVector[][] squarePos;
int[][] squareValue;

enum gameState {MAIN_MENU, GAME};
gameState currentGameState;

void setup(){
  size(990,990);
  currentGameState = gameState.MAIN_MENU;
  divInterval = 3;
  areaNum = 9;
  gameOverTime = 0;
  areaWidth = width / areaNum;
  areaHeight = height / areaNum;
  tieValue = -6;
  delta = 1/frameRate;
  mainMenuC = color(50,80,50);
  bgPOne = color(50,50,70);
  bgPTwo = color(70,50,50);
  divBorder = color(255,0,0);
  usualBorder = color(0,0,0);
  playerOneC = color(50,50,150);
  playerTwoC = color(150,50,50);
  tieColor = color(20,20,20);
  unplayableColor = color(80,0,0,80);
  
  playerOnePlaying = true;
  
  squarePos = new PVector[areaNum][areaNum];
  squareValue = new int[areaNum][areaNum];
  endGrid = new int[areaNum];
  baseSquareValue = -5;
  // make it so that instead of a base value of 0, each index has a base value of baseSquareValue.
  // this is useful for checking wins.
  initNewGame();
}

int compareAmount(int[] arr, int a, int b){
  int res = 0;
  for (int i = 0; i < arr.length; i++){
    res += arr[i] == a ? 1 : (arr[i] == b ? -1 : 0);
  }
  return res == 0 ? 0 : (res > 0 ? a : b);
}

int sum(int[] arr){
  int result = 0;
  for (int i = 0; i < arr.length; i++){
    result += arr[i];
  }
  return result;
}

int[] getSubArray(int[] arr, int start, int end, int step){
  int[] result = new int[end-start];
  for (int i = start; i < end; i+=step){
    result[i-start] = arr[i];
  }
  return result;
}

boolean checkArray4Value(int[] arr, int val){
  for (int i = 0; i < arr.length; i++) {
    if (arr[i] == val) {return true;}
  }
  return false;
}

int check4Win(int[] arr){
  int[] results = new int[areaNum - 1];
  for(int i = 0; i < divInterval; i++){
    results[i] = sum(getSubArray(arr, (i*3), (i*3)+3, 1));
    results[3+i] = sum(getSubArray(arr, i, i+7, 3));
  }
  results[6] = arr[0] + arr[4] + arr[8];
  results[7] = arr[2] + arr[4] + arr[6];
  
  if (checkArray4Value(results, 3)) {
    return 1;
  } else if (checkArray4Value(results,6)) {
    return 2;
  }
  return 0;
}

void initNewGame(){
  playableGrid = -1;
  endWinner = -1;
  for (int i = 0; i < areaNum; i++) {
    endGrid[i] = baseSquareValue;
    for (int j = 0; j < areaNum; j++) {
      squareValue[i][j] = baseSquareValue;
    }
  }
}

void drawUnplayable(){
  if (playableGrid == -1) {return;}
  for (int i = 0; i < areaNum; i++){
    if (i == playableGrid) {continue;}
    fill(unplayableColor);
    rect((i % 3) * areaWidth * 3, floor(i/3) * areaHeight * 3, areaWidth * 3, areaHeight * 3);
  }
}

void drawFinal(){
  if (endWinner != -1){
   color winnerColor = endWinner == 0 ? color(0,0,0) : (endWinner == 1 ? playerOneC : playerTwoC);
   fill(winnerColor);
   rect(0, 0, width, height);
   return;
  }
  
  for (int i = 0; i < endGrid.length; i++){
    if (endGrid[i] == baseSquareValue) {continue;}
    fill(endGrid[i] == tieValue ? tieColor : (endGrid[i] == 1 ? playerOneC : playerTwoC));
    rect((i % 3) * areaWidth * 3, floor(i/3) * areaHeight * 3, areaWidth * 3, areaHeight * 3);
  }
}

void drawGrid(){
 for (int i = 1; i <= areaNum; i++){
    stroke(i % divInterval != 0 ? usualBorder : divBorder);
    line(i * areaWidth, 0f, i * areaWidth, height);
    line(0f, i * areaHeight, width, i * areaHeight);
  }
}

void drawSquares(){
  color black = color(0,0,0);
  stroke(black);
  for (int i = 0; i < areaNum; i++){
    for (int j = 0; j < areaNum; j++){
      // checks if squareValue[i][j] is attributed, if it is, squarePos must be too. Else, skips iteration.
      if (squareValue[i][j] == baseSquareValue) {continue;} 
      fill(squareValue[i][j] == 1 ? playerOneC : playerTwoC);
      rect(squarePos[i][j].x * areaWidth, squarePos[i][j].y * areaHeight, areaWidth, areaHeight);
    }
  }
}

void mousePressed(){
  if (currentGameState != gameState.GAME) {return;}
  
  int xMousePos = floor(mouseX/areaWidth);
  int yMousePos = floor(mouseY/areaHeight);
  int gridCoord = floor(xMousePos/divInterval) + divInterval * floor(yMousePos/divInterval);
  int subGridCoord = xMousePos % divInterval + divInterval * (yMousePos % divInterval);
  
  // Check if player can place square. Same logic concerning squareValue and squarePos as before.
  boolean isSquareTaken = squareValue[gridCoord][subGridCoord] != baseSquareValue;
  boolean isGridClosed = endGrid[gridCoord] != baseSquareValue;
  boolean isGridUnplayable = gridCoord != playableGrid && playableGrid != -1;
  if (isSquareTaken || isGridClosed || isGridUnplayable) {return;}
  
  squarePos[gridCoord][subGridCoord] = new PVector(xMousePos, yMousePos);
  squareValue[gridCoord][subGridCoord] = playerOnePlaying ? 1 : 2;
  
  playerOnePlaying = !playerOnePlaying;
 
  int winner = check4Win(squareValue[gridCoord]);
  boolean isSubGridFull = !checkArray4Value(squareValue[gridCoord], baseSquareValue);
  if (winner != 0) {
    endGrid[gridCoord] = winner;
  } else if (isSubGridFull) {
    endGrid[gridCoord] = tieValue;
  }
  
  int finalWinner = check4Win(endGrid);
  boolean isEndGridFull = !checkArray4Value(endGrid, baseSquareValue);
  if (finalWinner != 0) {
    println("Player " + finalWinner + " won !");
    endWinner = finalWinner;
  } else if (isEndGridFull) {
   println("YOU TIED ??");
   int trueWinner = compareAmount(endGrid, 1, 2);
   if (trueWinner == 0){
     println("You managed a true tie... welp i'm in awe.");
     endWinner = 0;
    } else {
     println("Just kidding, player " + trueWinner + " won");
     endWinner = trueWinner;
    }
  }
  playableGrid = endGrid[subGridCoord] == baseSquareValue ? subGridCoord : -1;
}

void keyPressed(){
  switch (key) {
    case ' ': {
      currentGameState = gameState.GAME;
      break;
    }
  }
}

void draw(){
  
  switch (currentGameState) {
    
    case MAIN_MENU: {
      background(mainMenuC);
      String mainTitle = "Ultimate Tic Tac Toe !";
      String pressSpace = "Press space to start ;)";
      color white = color(255,255,255);
      fill(white);
      textSize(50);
      text(mainTitle, (width-textWidth(mainTitle))/2, height/4);
      textSize(25);
      text(pressSpace, (width-textWidth(pressSpace))/2, height/3);
      break;
    }
    
    case GAME: {
      background(playerOnePlaying ? bgPOne : bgPTwo);
      drawSquares();
      drawGrid();
      drawFinal();
      
      if (endWinner != -1) {
        println(gameOverTime);
        gameOverTime += delta;
        if (gameOverTime >= GAME_OVER_END_TIME) {
          gameOverTime = 0;
          initNewGame();
          currentGameState = gameState.MAIN_MENU;
        }
        return;
      } 
      
      drawUnplayable();
      break;
    }
  }
}
