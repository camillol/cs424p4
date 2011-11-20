class TextField extends View {
  String value = "";
  int pos;
  color fgColor = 255;
  final static int MARGIN = 3;
  
  TextField(float x_, float y_, float w_, float h_)
  {
    super(x_,y_,w_,h_);
  }
  
  void drawContent(float lx, float ly)
  {
    strokeWeight(1);
    stroke(fgColor);
    noFill();
    rect(0, 0, w, h);
    
    fill(fgColor);
    textAlign(LEFT, CENTER);
    text(value, MARGIN, h/2);
    
    if (focusView == this && ((millis() / 500) % 2 == 0)) {
      float tw = textWidth(value);
      line(MARGIN + tw, MARGIN, MARGIN + tw, h-MARGIN);
    }
  }
  
  boolean contentClicked(float lx, float ly)
  {
    focusView = this;
    return true;
  }
  
  void keyTyped()
  {
    if (key == CODED) println(keyCode);
    else if (key == BACKSPACE && value.length() > 0) value = value.substring(0, value.length()-1);
    else value = value + key;
  }
}
