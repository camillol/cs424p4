View rootView;

PApplet papplet;

color backgroundColor = 0;
color textColor = 255;

WebDataSource data;

CheckBox testCB;

void setup()
{
  size(1024, 768);
//  setupG2D();
  
  papplet = this;
  
  smooth();

  /* load data */
  data = new WebDataSource("http://radiogaga.heroku.com/");
  
  /* setup UI */
  rootView = new View(0, 0, width, height);
  
  testCB = new CheckBox(100, 100, 20, 20);
  rootView.subviews.add(testCB);
  
  // I want to add true multitouch support, but let's have this as a stopgap for now
  addMouseWheelListener(new java.awt.event.MouseWheelListener() {
    public void mouseWheelMoved(java.awt.event.MouseWheelEvent evt) {
      rootView.mouseWheel(mouseX, mouseY, evt.getWheelRotation());
    }
  });
}

void draw()
{
  background(backgroundColor); 
  Animator.updateAll();
  
  rootView.draw(); 
}

void mousePressed()
{
  rootView.mousePressed(mouseX, mouseY);
}

void mouseDragged()
{
  rootView.mouseDragged(mouseX, mouseY);
}

void mouseClicked()
{
  rootView.mouseClicked(mouseX, mouseY);
}

void mouseReleased()
{
}

void buttonClicked(CheckBox cb)
{
  
}

void listClicked(ListBox lb, int index, Object item)
{
  
}

