class MapView extends View {
  PShape mapShape;
  float viewBoxW;
  float viewBoxH;
  float offsetX, offsetY;
  
  /* all country codes in the map; some are not in our data */
  final String[] allCC = {"sd","ss","ge","xa","xo","pe","bf","fr","gp","mq","re","yt","gf","ly","by","pk","id","ye","mg","bo","rs","xk","ci","dz","ch","cm","mk","bw","ke","tw","jo","mx","ae","bz","br","sl","ml","cd","it","so","xs","af","bd","do","gw","gh","at","se","tr","ug","mz","jp","nz","cu","ve","pt","co","mr","ao","de","th","au","pg","iq","hr","gl","ne","dk","lv","ro","zm","mm","et","gt","sr","eh","cz","td","al","fi","sy","kg","sb","om","pa","ar","uk","cr","py","gn","ie","ng","tn","pl","na","za","eg","tz","sa","vn","ru","ht","ba","in","cn","hk","mo","ca","sv","gy","be","gq","ls","bg","bi","dj","az","xn","ir","my","ph","uy","cg","me","ee","rw","am","sn","tg","es","ga","hu","mw","tj","kh","kr","hn","is","ni","cl","ma","lr","nl","bq","cf","sk","lt","zw","lk","il","la","kp","gr","tm","ec","bj","si","no","md","xp","ua","lb","np","er","us","kz","tf","aq","sz","uz","mn","bt","nc","fj","kw","tl","bs","vu","fk","gs","gm","qa","jm","cy","xc","pr","ps","bn","tt","cv","pf","ws","lu","km","mu","fo","st","vi","cw","sx","dm","to","ki","fm","bh","ad","mp","pw","sc","ag","bb","tc","vc","lc","gd","mt","mv","ky","kn","ms","bl","nu","pm","ck","wf","as","mh","aw","li","vg","sh","je","ai","mf","gg","sm","bm","tv","nr","gi","pn","mc","va","im","gu","sg","nf","tk"};
  
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
    
    /* print first-level children - these include 'null' and 'ocean', but exclude 'xk', 'xa', 'xn', 'xo', 're', 'xc', 'mo', 'gp', 'gf', 'mq', 'bq', 'xs', 'xp', 'yt', 'hk' */
/*    println("");
    for (int i = 0; i < mapShape.getChildCount(); i++) {
      print(mapShape.getChild(i).getName() + ",");
    }
    println();*/

    if (data.getCountries() != null) for (Country c : data.getCountries()) {
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
    fill(#EEEEFF);
    drawOcean(mapShape.getChild("ocean"));
    
    stroke(128);
    fill(255);
    for (int i = 0; i < allCC.length; i++) {
      String cc = allCC[i];
//      Country c = data.getCountryByCode(cc);
      PShape cShape = mapShape.getChild(cc);
      drawCountry(cShape, cc);
    }
    
    popMatrix();
    
    stroke(#00FF00);
    noFill();
    rect(0,0,w,h);
  }
  
  void drawOcean(PShape oShape) {
    shape(oShape, 0, 0);
  }
  
  void drawCountry(PShape cShape, String cc) {
    shape(cShape, 0, 0);
  }
}
