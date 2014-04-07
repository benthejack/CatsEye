/*---------------------------------------------------------------------------------------------
*
*    TileGrid
*    
*    Base class for various grid generators (hexGrid, triGrid, squareGrid etc..)
*    Do not instantiate this class directly, rather use one of the subclasses that have the generate()
*    function implemented.
*
*    Ben Jack 6/4/2014 
*
*---------------------------------------------------------------------------------------------*/
 
class TileGrid{
  
  //----------------- CLASS VARIABLES---------------------
  protected PGraphics renderContext, gridContext;
  protected PImage previewImage, gridPreviewImage;
  protected PImage textureImage; 
  protected PImage maskImage;

  protected NGonGenerator ngonGenerator;
  
  protected boolean generated = false;
  protected boolean gridGenerated = false;
  protected float missingOdds = 0; //a number between 0 and 1 that represents a random chance a tile will be missing 
  protected float cellRadius;
  protected PVector cellSize;
  protected PVector renderSize, previewSize;
  
  protected String renderMode;
  
  
  //----------------------METHODS------------------------
  
  //Don't create a TileGrid directly, use a subclass (hexGrid, triGrid, squareGrid)
  protected TileGrid(){
    
    //default settings
    renderSize = new PVector(width, height);
    cellRadius = 100;
    previewImage = createGraphics(100,100);
    ((PGraphics)previewImage).beginDraw();
    ((PGraphics)previewImage).background(0,0);
    ((PGraphics)previewImage).endDraw();
    
    textureImage = createGraphics(100,100);
    ((PGraphics)textureImage).beginDraw();
    ((PGraphics)textureImage).background(0,0);
    ((PGraphics)textureImage).endDraw();

  }
  
  public void setTexture(PImage i_texture){
    textureImage = i_texture.get(); 
  }
  
  public void setMask(PImage i_mask){
    maskImage = i_mask.get();
  }
  
  public void setCellRadius(float i_cellRad){
    cellRadius = i_cellRad;
  }
  
  public void setRenderSize(PVector i_size){
    renderSize = i_size;
  }
  
  public void setMissingOdds(int i_odds){
    missingOdds = i_odds;
  }
  
  public void saveImage(String i_path){
    
    if(!generated){
      generate();
    }
    
    renderContext.save(i_path);
  }
  
  
  /***     
  *      This currently does nothing. It may be used in the future. 
  ***/
  public void setRenderMode(String i_mode){
    renderMode = i_mode;
  }
  
  
  public PImage getPrintImage(){
    return renderContext.get();
  }
  
  
  void setPreviewSize(PVector i_size){
    previewSize = i_size;
    previewImage = renderContext.get();
    previewImage.resize((int)i_size.x, (int)i_size.y);
  }
  
  public PImage getPreviewImage(){

    return previewImage;
  }
  
  public PImage getGridImage(){
     
    if(!gridGenerated){
       generate(true);
       gridPreviewImage = gridContext.get();
       gridPreviewImage.resize((int)previewSize.x, (int)previewSize.y);
     } 
     
     return gridPreviewImage;
  }
  
  public PImage getUnitImage(){
     return ngonGenerator.getUnitImage(); 
  }
  
  public void generate(){
    generate(false);
  }
  
  public void generate(boolean i_outlines){
    /*Implement this function in a subclass
    If creating subclasses it is up to you to
    implement features such as missingOdds*/
  }
  
  
  //-----------------HELPER FUNCTIONS FOR USE IN SUBLCLASS GENERATE() IMPLEMENTATIONS-------------------
 
  /***
  *     when implementing a new tilegrid subclass use this function to draw the ngongeneratior
  *     This function implements the mask and missingodds features and also takes care
  *     of only drawing outlines if an outline grid is wanted.
  ***/
  protected void drawNgonAt(float i_x, float i_y, PGraphics i_currentContext){
   
   if(i_currentContext == gridContext){
       ngonGenerator.drawOutlinesAt(i_x, i_y, i_currentContext);
   }else if (random(1) > missingOdds && !isMaskedAt(i_x, i_y)){
       ngonGenerator.drawAt(i_x, i_y, i_currentContext); 
   }
   
  }
  
  /***
  *     when implementing a new tilegrid subclass always call this at the very beginning 
  *     of the generate() function. It sets up and returns the correct drawing context.
  ***/
  protected PGraphics initGeneration(int cellSides, boolean i_outlines){
    
    ngonGenerator = new NGonGenerator(cellSides, cellRadius, textureImage);
    cellSize = new PVector(ngonGenerator.cellWidth(),  ngonGenerator.cellHeight());
    
    if(i_outlines){
      gridContext = createGraphics((int)renderSize.x, (int)renderSize.y);
      gridContext.beginDraw();
      gridContext.background(0,0);
      return gridContext;
    }
    else{
      renderContext = createGraphics((int)renderSize.x, (int)renderSize.y);
      renderContext.beginDraw();
      renderContext.background(0,0);
      return renderContext;  
    }
  }
  
  /***
  *     when implementing a new tilegrid subclass always call this at the very end 
  *     of the generate() function. It correctly closes the correct drawing context
  *     and flags the tilegrid as generated. 
  ***/
  protected void completeGeneration(boolean i_outlines){
    
    if(i_outlines){
      gridContext.endDraw();
      gridGenerated = true;
    }
    else{
      renderContext.endDraw();
      generated = true;
      
      previewImage = renderContext.get();
      previewImage.resize((int)renderSize.x, (int)renderSize.y);
    }
    
  }
  
  /***
  *    this implements image masking, you need not use it in a subclass if you are using drawNgonAt.
  ***/
  protected boolean isMaskedAt(float i_x, float i_y){
    
    if(maskImage == null)
      return false;
    
    try {
      maskImage.loadPixels();
      
      float xMaskScaleFactor = maskImage.width/(renderContext.width+0.0);
      float yMaskScaleFactor = maskImage.height/(renderContext.height+0.0);
      
      int xMask = (int)(abs(i_x)*xMaskScaleFactor);
      int yMask = (int)(abs(i_y)*yMaskScaleFactor);
      int col = maskImage.pixels[yMask*maskImage.width + xMask]&255;
      
      return col > 128;
    }catch(ArrayIndexOutOfBoundsException e){
      return false; 
    }

  }
  

  
}


