class Java2DNgonGenerator extends NGonGenerator {

  private PatternTriangle unit;
  private PMatrix2D[] transforms;

  Java2DNgonGenerator(int i_segments, float i_radius, PImage i_gfx) 
  {
    super(i_segments, i_radius);
    float theta = TWO_PI/i_segments;

    PImage canvas = new PImage((int)i_radius*2, (int)i_radius*2, ARGB);

    PVector temp1 = new PVector(i_radius, 0, 0);
    PVector temp2 = new PVector(cos(theta)*i_radius, sin(theta)*i_radius, 0);

    temp1.lerp(temp2, 0.5);

    PVector f1 = new PVector(0, 0, 0);
    PVector f2 = new PVector(i_radius, 0, 0);
    PVector f3 = temp1.get();

    unit = new PatternTriangle(f1, f2, f3, i_gfx);  
    unitWidth = PVector.dist(f1, f3);
    unitHeight = PVector.dist(f2, f3); 

    transforms = new PMatrix2D[i_segments*2];
    PMatrix2D flip = new PMatrix2D();
    flip.scale(-1, 0);

    for (int i = 0; i < i_segments*2; ++i) {
      PMatrix2D newMat = new PMatrix2D();

      if (i%2 == 1) {
        newMat.scale(-1, 1);
        newMat.rotate(-PI-theta);
      }
      newMat.rotate(theta/2);
      newMat.rotate((i/2)*theta);
      transforms[i] = newMat;
    }
  }

  public void drawAt(float i_x, float i_y, PGraphics renderContext) {

    for (int i = 0; i < sides*2; ++i) {
      renderContext.pushMatrix();
      renderContext.translate(i_x, i_y);

      //hack to fix bizarre tearing on the screen diagonal when creating a square grid
      if (sides == 4)
        renderContext.rotate(0.0001);
      //-------------------------------------------------------------------------------

      renderContext.applyMatrix(transforms[i]);
      unit.draw(renderContext);
      renderContext.popMatrix();
    }
  }

  public void drawOutlinesAt(float i_x, float i_y, PGraphics renderContext) {

    for (int i = 0; i < sides*2; ++i) {
      renderContext.pushMatrix();
      renderContext.translate(i_x, i_y);
      renderContext.applyMatrix(transforms[i]);
      unit.drawOutline(renderContext);
      renderContext.popMatrix();
    }
  }

  public PImage getUnitImage() {
    return unit.getImage();
  }
}






class P2DNgonGenerator extends NGonGenerator {

  private PShape polygon;
  private PShape outlines;

  P2DNgonGenerator(int i_segments, float i_radius, PImage i_gfx) {
    super(i_segments, i_radius);
    
    PVector[] defaultTexCoords = {
      new PVector(0, 1), new PVector(1, 1), new PVector(1, 0)
    };
    init(i_gfx, defaultTexCoords);
  }

  P2DNgonGenerator(int i_segments, float i_radius, PImage i_gfx, PVector[] i_texCoords) {
    super(i_segments, i_radius);

    init(i_gfx, i_texCoords);
  }

  void init(PImage i_gfx, PVector[] i_texCoords) 
  {
    polygon = createShape();
    polygon.beginShape(TRIANGLE_FAN);
    polygon.noStroke();
    polygon.textureMode(NORMAL);
    polygon.texture(i_gfx);
    createPolygon(polygon, i_texCoords);
    polygon.endShape();

    outlines = createShape();
    outlines.beginShape(TRIANGLE_FAN);
    outlines.stroke(255,0,0);
    outlines.strokeWeight(2);
    outlines.noFill();
    createPolygon(outlines, i_texCoords);
    outlines.endShape();
  }

  void createPolygon(PShape i_polygon, PVector[] i_texCoords) {

    float theta = TWO_PI/sides;
    i_polygon.vertex(0, 0, i_texCoords[0].x, i_texCoords[0].y);

    for (int i = 0; i <= sides; ++i) {
      float t = (theta*i)+(theta/2);
      float nt = (theta*(i+1))+(theta/2);

      PVector pt = new PVector(cos(t)*radius, sin(t)*radius);
      PVector npt = new PVector(cos(nt)*radius, sin(nt)*radius);
      PVector mid = PVector.lerp(pt, npt, 0.5);

      unitWidth  = PVector.dist(new PVector(0, 0), mid);
      unitHeight = PVector.dist(pt, mid); 

      i_polygon.vertex(pt.x, pt.y, i_texCoords[1].x, i_texCoords[1].y);
      i_polygon.vertex(mid.x, mid.y, i_texCoords[2].x, i_texCoords[2].y);
    }
    
  }

  public void drawAt(float i_x, float i_y, PGraphics renderContext) {

    renderContext.pushMatrix();
    renderContext.translate(i_x, i_y);
    renderContext.shape(polygon);
    renderContext.popMatrix();
  }

  public void drawOutlinesAt(float i_x, float i_y, PGraphics renderContext) {

    renderContext.pushMatrix();
    renderContext.translate(i_x, i_y);
    renderContext.shape(outlines);
    renderContext.popMatrix();
  }

  public PImage getUnitImage() {
    return null;
  }
  
}

