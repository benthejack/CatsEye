  import java.awt.Frame;
  import java.awt.BorderLayout;
  import controlP5.*;
  
  
  private ControlP5 cp5;
  private ImageSelectionWindow imageWindow;
  
  RadioButton gridTypeButton;
  Textfield printWidthField, printHeightField;
  Button maskImageBtn;
  Group globalControls, gridControls;
  
  private int printWidthValue = 1000;
  private int printHeightValue = 1000;
  private float cellRadius = 100;
  private boolean drawGrid = false;
  
  private PImage textureImage, maskImage, backgroundImage;
  
  
  
  
  
  void setupTileExplorerGUI() {
    cp5 = new ControlP5(this);
  
    gridControlGroup();
    globalControlGroup();
  
    imageWindow = addImageWindow("patternImage", 600, 600);
    
    backgroundImage = createCheckerBackground();
  }
  
  
  
  
  
  void drawGui(){
    image(backgroundImage, 0, 0);
    PImage patternImage = gridGenerator.getPreviewImage();
    image(patternImage, (width-patternImage.width)/2,  (height-patternImage.height)/2);
   
    if(drawGrid){
        image(gridGenerator.getGridImage(), 0, 0);
    }
   
  }
  
  
  
  
  
  
  void generate(int guiJunk) { 
    printWidthField.submit();
    printHeightField.submit();
    println();
    gridGenerator.setTexture(imageWindow.getCropSection());
    gridGenerator.setCellRadius(cellRadius);
  
    gridGenerator.generate();
  }
  
  
  
  
  void saveImage(int guiJunk) { 
  
    String[] months = {
      "january", "febuary", "march", "april", "may", "june", "july", "august", "september", "october", "november", "december"
    };
    String path = "images/"+year()+"/"+months[month()-1]+"/"+day()+"/"+hour()+"_"+minute()+"_"+second();
    gridGenerator.saveImage(path);
  }  
  
  
  
  void changeGridType(int i_type) {
  
    switch(i_type) {
    case 1:
      gridGenerator = new HexGrid();
      break;
  
    case 2:
      gridGenerator = new TriGrid();
      break;
  
    case 3:
      gridGenerator = new SquareGrid();
      break;
  
    default:
      gridGenerator = new HexGrid();
      break;
    }
  }
  
  
  
  
  //Creates secondary GUI window---------------------------------------------------------
  ImageSelectionWindow addImageWindow(String theName, int theWidth, int theHeight) {
    Frame f = new Frame(theName);
    ImageSelectionWindow p = new ImageSelectionWindow(this, theWidth, theHeight);
    f.add(p);
    p.init();
    f.setTitle(theName);
    f.setSize(p.width, p.height);
    f.setLocation(0, 0);
    f.setResizable(false);
    f.setVisible(true);
    return p;
  }
  
  
  
  
  void loadMask(int val) {
    selectInput("Select an image", "maskSelected");
  }
  
  void maskSelected(File selection) {
    if (selection == null) {
      println("Window was closed or the user hit cancel.");
    } 
    else {
      maskImage = loadImage(selection.getAbsolutePath());
      gridGenerator.setMask(maskImage);
    }
  
    PImage tempImg = maskImage.get();
    if (tempImg.width > tempImg.height)
      tempImg.resize(120, 0);
    else
      tempImg.resize(0, 120);
  
    maskImageBtn.setImage(tempImg);
  }  
  
  
  
  
  void useMask(int i_useMask){
   gridGenerator.useMask(i_useMask==1);
  }
  
  
  
  
  void missingOdds(float i_odds){
   gridGenerator.setMissingOdds(i_odds); 
  }
  
  
  
  
  void printWidth(String i_value) {
    printWidthValue = Integer.parseInt(i_value);
      println(printWidthValue);
  
    gridGenerator.setRenderSize(new PVector(printWidthValue, printHeightValue));
  }
  
  
  
  void printHeight(String i_value) {
    printHeightValue = Integer.parseInt(i_value);
    gridGenerator.setRenderSize(new PVector(printWidthValue, printHeightValue));
  }
  
  
  
  // This function draws the grey and white checker background to a PGraphics object
  PImage createCheckerBackground(){
   
    int checkerCount = 100;
    PGraphics checkerGfx = createGraphics(width, height);
    
    float boxWidth = width/(checkerCount+0.0);
    
    checkerGfx.beginDraw();
    checkerGfx.background(255);
    checkerGfx.fill(200);
    checkerGfx.noStroke();
    
    for(int i = 0; i < checkerCount; ++i){
      for(int j = 0; j < checkerCount; ++j){
       if((i % 2 == 0 && j % 2 == 0) || (i % 2 == 1 && j % 2 == 1)){
         checkerGfx.rect(i*boxWidth, j*boxWidth, boxWidth, boxWidth);
       }
      }
    }
    
    checkerGfx.endDraw();  
    
    return checkerGfx;
  }
  
  
  
  //**************************************ACTUAL GUI CREATION***************************************
  
  void globalControlGroup() {
        
    cp5.addToggle("drawGrid")
      .setPosition(1000-40, 20)
        .setSize(20, 20);
  
    globalControls = cp5.addGroup("globalControls")
      .setPosition(0, 10)
        .setBackgroundHeight(210)
          .setWidth(160)
            .setBackgroundColor(color(0, 90));
  
    printWidthField = cp5.addTextfield("printWidth")
      .setPosition(20, 20)
        .setSize(50, 14)
          .setValue("1000")
            .setAutoClear(false)
              .setGroup(globalControls)
                .setInputFilter(ControlP5.INTEGER);
  
    printHeightField = cp5.addTextfield("printHeight")
      .setPosition(90, 20)
        .setSize(50, 14)
          .setValue("1000")
            .setAutoClear(false)
              .setGroup(globalControls)
                .setInputFilter(ControlP5.INTEGER);  
  
    gridTypeButton = cp5.addRadioButton("changeGridType")
      .setPosition(20, 80)
        .setSize(10, 10)
          .setItemsPerRow(3)
            .setSpacingColumn(30)
              .setSpacingRow(20)
                .addItem("Hex", 1)
                  .addItem("Tri", 2)
                    .addItem("Square", 3)
                      .setGroup(globalControls);
  
    gridTypeButton.activate(0);
  
    cp5.addNumberbox("cellRadius")
      .setPosition(20, 140)
        .setSize(50, 14)
          .setScrollSensitivity(1.1)
            .setValue(100)
              .setRange(10, 5000)
                .setGroup(globalControls);
  
    cp5.addNumberbox("svgScale")
      .setPosition(90, 140)
        .setSize(50, 14)
          .setRange(0.1, 50)
            .setMultiplier(0.1)
              .setScrollSensitivity(0.1)
                .setValue(1.0)
                  .setGroup(globalControls);
  
    cp5.addButton("generate")
      .setPosition(20, 180)
        .setSize(50, 20)
          .setGroup(globalControls);
  
    cp5.addButton("saveImage")
      .setPosition(90, 180)
        .setSize(50, 20)
          .setGroup(globalControls);
  }
  
  
  //GRID GUI SETUP
  void gridControlGroup() {
  
    gridControls = cp5.addGroup("gridControls")
      .setPosition(0, 230)
        .setBackgroundHeight(250)
          .setWidth(160)
            .setBackgroundColor(color(0, 90));  
  
  
    cp5.addSlider("missingOdds")
      .setPosition(20, 20)
        .setSize(80, 20)
          .setRange(0, 1)
            .setGroup(gridControls);
  
  
    cp5.addToggle("useMask")
      .setPosition(20, 60)
        .setSize(20, 20)
          .setGroup(gridControls);
  
  
    maskImageBtn = cp5.addButton("loadMask")
      .setPosition(20, 100)
        .setSize(120, 120)
          .setGroup(gridControls);
  }

