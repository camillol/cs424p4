View rootView;

View pressedView = null;
View focusView = null;

PApplet papplet;

color backgroundColor = 0;
color textColor = 255;
color borderColor = 128;

WebDataSource data;

Checkbox testCB;
//String host = "http://localhost:3000/"; 
//String host = "http://radiogaga.heroku.com/";

PFont font;
int normalFontSize;

TabView mainTabView;
ArtistDetailView artistDetailView;
SongDetailView songDetailView;

void setup()
{
  size(1024, 768);
//  setupG2D();
  
  papplet = this;
  
  smooth();

  /* load data */
  data = new WebDataSource("http://radiogaga.heroku.com/");
  
  /* setup UI */
  font = loadFont("Helvetica-14.vlw");
  normalFontSize = 14;
  textFont(font);
  textSize(normalFontSize);
  
  rootView = new View(0, 0, width, height);
  
  mainTabView = new TabView(10, 10, width-20, height-20, Arrays.asList("Top Artists", "Artist Details", "Songs", "Time"));
  rootView.subviews.add(mainTabView);
  
  View topArtistsPane = mainTabView.tabs.get(0).pane;
  
  TopArtistView topArtistsA = new TopArtistView(20, 20, 460, 240, new UserFilter());
  topArtistsPane.subviews.add(topArtistsA);  

  UserFilter demoFilter = new UserFilter();
  demoFilter.country = data.getCountryNamed("United States");
  demoFilter.ageMin = 20;
  demoFilter.ageMax = 30;
  demoFilter.gender = FEMALE;
  TopArtistView topArtistsB = new TopArtistView(520, 20, 460, 240, demoFilter);
  //rootView.subviews.add(topArtistsB);  
  topArtistsPane.subviews.add(topArtistsB);
  
  topArtistsPane.subviews.add(new WeeklyTopArtistView(20, 340, 300, 240, 2008, 1));
  
  topArtistsPane.subviews.add(new RankingView(340, 390, 660, 200, new ArtistWeeklyRankSet(2008)));
  
  /*new RankingDataSource() {
    public List get(int time) {
      if (time == 0) return Arrays.asList("a", "b", "c", "d");
      if (time == 1) return Arrays.asList("a", "c", "d", "e");
      return Arrays.asList("c", "e", "a", "d");
    }
    public int times() {return 3;}
  }));*/
  

  View artistDetailPane = mainTabView.tabs.get(1).pane;
  /* Eugine, add artist detail views to artistDetailPane.subviews */
  artistDetailView = new ArtistDetailView(0,0,artistDetailPane.w,artistDetailPane.h);
//  artistDetailView.setArtist(findArtist(4112));
  artistDetailPane.subviews.add(artistDetailView);
  
  View songPane = mainTabView.tabs.get(2).pane;
  songDetailView = new SongDetailView(0,0,songPane.w,songPane.h);
  songPane.subviews.add(songDetailView);
  
/*  View mapTestPane = mainTabView.tabs.get(2).pane;

  final String barLabels[] = {"one", "two", "three"};
  final float barValues[] = {120, 435, 65};
  final float barMax = 435;
  final color barColors[] = {#ff0000, #00ff00, #0000ff};
  mapTestPane.subviews.add(new BarChart(500, 200, 200, 300, new BarChartDataSource(){
    public String getLabel(int index) { return barLabels[index]; }
    public float getValue(int index) { return barValues[index]; }
    public int count() { return barLabels.length; }
    public float getMaxValue() { return barMax; }
    public color getColor(int index) { return barColors[index % barColors.length]; }
  }, true, true));*/
  
  View timePane = mainTabView.tabs.get(3).pane;
  timePane.subviews.add(new Label(40, 20, 300, 20, "Songs played by local time"));
  BarChart timeBarChart = new BarChart(40, 40, 700, 200, new AsyncBarChartDataSource(data.getLocalTimePlays()), true, true);
  timePane.subviews.add(timeBarChart);
  
  final Future<GMTTimePlays> gtpf = data.getGMTTimePlays();
  MapView mapView = new MapView(40,300,700,400) {
    public void drawCountry(PShape cShape, String cc) {
      Country c = data.getCountryByCode(cc);
      fill(#eeeeee);
      if (c != null && gtpf.isDone()) {
        int[] counts;
        try {
          counts = gtpf.get().byCountry.get(c);
          if (counts != null) fill(lerpColor(#ffffff, #ff0000, 1.0*counts[second() % 24]/counts[24]));
        } catch (InterruptedException e) {
          println(e);
        } catch (ExecutionException e) {
          println(e);
        }
      }
      super.drawCountry(cShape, cc);
    }
  };
  timePane.subviews.add(mapView); 
  timePane.subviews.add(new View(760, 360, 100, 100) {
    public void drawContent(float lx, float ly) {
      textSize(30);
      fill(255);
      text("GMT: " + second() % 24, 0, 0);
      textSize(normalFontSize);
    }
  }); 
  
  
  
  // I want to add true multitouch support, but let's have this as a stopgap for now
  addMouseWheelListener(new java.awt.event.MouseWheelListener() {
    public void mouseWheelMoved(java.awt.event.MouseWheelEvent evt) {
      rootView.mouseWheel(mouseX, mouseY, evt.getWheelRotation());
    }
  });
  
//  mbidtoArtist("b10bbbfc-cf9e-42e0-be17-e2c3e1d2600d");
}

void showArtistDetails(Artist artist)
{
  mainTabView.setActiveTab(mainTabView.tabs.get(1));
  artistDetailView.setArtist(artist);
}

void showSongDetails(Song song)
{
  mainTabView.setActiveTab(mainTabView.tabs.get(2));
  songDetailView.setSong(song);
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

