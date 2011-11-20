View rootView;

View pressedView = null;
View focusView = null;

PApplet papplet;

color backgroundColor = 0;
color textColor = 255;

WebDataSource data;

Checkbox testCB;

void setup()
{
  size(1024, 768);
//  setupG2D();
  
  papplet = this;
  
  smooth();

  /* load data */
  if (false) data = new WebDataSource("http://localhost:3000/");
  else data = new WebDataSource("http://radiogaga.heroku.com/");
  
  /* setup UI */
  rootView = new View(0, 0, width, height);
  
  testCB = new Checkbox(100, 400, 20, 20);
  testCB.setAction(new Action<Button>() {
    public void respond(Button b) {
      Checkbox cb = (Checkbox)b;
      println(cb.checked);
    }
  });
  rootView.subviews.add(testCB);
  
  Button testB = new Button(100, 500, 120, 20, "hello");
  testB.setAction(new Action<Button>() {
    public void respond(Button b) {
      println(b.title);
    }
  });
  rootView.subviews.add(testB);
  
  TextField testTF = new TextField(200, 500, 150, 20);
  rootView.subviews.add(testTF);
  TextField testTF2 = new TextField(200, 540, 150, 20);
  rootView.subviews.add(testTF2);
  
  TopArtistView topArtists = new TopArtistView(20, 20, 400, 220);
  rootView.subviews.add(topArtists);  
  
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
  
  rootView.draw(mouseX, mouseY);
}

void mousePressed()
{
  pressedView = rootView.mousePressed(mouseX, mouseY);
}

void mouseDragged()
{
  rootView.mouseDragged(mouseX, mouseY);
}

void mouseReleased()
{
  pressedView = null;
}

void mouseClicked()
{
  rootView.mouseClicked(mouseX, mouseY);
}

void keyTyped()
{
  if (focusView != null) focusView.keyTyped();
}

