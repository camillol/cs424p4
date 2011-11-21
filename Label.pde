class Label extends View {
  String label;
  color fgColor = 255;
  int align = LEFT;
  final static int MARGIN = 3;
  
  Label(float x_, float y_, float w_, float h_, String label, int align)
  {
    super(x_,y_,w_,h_);
    this.label = label;
    this.align = align;
  }

  Label(float x_, float y_, float w_, float h_, String label)
  {
    this(x_,y_,w_,h_, label, LEFT);
  }
  
  void drawContent(float lx, float ly)
  {
/*    strokeWeight(1);
    stroke(fgColor);
    noFill();
    rect(0, 0, w, h);
    */
    textAlign(align, CENTER);
    fill(fgColor);
    text(label, MARGIN, 0, w-MARGIN*2, h);
  }
}

