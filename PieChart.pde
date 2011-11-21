class PieChart extends View{
  float diameter;
  String title;
  ArrayList<String> labels;
  ArrayList<Integer> angles;

  int chartType;
  public static final int CHART_TYPE_GENDER = 1;

  PieChart(float x_, float y_, float w_, float h_, ArrayList<String> labels, ArrayList<Integer> angles, int chartType, String title){
    super(x_,y_,w_,h_);
    this.labels = labels;
    this.angles = angles;
    this.chartType = chartType;
    this.title = title;
    setChartSettings();
  }

  void setChartSettings(){
    if(chartType == CHART_TYPE_GENDER){
      diameter = min(w, h);
    }
  }

  void drawContent(float lx, float ly){
    textSize(20);
    text(title, 0, 0);
    
    int i = 0;
    textSize(10);
    float lastAngle = 0;
    for(Integer angle : angles){
      fill((float)(i / (float)angles.size() * 255));
      //System.out.println("x ="+x+"y="+y+"width: " + w + " height: " + h + " diameter: " + diameter + " lastAngle: " + lastAngle + " last angle + radians: " + lastAngle+radians(angle));
      arc(w/2, h/2, diameter, diameter, lastAngle, lastAngle+radians(angle));
      float labelAngle = lastAngle + radians(angle)/2;
      //fill(#ff0000);
      fill((float)((angles.size() - i) / (float)angles.size() * 255));
      textAlign(CENTER, CENTER);
      
      text(labels.get(i), w/2 + cos(labelAngle)*diameter/4, h/2 + sin(labelAngle)*diameter/4);
      lastAngle += radians(angle);
      i++;
    }
    textSize(normalFontSize);
  }
}
