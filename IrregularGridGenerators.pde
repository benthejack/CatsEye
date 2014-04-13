/*---------------------------------------------------------------------------------------------
 *
 *    VoronoiDelauneyGrid
 *    
 *    Implementation of voronoi and delauney triangulation tiling grids
 *
 *    Ben Jack 6/4/2014 
 *
 *---------------------------------------------------------------------------------------------*/

import toxi.geom.*;
import toxi.geom.mesh2d.*;

import toxi.util.*;
import toxi.util.datatypes.*;

import toxi.processing.*;

import java.util.List;



class VoronoiDelaunayGrid extends TileGrid {

  public final int VORONOI = 0;
  public final int DELAUNAY = 1; 
  
  private int type;
  
  Voronoi voronoi;
  PolygonClipper2D clip;

  private FloatRange xpos, ypos;



  VoronoiDelaunayGrid() {
    super();
    init();
  }

  VoronoiDelaunayGrid(TileGrid i_oldGrid) {
    super(i_oldGrid);
    init();
  }

  private void init() {
    voronoi = new Voronoi();
    type = VORONOI;
    renderMode = P2D;
    cellRadius = -1;
    cellSize = new PVector(-1, -1);
    
    xpos=new BiasedFloatRange(-renderSize.x*0.5, renderSize.x*1.5, renderSize.x/2, 0.222f);
    ypos=new BiasedFloatRange(-renderSize.x*0.5, renderSize.y*1.5, renderSize.y/2, 0.222f);
    

  }
  
  public void setRenderMode(String i_mode) {
      println("only P2D mode for voronoi and delaunay grids");
  }

  public void setType(int i_type){
    type = i_type;
  } 

  public void addPoint(PVector i_pt) {
    voronoi.addPoint(new Vec2D(i_pt.x, i_pt.y));
  }


  public void addRandomPoints(int i_count, float i_rangeX, float i_rangeY) {
    for (int i = 0; i < i_count; ++i) {
      addPoint(new PVector(xpos.pickRandom(), ypos.pickRandom()));
    }
  }
  
  
  public void generate(boolean i_outlines) {
 
    P2DIrregularPolygonGenerator generator = setupIrregularNgonGenerator();
    PGraphics currentContext = initGeneration(i_outlines);

    clip=new SutherlandHodgemanClipper(new Rect(0, 0, renderSize.x, renderSize.y));

    if(type==VORONOI){
      for (Polygon2D poly : voronoi.getRegions()) {
        
        Polygon2D clipped = clip.clipPolygon(poly);
        Vec2D centroid = clipped.getCentroid();

        if(clipped.vertices.size() > 0){
          generator.constructIrregularPolygon(reformatList(clipped.vertices), new PVector(centroid.x, centroid.y), i_outlines);
          drawNgonAt(centroid.x, centroid.y, currentContext);
        }
      }
    }else if(type==DELAUNAY){
      for (Triangle2D tri : voronoi.getTriangles()) {
        
        Polygon2D clipped = clip.clipPolygon(tri.toPolygon2D());
        Vec2D centroid = clipped.getCentroid();

        if(clipped.vertices.size() > 0){
          generator.constructIrregularPolygon(reformatList(clipped.vertices), new PVector(centroid.x, centroid.y), i_outlines);
          drawNgonAt(centroid.x, centroid.y, currentContext);
        }
      }  
    }

    completeGeneration(i_outlines);
  }



  private ArrayList<PVector> reformatList(List<Vec2D> i_list) {

    ArrayList<PVector> output = new ArrayList<PVector>();

    for (Vec2D i : i_list) {
      output.add(new PVector(i.x, i.y));
    } 

    return output;
    
  }

  
}

