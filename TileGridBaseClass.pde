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

class TileGrid {

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
  protected PVector[] texCoords;

  protected boolean useMask;

  protected String renderMode = JAVA2D;


  //----------------------CONSTRUCTORS------------------------

  //Don't create a TileGrid directly, use a subclass (hexGrid, triGrid, squareGrid)
  protected TileGrid() {

    //default settings
    renderSize = new PVector(width, height);
    previewSize = new PVector(width, height);

    texCoords = new PVector[3];
    texCoords[0] = new PVector(0, 1);
    texCoords[1] = new PVector(1, 1);
    texCoords[2] = new PVector(1, 0);

    cellRadius = 100;
    previewImage = createGraphics(100, 100);
    ((PGraphics)previewImage).beginDraw();
    ((PGraphics)previewImage).background(0, 0);
    ((PGraphics)previewImage).endDraw();

    textureImage = createGraphics(100, 100);
    ((PGraphics)textureImage).beginDraw();
    ((PGraphics)textureImage).background(0, 0);
    ((PGraphics)textureImage).endDraw();
  }

  protected TileGrid(TileGrid i_toCopy) {

    //default settings
    renderSize = i_toCopy.getRenderSize();
    previewSize = i_toCopy.getPreviewSize();
    cellRadius = i_toCopy.getCellRadius();
    maskImage = i_toCopy.getMaskImage();
    useMask = i_toCopy.isUsingMask();
    missingOdds = i_toCopy.getMissingOdds();
    setTextureCoords(i_toCopy.getTextureCoords());
    renderMode = i_toCopy.getRenderMode();

    previewImage = createGraphics(100, 100);
    ((PGraphics)previewImage).beginDraw();
    ((PGraphics)previewImage).background(0, 0);
    ((PGraphics)previewImage).endDraw();

    textureImage = createGraphics(100, 100);
    ((PGraphics)textureImage).beginDraw();
    ((PGraphics)textureImage).background(0, 0);
    ((PGraphics)textureImage).endDraw();
  }  


  //----------------------------------SETTERS/GETTERS-----------------------------------------


  //----setters-----

  public void setTexture(PImage i_texture) {
    textureImage = i_texture.get();
  }

  public void setTextureCoords(PVector[] i_texCoords) {

    texCoords = new PVector[3];

    if(i_texCoords != null && i_texCoords[0] != null && i_texCoords[1] != null && i_texCoords[2] != null){
      texCoords[0] = i_texCoords[0].get();
      texCoords[1] = i_texCoords[1].get();
      texCoords[2] = i_texCoords[2].get();
    }
    
  } 

  public void setMask(PImage i_mask) {
    maskImage = i_mask.get();
  }

  public void setCellRadius(float i_cellRad) {
    cellRadius = i_cellRad;
    gridGenerated = false;
  }

  public void setRenderSize(PVector i_size) {
    renderSize = i_size.get();
    gridGenerated = false;
  }

  public void setMissingOdds(float i_odds) {
    missingOdds = i_odds;
  }

  public void saveImage(String i_path) {
    saveImage(i_path, ".png");
  }

  public void saveImage(String i_path, String i_fileSuffix) {

    if (!generated) {
      generate();
    }

    renderContext.save(i_path+i_fileSuffix);
  }

  public void useMask(boolean i_useMask) {
    useMask = i_useMask;
  }

  void setPreviewSize(PVector i_size) {
    previewSize = i_size;
  }

  /***     
   *      This changes between rendering modes. The options are JAVA2D and P2D 
   ***/
  public void setRenderMode(String i_mode) {
    renderMode = i_mode;
  }

  //-----getters-----

  public PImage getPrintImage() {
    return renderContext.get();
  }

  public PImage getPreviewImage() {  
    return previewImage;
  }

  public PImage getGridImage() {

    if (!gridGenerated) {
      generate(true);
      gridPreviewImage = gridContext.get();
      gridPreviewImage.resize(renderContext.width >= renderContext.height ? (int)previewSize.x : 0, renderContext.height > renderContext.width ? (int)previewSize.y : 0);
    } 

    return gridPreviewImage;
  }

