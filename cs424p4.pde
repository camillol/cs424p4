View rootView;

View pressedView = null;
View focusView = null;

PApplet papplet;

color backgroundColor = 0;
color textColor = 255;
color borderColor = 128;

WebDataSource data;

Checkbox testCB;

PFont font;

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
  font = loadFont("Helvetica-14.vlw");
  textFont(font);
  
  rootView = new View(0, 0, width, height);
  
  TopArtistView topArtistsA = new TopArtistView(20, 20, 460, 240, new UserFilter());
  rootView.subviews.add(topArtistsA);  

  UserFilter demoFilter = new UserFilter();
  demoFilter.country = data.getCountryNamed("United States");
  demoFilter.ageMin = 20;
  demoFilter.ageMax = 30;
  demoFilter.gender = FEMALE;
  TopArtistView topArtistsB = new TopArtistView(20, 300, 460, 240, demoFilter);
  rootView.subviews.add(topArtistsB);  
  
  // I want to add true multitouch support, but let's have this as a stopgap for now
  addMouseWheelListener(new java.awt.event.MouseWheelListener() {
    public void mouseWheelMoved(java.awt.event.MouseWheelEvent evt) {
      rootView.mouseWheel(mouseX, mouseY, evt.getWheelRotation());
    }
  });
  
//  mbidtoArtist("b10bbbfc-cf9e-42e0-be17-e2c3e1d2600d");
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

