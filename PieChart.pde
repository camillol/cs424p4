interface PieChartDataSource {
  String getLabel(int index);
  float getValue(int index);
  int count();
  float getTotal();
  color getColor(int index);
}

class MissingPieChartDataSource implements PieChartDataSource {
  String getLabel(int index) { return "no data"; }
  float getValue(int index) { return 0; }
  int count() { return 0; }
  float getTotal() { return 1; }
  color getColor(int index) { return 0;  }
}

class PieChart extends View
{
  PieChartDataSource data;
  boolean showLabels;
  String title;
  
  PieChart(float x_, float y_, float w_, float h_, PieChartDataSource data, boolean showLabels, String title)
  {
    super(x_,y_,w_,h_);
    this.data = data;
    this.showLabels = showLabels;
    this.title = title;
  }
  
  void drawContent(float lx, float ly)
  {
    stroke(255);
    
    int count = data.count();
    float total = data.getTotal();
    
    float theta = 0;
    for (int i = 0; i < count; i++) {
      float angle = TWO_PI * data.getValue(i) / total;
      fill(data.getColor(i));
      //fill((float)(i / (float)angles.size() * 255));
      float d = min(w,h);
      arc(w/2, h/2, d, d, theta, theta+angle);
      if (showLabels) {
        fill(textColor);
        //fill((float)((angles.size() - i) / (float)angles.size() * 255));
        float labelAngle = theta + angle/2;
        textAlign(CENTER, CENTER);
        text(data.getLabel(i), w/2 + cos(labelAngle)*d/4, h/2 + sin(labelAngle)*d/4);
      }
      theta += angle;
    }
  }
  
  boolean contentClicked(float lx, float ly)
  {
    return true;
  }
}

