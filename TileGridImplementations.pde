
/*---------------------------------------------------------------------------------------------
*
*    HexGrid
*    
*    Implementation of hexagonal tiling grid
*
*    Ben Jack 6/4/2014 
*
*---------------------------------------------------------------------------------------------*/

class HexGrid extends TileGrid{
 
  
 HexGrid(){
   super();
 }
 
 
 public void generate(boolean i_outlines){
   
      PGraphics currentContext = initGeneration(6, i_outlines);
      
      int cellsY = (int)(renderContext.height/cellSize.x+2);
      int cellsX = (int)(renderContext.width /cellSize.y+2);
    
      for (int i = 0; i < cellsX; ++i) {
        for (int j = 0; j < cellsY; ++j) {
        
          float centerX = (i-1)*(cellSize.x*2);
          if (j%2 == 1) centerX += cellSize.x;
    
          float centerY = (j-1)*(cellRadius+cellSize.y);
    
          drawNgonAt(centerX, centerY, currentContext);
          
        }
      }
    
      completeGeneration(i_outlines);
  }
  
}


/*---------------------------------------------------------------------------------------------
*
*    SquareGrid
*    
*    Implementation of square tiling grid
*
*    Ben Jack 6/4/2014 
*
*---------------------------------------------------------------------------------------------*/

class SquareGrid extends TileGrid{
  
 SquareGrid(){
   super();
 }
 
 public void generate(boolean i_outlines){
 
      PGraphics currentContext = initGeneration(4, i_outlines);
    
      int cellsY = (int)(renderContext.height/cellSize.x+2);
      int cellsX = (int)(renderContext.width /cellSize.y+2);
    
      for (int i = 0; i < cellsX; ++i) {
        for (int j = 0; j < cellsY; ++j) {
    
          float centerX = (i-1)*(cellSize.x*2);
          float centerY = (j-1)*(cellSize.x*2);
    
          drawNgonAt(centerX, centerY, currentContext);
        }
      }
    
      completeGeneration(i_outlines);
  
    }
  
}

/*---------------------------------------------------------------------------------------------
*
*    triGrid
*    
*    Implementation of triagonal tiling grid
*
*    Ben Jack 6/4/2014 
*
*---------------------------------------------------------------------------------------------*/

class TriGrid extends TileGrid{
 
  
 TriGrid(){
   super();
 }
 
 public void generate(boolean i_outlines){
   
      PGraphics currentContext = initGeneration(3, i_outlines);
    
      float triHeight  = cellSize.x + cellRadius;
      float cellWidth  = cellSize.x;
      float cellHeight = cellSize.y;
    
      int cellsY = (int)(renderContext.height/triHeight+2);
      int cellsX = (int)(renderContext.width /triHeight+2);
    
      for (int flip = 0; flip < 2; ++flip) {
        for (int i = -1; i < cellsX; ++i) {
          for (int j = -1; j < cellsY; ++j) {
    
            currentContext.pushMatrix();
    
            float centerY = j*(cellHeight*2) + (i%2 == 0? cellHeight : 0) + (flip%2==1?cellHeight:0);
            float centerX = (i*triHeight + (flip%2==1 ? cellWidth : 0))*(flip%2==1?1:-1);
    
            if (flip % 2 == 0) {
              currentContext.scale(-1, 1);
            }
    
            drawNgonAt(centerX, centerY, currentContext);
    
            currentContext.popMatrix();
          }
        }
      }
    
      completeGeneration(i_outlines);
  }
  
}
