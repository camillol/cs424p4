class MapView extends View {
  PShape mapShape;
  float viewBoxW;
  float viewBoxH;
  float offsetX, offsetY;
  
  MapView(float x_, float y_, float w_, float h_)
  {
    super(x_,y_,w_,h_);
    mapShape = loadShape("BlankMap-World6-fixids.svg");
    mapShape.disableStyle();
    viewBoxW = 2752.766;
    viewBoxH = 1537.631;
    
    offsetX = offsetY = 100000;
    for (int i = 0; i < mapShape.getChild("ocean").getVertexCount(); i++) {
      offsetX = min(offsetX, mapShape.getChild("ocean").getVertexX(i));
      offsetY = min(offsetY, mapShape.getChild("ocean").getVertexY(i));
    }
    
    for (Country c : data.getCountries()) {
      PShape cShape = mapShape.getChild(c.code);
      if (cShape == null) println("no shape for " + c.code);
    }
  }
  
  void drawContent(float lx, float ly)
  {
    pushMatrix();
    scale(min(w/viewBoxW, h/viewBoxH));
    translate(-offsetX, -offsetY);
    
    noStroke();
    fill(#FF0000);
    shape(mapShape.getChild("ocean"), 0, 0);
    stroke(128);
    fill(255);
    for (Country c : data.getCountries()) {
      PShape cShape = mapShape.getChild(c.code);
      if (cShape != null) shape(cShape, 0, 0);
    }
    
    popMatrix();
    
    stroke(#00FF00);
    noFill();
    rect(0,0,w,h);
  }
}
