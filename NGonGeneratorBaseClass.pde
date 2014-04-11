class NGonGenerator {

  protected int sides;
  protected float radius, unitWidth, unitHeight;


  NGonGenerator(int i_segments, float i_radius) {
    sides = i_segments;
    radius = i_radius;
  }

  public void drawAt(float i_x, float i_y, PGraphics renderContext) {
  }

  public void drawOutlinesAt(float i_x, float i_y, PGraphics renderContext) {
  }

  public float cellWidth() {
    return unitWidth;
  }

  public float cellHeight() {
    return unitHeight;
  }  

  public float cellRadius() {
    return radius;
  }

  public PImage getUnitImage() {
    return createImage(1,1,RGB);
  }
  
}

