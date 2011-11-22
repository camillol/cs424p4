interface TableAction {
  void itemClicked(TableView tv, int index, Object item);
}

interface TableDataSource {
  String getText(int index, int column);
  Object get(int index);
  int count();
  boolean selected(int index);
  PImage getImage(int index, int column);
}

class MissingTableDataSource implements TableDataSource {
  String msg;
  
  MissingTableDataSource(String msg_) { msg = msg_; }
  String getText(int index, int column) { return msg; }
  Object get(int index) { return null; }
  int count() { return 1; }
  boolean selected(int index) { return false; }
  PImage getImage(int index, int column){return null;}
}

class AsyncTableDataSource implements TableDataSource {
   PImage getImage(int index, int column){ return null;}
  Future<? extends TableDataSource> data;
  MissingTableDataSource noData;
  AsyncTableDataSource(Future<? extends TableDataSource> data) {
    this.data = data;
    noData = new MissingTableDataSource("loading...");
  }
  TableDataSource getData() {
    if (data.isDone()) try {
      return data.get();
    } catch (InterruptedException e) {
      println(e);
    } catch (ExecutionException e) {
      println(e);
      noData.msg = "request failed";
    }
    return noData;
  }
  String getText(int index, int column) { return getData().getText(index,column); }
  Object get(int index) { return getData().get(index); }
  int count() { return getData().count(); }
  boolean selected(int index) { return getData().selected(index); }
}

class TableColumn {
  String label;
  float w;
  int align;
  boolean imagable;
  
  TableColumn(String label, float w, int align) {
    this.label = label;
    this.w = w;
    this.align = align;
  }
  
  TableColumn(String label, float w) {
    this(label, w, LEFT);
  }
  TableColumn(String label, float w, boolean imagable) {
    this(label, w);
    this.imagable = imagable;
  }

}

class TableHeader extends View {
  TableView tableView;
  TableHeader(float x_, float y_, float w_, float h_, TableView tableView)
  {
    super(x_,y_,w_,h_);
    this.tableView = tableView;
  }
  
  void drawContent(float lx, float ly)
  {
    strokeWeight(1);
    stroke(borderColor);
    fill(tableView.bgColor);
    rect(0,0,w,h);
    noStroke();
    
    fill(tableView.fgColor);
    
    float colx = 0;
    for (int j = 0; j < tableView.columns.size(); j++) {
      TableColumn col = tableView.columns.get(j);
      textAlign(col.align, CENTER);
      text(col.label, colx + TableView.MARGIN, 0, col.w - TableView.MARGIN*2, h);
      colx += col.w;
    }
  }
}

class TableView extends View {
  int rowHeight = 20;
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
  
  void setRowHeight(int rowHeight){
    rowHeight = rowHeight;
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
    stroke(borderColor);
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
      rect(0, 1, barSize, h-1);
      
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
      drawCell(i, j, col, colx);
      colx += col.w;
    }
  }
  
  void drawCell(int i, int j, TableColumn col, float colx)
  {
    textAlign(col.align, CENTER);
    if(col.imagable && data.getImage(i,j) != null)
      image(data.getImage(i,j), colx + MARGIN, 0);
    else
      text(data.getText(i, j), colx + MARGIN, 0, col.w - MARGIN*2, rowHeight);
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