  public PImage getUnitImage() {

    if (generated)
      return ngonGenerator.getUnitImage();
    else
      return createImage(1, 1, ARGB);
  }

  PVector getRenderSize() {
    return renderSize.get();
  }

  PVector getPreviewSize() {
    return previewSize.get();
  }

  public PVector[] getTextureCoords() {

    PVector[] copy = new PVector[3];
    copy[0] = texCoords[0].get();
    copy[1] = texCoords[1].get();
    copy[2] = texCoords[2].get();

    return copy;
  } 

  float getCellRadius() {
    return cellRadius;
  }

  PImage getMaskImage() {
    return maskImage;
  }  

  boolean isUsingMask() {
    return useMask;
  }

  float getMissingOdds() {
    return missingOdds;
  }

  String getRenderMode() {
    return renderMode;
  }



  //---------------------------------METHODS--------------------------------------
  public void generate() {
    generate(false);
  }

  public void generate(boolean i_outlines) {
    /*Implement this function in a subclass
     see the helper methods below*/
  }


  //-----------------HELPER METHODS FOR USE IN SUBLCLASS GENERATE() IMPLEMENTATIONS-------------------

  /***
   *     when implementing a new tilegrid subclass use this function to draw the ngongeneratior
   *     This function implements the mask and missingodds features and also takes care
   *     of only drawing outlines if an outline grid is wanted.
   ***/
  protected void drawNgonAt(float i_x, float i_y, PGraphics i_currentContext) {

    if (i_currentContext == gridContext) {
      ngonGenerator.drawOutlinesAt(i_x, i_y, i_currentContext);
    }
    else if (random(1) > missingOdds && !isMaskedAt(i_x, i_y)) {
      ngonGenerator.drawAt(i_x, i_y, i_currentContext);
    }
  }

  /***
   *     when implementing a new tilegrid subclass always call this at the very beginning 
   *     of the generate() function. It sets up and returns the correct drawing context.
   ***/
  protected PGraphics initGeneration(int cellSides, boolean i_outlines) {

    if (renderMode == JAVA2D)
      ngonGenerator = new Java2DNgonGenerator(cellSides, cellRadius, textureImage);
    else
      ngonGenerator = new P2DNgonGenerator(cellSides, cellRadius, textureImage, texCoords);   

    cellSize = new PVector(ngonGenerator.cellWidth(), ngonGenerator.cellHeight());

    if (i_outlines) {
      gridContext = createGraphics((int)renderSize.x, (int)renderSize.y, renderMode);
      gridContext.beginDraw();
      gridContext.background(0, 0);
      return gridContext;
    }
    else {
      renderContext = createGraphics((int)renderSize.x, (int)renderSize.y, renderMode);
      renderContext.beginDraw();
      renderContext.background(0, 0);
      return renderContext;
    }
  }

  /***
   *     when implementing a new tilegrid subclass always call this at the very end 
   *     of the generate() function. It correctly closes the correct drawing context
   *     and flags the tilegrid as generated. 
   ***/
  protected void completeGeneration(boolean i_outlines) {

    if (i_outlines) {
      gridContext.endDraw();
      gridGenerated = true;
    }
    else {
      renderContext.endDraw();
      generated = true;

      previewImage = renderContext.get();
      previewImage.resize(renderContext.width >= renderContext.height ? (int)previewSize.x : 0, renderContext.height > renderContext.width ? (int)previewSize.y : 0);
    }
  }

  /***
   *    this implements image masking, you need not use it in a subclass if you are using drawNgonAt.
   ***/
  protected boolean isMaskedAt(float i_x, float i_y) {

    if (!useMask || maskImage == null)
      return false;

    try {
      maskImage.loadPixels();

      float xMaskScaleFactor = maskImage.width/(renderContext.width+0.0);
      float yMaskScaleFactor = maskImage.height/(renderContext.height+0.0);

      int xMask = (int)(abs(i_x)*xMaskScaleFactor);
      int yMask = (int)(abs(i_y)*yMaskScaleFactor);
      int col = maskImage.pixels[yMask*maskImage.width + xMask]&255;

      return col > 128;
    }
    catch(ArrayIndexOutOfBoundsException e) {
      return false;
    }
  }
}

