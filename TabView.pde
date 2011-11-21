class TabViewTab {
  String title;
  View pane;
  TabView tabView;
  
  TabViewTab(TabView tabView, String title)
  {
    this.title = title;
    this.tabView = tabView;
    this.pane = new View(0, TabView.TAB_HEIGHT, tabView.w, tabView.h-TabView.TAB_HEIGHT);
  }
}

class TabView extends View {
  List<TabViewTab> tabs;
  TabViewTab activeTab = null;
  
  final static int TAB_HEIGHT = 20;
  final static int TAB_GAP = 8;
  final static int TAB_PADDING = 4;
  
  TabView(float x_, float y_, float w_, float h_, List<String> tabTitles)
  {
    super(x_,y_,w_,h_);
    tabs = new ArrayList<TabViewTab>(tabTitles.size());
    for (String title : tabTitles) {
      tabs.add(new TabViewTab(this, title));
    }
    setActiveTab(tabs.get(0));
  }
  
  void setActiveTab(TabViewTab t)
  {
    if (activeTab != null) subviews.remove(activeTab.pane);
    activeTab = t;
    subviews.add(activeTab.pane);
  }
  
  void drawContent(float lx, float ly)
  {
    strokeWeight(1);
    stroke(borderColor);
    noFill();
    rect(0, TAB_HEIGHT, w, h-TAB_HEIGHT);
    
    float tabx = 0;
    for (TabViewTab t : tabs) {
      float tabw = textWidth(t.title) + TAB_PADDING*2;
      if (t == activeTab) {
        fill(128);
      } else {
        noFill();
      }
      rect(tabx, 0, tabw, TAB_HEIGHT);
      fill(textColor);
      textAlign(CENTER, CENTER);
      text(t.title, tabx + TAB_PADDING, 0, tabw - TAB_PADDING*2, TAB_HEIGHT);
      tabx += tabw + TAB_GAP;
    }
  }
  
  boolean contentClicked(float lx, float ly)
  {
    if (ly < TAB_HEIGHT) {
      float tabx = 0;
      for (TabViewTab t : tabs) {
        float tabw = textWidth(t.title) + TAB_PADDING*2;
        if (ptInRect(lx, ly, tabx, 0, tabw, TAB_HEIGHT)) {
          setActiveTab(t);
          return true;
        }
        tabx += tabw + TAB_GAP;
      }
    }
    return false;
  }
}
