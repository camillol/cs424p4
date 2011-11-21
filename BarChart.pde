interface BarChartDataSource {
  String getLabel(int index);
  float getValue(int index);
  int count();
  float getMaxValue();
  color getColor(int index);
}

class BarChart extends View {
  
  BarChartDataSource data;
  boolean showLabels;
  boolean showScale;
  
  final static int LABEL_HEIGHT = 20;
  final static int SCALE_WIDTH = 30;
  
  BarChart(float x_, float y_, float w_, float h_, BarChartDataSource data, boolean showLabels, boolean showScale)
  {
    super(x_,y_,w_,h_);
    this.data = data;
    this.showLabels = showLabels;
    this.showScale = showScale;
  }
  
  void drawContent(float lx, float ly)
  {
    stroke(255);
    
    int count = data.count();
    float vmax = data.getMaxValue();
    float hmax = h;
    if (showLabels) hmax -= LABEL_HEIGHT;
    
    float barx = 0;
    if (showScale) {
      textAlign(RIGHT, TOP);
      barx += SCALE_WIDTH;
      line(0, 0, SCALE_WIDTH, 0);
      text(nf(vmax,1,0), SCALE_WIDTH-8, 4);
      line(0, hmax, SCALE_WIDTH, hmax);
      textAlign(RIGHT, BOTTOM);
      text(nf(0,1,0), SCALE_WIDTH-8, hmax);
    }
    float barw = (w-barx)/count;
    
    textAlign(CENTER, CENTER);
    for (int i = 0; i < count; i++) {
      float barh = hmax * data.getValue(i) / vmax;
      fill(data.getColor(i));
      rect(barx, hmax-barh, barw, barh);
      if (showLabels) {
        fill(textColor);
        text(data.getLabel(i), barx, h - LABEL_HEIGHT, barw, LABEL_HEIGHT);
      }
      barx += barw;
    }
  }
  
  boolean contentClicked(float lx, float ly)
  {
    return true;
  }
}

