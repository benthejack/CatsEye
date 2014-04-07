class NGonGenerator{
 
 private int sides;
 private float radius, unitWidth, unitHeight;
 
 private PatternTriangle unit;
 private PImage canvas;
 
 private PMatrix2D[] transforms;
 
 NGonGenerator(int i_segments, float i_radius, PImage gfx){
   
   sides = i_segments;
   float theta = TWO_PI/i_segments;
   radius = i_radius;
     
   canvas = new PImage((int)i_radius*2, (int)i_radius*2, ARGB);
   
   PVector temp1 = new PVector(i_radius,0,0);
   PVector temp2 = new PVector(cos(theta)*i_radius,sin(theta)*i_radius,0);
   
   temp1.lerp(temp2,0.5);
   
   PVector f1 = new PVector(0,0,0);
   PVector f2 = new PVector(i_radius,0,0);
   PVector f3 = temp1.get();
   
   unit = new PatternTriangle(f1,f2,f3,gfx);  
   unitWidth = PVector.dist(f1,f3);
   unitHeight = PVector.dist(f2,f3); 
   
   transforms = new PMatrix2D[i_segments*2];
   PMatrix2D flip = new PMatrix2D();
   flip.scale(-1,0);
   
   for(int i = 0; i < i_segments*2; ++i){
     PMatrix2D newMat = new PMatrix2D();
     
     if(i%2 == 1){
       newMat.scale(-1,1);
       newMat.rotate(-PI-theta); 
     }
     newMat.rotate(theta/2);
     newMat.rotate((i/2)*theta);
     transforms[i] = newMat;
   }
   
 }
 
 public void drawAt(float i_x, float i_y, PGraphics renderContext){
  
     for(int i = 0; i < sides*2; ++i){
       renderContext.pushMatrix();
       renderContext.translate(i_x,i_y);
       
       //hack to fix bizarre tearing on the screen diagonal when creating a square grid
       if(sides == 4)
         renderContext.rotate(0.0001);
       //-------------------------------------------------------------------------------
       
       renderContext.applyMatrix(transforms[i]);
       unit.draw(renderContext);
       renderContext.popMatrix();
     }
   
 }
 
 public void drawOutlinesAt(float i_x, float i_y, PGraphics renderContext){
  
     for(int i = 0; i < sides*2; ++i){
       renderContext.pushMatrix();
       renderContext.translate(i_x,i_y);
       renderContext.applyMatrix(transforms[i]);
       unit.drawOutline(renderContext);
       renderContext.popMatrix();
     }
   
 }
 
 public float cellWidth(){
  return unitWidth; 
 }

 public float cellHeight(){
  return unitHeight; 
 }  
 
 public float cellRadius(){
   return radius; 
 }
 
 public PImage getUnitImage(){
   return unit.getImage(); 
 }
  
  
  
}
