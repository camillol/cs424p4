interface TableAction {
  void itemClicked(TableView tv, int index, Object item);
}

interface TableDataSource {
  String getText(int index, int column);
  Object get(int index);
  int count();
  boolean selected(int index);
}

class TableColumn {
  String label;
  float w;
  
  TableColumn(String label, float w) {
    this.label = label;
    this.w = w;
  }
}

class TableView extends View {
  final int rowHeight = 20;
  final int barSize = 14;
  
  color bgColor = color(0);
  color fgColor = color(255);
  color selBgColor = color(128);
  color selFgColor = color(255);
  
  List<TableColumn> columns;
  TableDataSource data;
  TableAction action;
  int scrollPos = 0;
  
  float thumbClickPos = -1;
  
  final static int MARGIN = 8;
  
  TableView(float x_, float y_, float w_, float h_, List<TableColumn> columns, TableDataSource data)
  {
    super(x_,y_,w_,h_);
    this.columns = columns;
    this.data = data;
    action = null;
  }
  
  int maxScroll()
  {
    return max(data.count() - int(h/rowHeight), 0);
  }
  
  void scrollTo(int index)
  {
    scrollPos = min(max(index, 0), maxScroll());
  }

  void drawContent(float lx, float ly)
  {
    strokeWeight(1);
    stroke(fgColor);
    fill(bgColor);
    rect(0,0,w,h);
    noStroke();
    
    textAlign(LEFT, CENTER);
    for(int i = scrollPos; i < scrollPos + (h/rowHeight) && i < data.count(); i++) {
      float rowy = (i-scrollPos) * rowHeight;
      pushMatrix();
      translate(0, rowy);
      drawRow(i);
      popMatrix();
    }
    
    if (maxScroll() > 0) {
      pushMatrix();
      translate(w-barSize, 0);
      
      /* draw scrollbar */
      fill(bgColor);
      rect(0, 0, barSize, h);
      
      float thumbH = map(int(h/rowHeight), 0, data.count(), 0, h);
      float thumbY = map(scrollPos, 0, maxScroll(), 0, h-thumbH);
      fill(fgColor);
      rect(0, thumbY, barSize, thumbH);
      
      popMatrix();
    }
  }
  
  void drawRow(int i)
  {
    if (data.selected(i)) {
      fill(selBgColor);
      rect(0, 0, w, rowHeight);
      fill(selFgColor);
    } else {
      fill(fgColor);
    }
    
    float colx = 0;
    for (int j = 0; j < columns.size(); j++) {
      TableColumn col = columns.get(j);
      text(data.getText(i, j), colx + MARGIN, 0, col.w, rowHeight);
      colx += col.w;
    }
  }
  
  boolean contentPressed(float lx, float ly)
  {
    if (maxScroll() > 0 && lx >= w-barSize) {
      float thumbH = map(int(h/rowHeight), 0, data.count(), 0, h);
      float thumbY = map(scrollPos, 0, maxScroll(), 0, h-thumbH);
      thumbClickPos = (ly - thumbY) / thumbH;
    }
    return true;
  }
  
  boolean contentDragged(float lx, float ly)
  {
    if (thumbClickPos >= 0.0 && thumbClickPos <= 1.0) {
      float thumbH = map(int(h/rowHeight), 0, data.count(), 0, h);
      float thumbY = constrain(ly - thumbClickPos * thumbH, 0, h-thumbH);
      scrollPos = round(map(thumbY, 0, h-thumbH, 0, maxScroll()));
    }
    return true;
  }
  
  boolean contentClicked(float lx, float ly)
  {
    int index = constrain(int(ly/rowHeight) + scrollPos, 0, data.count()-1);
    if (action != null) action.itemClicked(this, index, data.get(index));
    return true;
  }
}

