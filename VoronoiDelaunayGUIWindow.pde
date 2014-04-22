import java.util.List;


public class VoronoiDelaunayGUIWindow extends PApplet {


  ControlP5 cp5;
  CatsEye parent;

  private int randomCount;
  private int myWidth, myHeight;
  private VoronoiDelaunayGrid vdGrid;

  private int gridType;

  ArrayList<PVector> points;
  Voronoi voronoi;
  PolygonClipper2D clip;

  private VoronoiDelaunayGUIWindow() {
  }


  public VoronoiDelaunayGUIWindow(CatsEye theParent, VoronoiDelaunayGrid i_vdGrid, int theWidth, int theHeight) {
    parent = theParent;
    vdGrid = i_vdGrid;
    myWidth = theWidth;
    myHeight = theHeight;

    voronoi = new Voronoi();
    clip=new SutherlandHodgemanClipper(new Rect(0, 0, theWidth, theHeight));
  }


  public void setup() {
    size(myWidth, myHeight); 

    createGuiControls();  
    points = new  ArrayList<PVector>();
  }


  public void clearPoints() {
    points.clear();
  }
  
  

  public void addRandomPoints() {

    println("random");

    for (int i = 0; i < randomCount; ++i) {
      points.add(new PVector(random(this.width), random(this.height)));
    }
  }
  
  
  
  public ArrayList<PVector> getNormalizedPoints(){
   
   ArrayList<PVector> normalized = new ArrayList<PVector>();
   
   for(PVector pt : points){
     normalized.add(new PVector(pt.x/(myWidth+0.0), pt.y/(myHeight+0.0))); 
   } 
    
   return normalized;
   
  }
  
  public void setGridType(int i_type){
    gridType = i_type;
  }
  
  
  
  //--------------------------------------PRIVATE METHODS----------------------------------------
  //although some of these are public due to controlP5 needs or otherwise, they shouldn't be used     
    
    
  public void mousePressed() {
    points.add(new PVector(mouseX, mouseY));
  }


  public void draw() {

    background(255);

    calculateVoronoi();
    
     noFill();
     stroke(0);
     
     List<Polygon2D> polys;
     
     if(gridType == DELAUNAYGRID){
       polys = new ArrayList<Polygon2D>();
       for(Triangle2D t : voronoi.getTriangles()){
        polys.add(t.toPolygon2D()); 
       }
     }
     else
        polys = voronoi.getRegions();
   
     
     for (Polygon2D poly : polys) {
        
        Polygon2D clipped = clip.clipPolygon(poly);

        beginShape();
        for(Vec2D pt : clipped.vertices){
          vertex(pt.x, pt.y);
        }
        
        Vec2D pt = clipped.vertices.get(0);
        vertex(pt.x, pt.y);
        endShape();
        
                
     }

    for (PVector pos : points) {
      fill(255, 0, 0);
      stroke(255, 0, 0);
      ellipse(pos.x, pos.y, 2, 2);
    }
    
  }
  
    
    private void calculateVoronoi(){
      
      voronoi = new Voronoi();
      
      for(PVector i : points){
        voronoi.addPoint(new Vec2D(i.x, i.y));
      }
      
    }
  


  //--------------------------------------------ACTUAL GUI CREATION--------------------------------------------------------

  private void createGuiControls() {
    this.cp5 = new ControlP5(this);

    this.cp5.addButton("clearPoints")
      .setPosition(20, 20);

    this.cp5.addButton("add random")
      .setPosition(100, 20)
        .plugTo(this, "addRandomPoints");
        
    cp5.addNumberbox("randomCount")
    .setPosition(180, 20)
      .setSize(45, 14)
        .setScrollSensitivity(1.1)
          .setValue(10)
            .setRange(10,1000);
        
     }
}

