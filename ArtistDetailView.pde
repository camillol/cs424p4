import java.util.*;

class ArtistDetailView extends View {
  
  int ROW_1 = 50;
  int ROW_2 = 100;
  int ROW_3 = 400;
  int COLUMN_1 = 20;
  int COLUMN_2 = 400;
  int COLUMN_3 = 500;
  
  final static int IMAGE_WIDTH = 200;
  final static int IMAGE_HEIGHT = 200;
  
  Artist artist; 
  PieChart genderPieChart;
  TableView artist_info;
  BarChart age_chart;
  MapView mapView;
  TableView similar_artist_table;
  UserFilterView ufView;
  
  ArtistDetailView(float x_, float y_, float w_, float h_){
    super(x_,y_,w_,h_);
    
    genderPieChart = new PieChart(COLUMN_2, ROW_2, 200, 200, new MissingPieChartDataSource("no data"), true, "Listeners by gender");
    this.subviews.add(genderPieChart);
    
    artist_info = new TableView(COLUMN_1, ROW_3, 400, 200, Arrays.asList(
      new TableColumn("Fact", 100), new TableColumn("Value", 100)), new MissingTableDataSource("no data"));
    this.subviews.add(artist_info);
    
    age_chart = new BarChart(COLUMN_2, ROW_3, 400, 200, new MissingBarChartDataSource("no data"), true, true);
    age_chart.setTitle("Users count by age");
    this.subviews.add(age_chart);
    
    mapView = new MapView(300,400,400,220) {
      public void drawOcean(PShape oShape) {
        fill(#333344);
        shape(oShape, 0, 0);
      }
      public void drawCountry(PShape cShape, String cc) {
        Country c = data.getCountryByCode(cc);
        if (c != null && artist != null && artist.getCountryBreakdown() != null) {
          int count = artist.getCountryBreakdown().get(c);
          fill(lerpColor(#000000, #ff0000, 1.0*count/c.users));
        } else {
          fill(0);
        }
        super.drawCountry(cShape, cc);
      }
    };
    this.subviews.add(mapView);
    
    ufView = new UserFilterView(COLUMN_3, ROW_1-20,  300, 20, new UserFilter());
    ufView.setAction(new Action<UserFilterView>() {
      public void respond(UserFilterView ufv) {
        if (artist != null) similar_artist_table.data = new AsyncTableDataSource(data.getSimilarArtists(artist, ufView.userFilter));
      }
    });
    subviews.add(ufView);
    
    similar_artist_table = new TableView(COLUMN_3, ROW_1, 300, 400, Arrays.asList(
      new TableColumn("Name", 100), new TableColumn("Image", 100, true)), new MissingTableDataSource("no data"));
    similar_artist_table.setRowHeight(200);
    similar_artist_table.action = new TableAction() {
      public void itemClicked(TableView tv, int index, Object item) {
        Artist artist = (Artist)item;
        showArtistDetails(artist);
      }
    };
    this.subviews.add(similar_artist_table);

    setArtist(null);
  }
  
  void setArtist(Artist a)
  {
    artist = a;
    if (artist == null) {
      genderPieChart.data = new MissingPieChartDataSource("no data");
      artist_info.data = new MissingTableDataSource("no data");
      age_chart.data = new MissingBarChartDataSource("no data");
      similar_artist_table.data = new MissingTableDataSource("no data");
    } else {
      genderPieChart.data = new AsyncPieChartDataSource(artist.getGenderBreakdown());
      artist_info.data = new AsyncTableDataSource(data.getArtistInfo(artist));
      age_chart.data = new AsyncBarChartDataSource(artist.getAgeBreakdown());
      similar_artist_table.data = new AsyncTableDataSource(data.getSimilarArtists(artist, ufView.userFilter));
    }
  }
  
  String getTitle()
  {
    if (artist == null) return "<no artist>";
    else return artist.name;
  }

  void drawTitle(){
    textAlign(BOTTOM);
    fill(200);
    textSize(40);
    text(getTitle(), COLUMN_1,ROW_1);
    textSize(normalFontSize);
  }
  
  void drawImageInRect(PImage img, float x, float y, float w, float h)
  {
    float s = min(w/img.width, h/img.height);
    float iw = img.width*s;
    float ih = img.height*s;
    image(img, x + (w-iw)/2, y + (h-ih)/2, iw, ih);
  }
  
  void drawImage(){
    rect(COLUMN_1, ROW_2, IMAGE_WIDTH, IMAGE_HEIGHT);
    if(artist != null) {
      drawImageInRect(artist.getImage(), COLUMN_1, ROW_2, IMAGE_WIDTH, IMAGE_HEIGHT);
    }
  }
  
  void drawContent(float lx, float ly){
    drawTitle();
    drawImage();   
  }
}

class SongDetailView extends View {
  TextField searchField;
  Button searchButton;
  TableView searchResults;
  
  Song song;
  
  SongDetailView(float x_, float y_, float w_, float h_){
    super(x_,y_,w_,h_);
    
    song = null;
    
    searchField = new TextField(20, 20, 300, 20);
    subviews.add(searchField);
    
    searchButton = new Button(320, 20, 100, 20, "Search");
    searchButton.setAction(new Action<Button>() {
      public void respond(Button b) {
        searchResults.data = new AsyncTableDataSource(data.searchSongs(searchField.value));
      }
    });
    subviews.add(searchButton);
    
    searchResults = new TableView(20, 40, 400, 100, Arrays.asList(
      new TableColumn("Name", 100), new TableColumn("Artist", 100)), new MissingTableDataSource("no data"));
    this.subviews.add(searchResults);
  }
  
  String getTitle()
  {
    if (song == null) return "<no song>";
    else return song.title;
  }

  void drawTitle(){
    textAlign(TOP);
    fill(200);
    textSize(40);
    text(getTitle(), 20, 180);
    textSize(normalFontSize);
  }
  
  void drawContent(float lx, float ly){
    drawTitle();
  }
}


