interface Action<T> {
  void respond(T view);
}

class Button extends View {
  color fgColor = 255;
  String title;
  Action<Button> action = null;
  
  Button(float x_, float y_, float w_, float h_, String title)
  {
    super(x_,y_,w_,h_);
    this.title = title;
  }
  
  void setAction(Action<Button> action)
  {
    this.action = action;
  }
  
  void drawContent(float lx, float ly)
  {
    strokeWeight(1);
    stroke(fgColor);
    if (pressedView == this && ptInRect(lx, ly, 0, 0, w, h)) {
      fill(128);
    } else {
      noFill();
    }
    rect(0, 0, w, h);
    
    fill(fgColor);
    textAlign(CENTER, CENTER);
    text(title, w/2, h/2);
  }
  
  boolean contentClicked(float lx, float ly)
  {
    if (action != null) action.respond(this);
    return true;
  }
}

