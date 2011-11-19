View rootView;

PApplet papplet;

color backgroundColor = 0;
color textColor = 255;

void setup()
{
  size(1024, 768);
//  setupG2D();
  
  papplet = this;
  
  smooth();

  /* load data */
  if (sketchPath == null)  // applet
    ;//data = new WebDataSource("http://young-mountain-2805.heroku.com/");  //dataPath("jsontest")
  else  // application
    ;//data = new SQLiteDataSource();  
  
  /* setup UI */
  rootView = new View(0, 0, width, height);
  
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

void listClicked(ListBox lb, int index, Object item)
{
  
}

