TileExplorerGUI GUI;
TileGrid gridGenerator;

void setup(){
  
  size(1000,1000);
  
  GUI = new TileExplorerGUI(this);
  
}

void draw(){
 
  background(180);
  image(gridGenerator.getPreviewImage(), 0, 0);
  
}
