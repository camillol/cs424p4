class CheckBox extends View {
  boolean checked = false;
  color fgColor = 255;
  
  final static int INSET = 3;
  
  CheckBox(float x_, float y_, float w_, float h_)
  {
    super(x_,y_,w_,h_);
  }
  
  void drawContent()
  {
    strokeWeight(1);
    stroke(fgColor);
    noFill();
    rect(0, 0, w, h);
    
    if (checked) {
      fill(fgColor);
      rect(INSET, INSET, w-INSET*2, h-INSET*2);
    }
  }
  
  boolean contentClicked(float lx, float ly)
  {
    checked = !checked;
    buttonClicked(this);
    return true;
  }
}

