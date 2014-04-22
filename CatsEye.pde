TileGrid gridGenerator;
VoronoiDelaunayGrid irregularGridGenerator;

void setup(){
  
  size(1000,1000, P2D);
  gridGenerator = new HexGrid();
  irregularGridGenerator = new VoronoiDelaunayGrid();
  

  setupTileExplorerGUI();
  
}

void draw(){
 
  background(180);
  drawGui();
  //image(vGrid.getPreviewImage(), 0, 0);
//  image(vGrid.getGridImage(), 0, 0);

}
