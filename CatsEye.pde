TileGrid gridGenerator;


void setup(){
  
  size(1000,1000, P2D);
  
  gridGenerator = new HexGrid();
  setupTileExplorerGUI();
  
}

void draw(){
 
  background(180);
  drawGui();
  
}