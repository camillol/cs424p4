class Checkbox extends Button {
  boolean checked = false;
  
  final static int INSET = 3;
  
  Checkbox(float x_, float y_, float w_, float h_)
  {
    super(x_,y_,w_,h_,"");
  }
  
  void drawContent(float lx, float ly)
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
    super.contentClicked(lx,ly);
    return true;
  }
}

class GlyphCheckbox extends Checkbox {
  String glyph;
  GlyphCheckbox(float x_, float y_, float w_, float h_, String glyph)
  {
    super(x_,y_,w_,h_);
    this.glyph = glyph;
  }
  
  void drawContent(float lx, float ly) {
    super.drawContent(lx, ly);
    if (checked) fill(0);
    else fill(fgColor);
    textAlign(CENTER, CENTER);
    text(glyph, 0, 0, w, h);
  }
}

