interface PieChartDataSource {
  String getLabel(int index);
  float getValue(int index);
  int count();
  float getTotal();
  color getColor(int index);
}

class MissingPieChartDataSource implements PieChartDataSource {
  String msg;
  
  MissingPieChartDataSource(String msg_) { msg = msg_; }
  String getLabel(int index) { return msg; }
  float getValue(int index) { return 1; }
  int count() { return 1; }
  float getTotal() { return 1; }
  color getColor(int index) { return 0;  }
}

class AsyncPieChartDataSource implements PieChartDataSource {
  Future<? extends PieChartDataSource> data;
  MissingPieChartDataSource noData;
  AsyncPieChartDataSource(Future<? extends PieChartDataSource> data) {
    this.data = data;
    noData = new MissingPieChartDataSource("loading...");
  }
  PieChartDataSource getData() {
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
  String getLabel(int index) { return getData().getLabel(index); }
  float getValue(int index) { return getData().getValue(index); }
  int count() { return getData().count(); }
  float getTotal() { return getData().getTotal(); }
  color getColor(int index) { return getData().getColor(index); }
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
    ellipseMode(CENTER);
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
    if (title != null) {
      textAlign(CENTER, BOTTOM);
      textSize(20);
      text(title, w/2, 0);
      textSize(normalFontSize);
    }
  }
  
  boolean contentClicked(float lx, float ly)
  {
    return true;
  }
}

