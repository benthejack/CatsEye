class SVGTile {

  int windowPosX;
  int windowPosY;

  PShape mySVG; // main SVG
  PShape [] children; // SVG layers

  PGraphics maskShape; // graphics - mask layer
  PGraphics maskedVector; // graphics - graphics/SVG layer
  PImage display; // final composition layer

  int childrenNum, patternResolution;

  float xPos, yPos, maskW, maskH, vectorImageHeight, vectorImageWidth, displayW, displayH, scale;

  SVGTile( PShape tSVG, float i_scale)
  {
    scale = i_scale;
    tSVG.scale(scale);
    this.maskW = 100;
    this.maskH = 100;
    this.patternResolution = 4; 
    this.mySVG = tSVG;
    this.mySVG.disableStyle();
    this.vectorImageWidth = tSVG.width*scale;
    this.vectorImageHeight = tSVG.height*scale;
    this.childrenNum = mySVG.getChildCount();
    this.children = new PShape[childrenNum];
    for (int i = 0; i<childrenNum; i++) {
      children[i] = mySVG.getChild(i);
    }

    windowPosX = (int)random(this.mySVG.width-103);
    windowPosY = (int)random(this.mySVG.height-103);
  }

  float getTileWidth() {
    return this.vectorImageWidth;
  }
  float getTileHeight() {
    return this.vectorImageHeight;
  }
  int getTileChildrenCount() {
    return this.childrenNum;
  }
  float getMaskWidth() {
    return this.maskW;
  }
  float getMaskHeight() {
    return this.maskH;
  }


  PImage drawTile () {

    color[]ttp = {};

    // vector image
    this.maskedVector = createGraphics( (int)(this.mySVG.width*scale), (int)(this.mySVG.height*scale), JAVA2D);
    this.maskedVector.beginDraw();
    this.maskedVector.smooth();
    for (int i = 0; i<=this.childrenNum-1; i++) {

      this.maskedVector.stroke(ttp[i]);
      this.maskedVector.strokeWeight(1);
      this.maskedVector.fill(ttp[i]);
      if (i==0) {
        this.maskedVector.strokeWeight(3);
        this.maskedVector.fill(ttp[0]);
      }
      if (i==6)this.maskedVector.noFill();

      this.children[i].scale(scale);
      this.maskedVector.shape(this.children[i], 0, 0);
    }
    maskedVector.endDraw();
    //    int windowPosX = (int)random(this.mySVG.width-103);
    //    int windowPosY = (int)random(this.mySVG.height-103);
    this.display = this.maskedVector.get();

    return this.display;
  }
  
}

