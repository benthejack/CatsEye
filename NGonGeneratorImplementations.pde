/*---------------------------------------------------------------------------------------------
 *
 *    Java2DNgonGenerator
 *    
 *    subclass of NGonGenerator that uses JAVA2D to render images.
 *    this class uses a masked image that is transformed several times.
 *
 *    The benefit of using JAVA2D is that it can export REALLY big images.
 *    The drawback is that a lot of features can't be implemented in JAVA2D
 *
 *    Ben Jack 11/4/2014 
 *
 *---------------------------------------------------------------------------------------------*/

float UNITPREVIEWSIZE = 120;



class Java2DNgonGenerator extends NGonGenerator {

  private PatternTriangle unit;
  private PatternTriangle unitPreview;
  private PMatrix2D[] transforms;

  Java2DNgonGenerator(int i_segments, float i_radius, PImage i_gfx) 
  {
    super(i_segments, i_radius);
    float theta = TWO_PI/i_segments;

    PImage canvas = new PImage((int)i_radius*2, (int)i_radius*2, ARGB);

    unit = createUnit(i_radius, i_gfx, theta, true);
    unitPreview = createUnit(UNITPREVIEWSIZE, i_gfx, theta, false);

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
  
  private PatternTriangle createUnit(float i_radius, PImage i_gfx, float i_theta, boolean i_isMainUnit){
   
    PVector temp1 = new PVector(i_radius, 0, 0);
    PVector temp2 = new PVector(cos(i_theta)*i_radius, sin(i_theta)*i_radius, 0);

    temp1.lerp(temp2, 0.5);

    PVector f1 = new PVector(0, 0, 0);
    PVector f2 = new PVector(i_radius, 0, 0);
    PVector f3 = temp1.get();

    PatternTriangle out = new PatternTriangle(f1, f2, f3, i_gfx);  

    if(i_isMainUnit){
      unitWidth = PVector.dist(f1, f3);
      unitHeight = PVector.dist(f2, f3);  
    }
    
    return out;
    
  }

  public void drawAt(float i_x, float i_y, PGraphics renderContext) {

    for (int i = 0; i < sides*2; ++i) {
      renderContext.pushMatrix();
      renderContext.translate(i_x, i_y);

      //hack to fix bizarre single pixel tearing on the screen diagonal when creating a square grid
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
    return unitPreview.getImage();
  }
}








/*---------------------------------------------------------------------------------------------
 *
 *    P2DNgonGenerator
 *    
 *    subclass of NGonGenerator that uses JAVA2D to render images.
 *    this class uses a textured PShape using texture coordinates.
 *
 *    The benefit of using P2D is that it enables a lot of features by using openGl.
 *    The drawback is that the size of images that can be produced are limited by the 
 *    graphics card of the user.
 *
 *    Ben Jack 11/4/2014 
 *
 *---------------------------------------------------------------------------------------------*/



class P2DNgonGenerator extends NGonGenerator {

  private PShape polygon;
  private PShape outlines;
  private PImage tesselationUnit;

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

  private void init(PImage i_gfx, PVector[] i_texCoords) 
  {
    polygon = createShape();
    polygon.beginShape(TRIANGLE_FAN);
    polygon.noStroke();
    polygon.textureMode(NORMAL);
    polygon.texture(i_gfx);
    polygon.vertex(0, 0, i_texCoords[0].x, i_texCoords[0].y);
    createPolygon(polygon, i_texCoords);
    polygon.endShape();


    PShape outer = createShape();
    outer.beginShape();
    outer.stroke(255);
    outer.strokeWeight(2);
    outer.noFill();
    createPolygon(outer, i_texCoords);
    outer.endShape();
    
    PShape inner = createShape();
    inner.beginShape(TRIANGLE_FAN);
    inner.stroke(255, 0, 0);
    inner.strokeWeight(2);
    inner.noFill();
    inner.vertex(0, 0, i_texCoords[0].x, i_texCoords[0].y);
    createPolygon(inner, i_texCoords);
    inner.endShape();
    
    outlines = createShape(GROUP);
    outlines.addChild(inner);
    outlines.addChild(outer);
    

    tesselationUnit = createTesselationUnit(i_gfx, i_texCoords);
  }

  private void createPolygon(PShape i_polygon, PVector[] i_texCoords) {
    
    float theta = TWO_PI/sides;

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

  private PImage createTesselationUnit(PImage i_gfx, PVector[] i_texCoords) {

    PGraphics out = createGraphics((int)UNITPREVIEWSIZE+10, (int)UNITPREVIEWSIZE+10, P2D);
    out.beginDraw();
    out.background(0, 0);

    PShape tri = createShape();

    tri.beginShape(TRIANGLES);
    tri.noStroke();
    tri.textureMode(NORMAL);
    tri.texture(i_gfx);

    float theta = TWO_PI/sides;
    float t = 0;
    float nt = theta;

    PVector pt = new PVector(cos(t)* UNITPREVIEWSIZE, sin(t)*UNITPREVIEWSIZE);
    PVector npt = new PVector(cos(nt)* UNITPREVIEWSIZE, sin(nt)*UNITPREVIEWSIZE);
    PVector mid = PVector.lerp(pt, npt, 0.5);

    tri.vertex(0, 0, i_texCoords[0].x, i_texCoords[0].y);
    tri.vertex(pt.x, pt.y, i_texCoords[1].x, i_texCoords[1].y);
    tri.vertex(mid.x, mid.y, i_texCoords[2].x, i_texCoords[2].y);

    tri.endShape();

    out.shape(tri);
    out.endDraw();

    return out.get();
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
    return tesselationUnit;
  }
}


