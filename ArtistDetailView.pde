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
  
  final static int SIMILAR_WIDTH = 440;
  final static int SIMILAR_HEIGHT = 200;
  
  final static int MAP_WIDTH = 400;
  final static int MAP_HEIGHT = 220;
  
  final static int AGE_HEIGHT = 200;
  
  final static int INFO_WIDTH = 280;
  
  Artist artist; 
  PieChart genderPieChart;
  TableView artist_info;
  BarChart age_chart;
  MapView mapView;
  TableView similar_artist_table;
  UserFilterView ufView;
  TableView songTable;
  
  ArtistDetailView(float x_, float y_, float w_, float h_){
    super(x_,y_,w_,h_);
    
    genderPieChart = new PieChart(w-300, 40, 200, 200, new MissingPieChartDataSource("no data"), true, "Listeners by gender");
    this.subviews.add(genderPieChart);
    
    artist_info = new TableView(240, 100, INFO_WIDTH, 340, Arrays.asList(
      new TableColumn("Fact", INFO_WIDTH*0.4), new TableColumn("Value", INFO_WIDTH*0.6)), new MissingTableDataSource("no data"));
    artist_info.borderColor = 0;
    this.subviews.add(artist_info);
    
    age_chart = new BarChart(w-MAP_WIDTH-20, h-MAP_HEIGHT - AGE_HEIGHT - 40, MAP_WIDTH, AGE_HEIGHT, new MissingBarChartDataSource("no data"), true, true);
    age_chart.setTitle("Users count by age");
    this.subviews.add(age_chart);
    
    mapView = new MapView(w-MAP_WIDTH-20,h-MAP_HEIGHT-20,MAP_WIDTH,MAP_HEIGHT) {
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
    
    songTable = new TableView(20, h-SIMILAR_HEIGHT-60 - 220, 400, 200, Arrays.asList(
      new TableColumn("Title", 200)), new MissingTableDataSource("no data"));
    songTable.action = new TableAction() {
      public void itemClicked(TableView tv, int index, Object item) {
        Song song = (Song)item;
        showSongDetails(song);
      }
    };
    this.subviews.add(songTable);
    
    
    subviews.add(new Label(20, h-SIMILAR_HEIGHT-60, SIMILAR_WIDTH, 20, "Similar"));

    ufView = new UserFilterView(20, h-SIMILAR_HEIGHT-40,  SIMILAR_WIDTH, 20, new UserFilter());
    ufView.setAction(new Action<UserFilterView>() {
      public void respond(UserFilterView ufv) {
        if (artist != null) similar_artist_table.data = new AsyncTableDataSource(data.getSimilarArtists(artist, ufView.userFilter));
      }
    });
    subviews.add(ufView);
    
    similar_artist_table = new TableView(20, h-SIMILAR_HEIGHT-20, SIMILAR_WIDTH, SIMILAR_HEIGHT, Arrays.asList(
      new TableColumn("Name", SIMILAR_WIDTH*0.8), new TableColumn("Image", SIMILAR_WIDTH*0.2, true)), new MissingTableDataSource("no data"));
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
      songTable.data = new MissingTableDataSource("no data");
    } else {
      genderPieChart.data = new AsyncPieChartDataSource(artist.getGenderBreakdown());
      artist_info.data = new AsyncTableDataSource(data.getArtistInfo(artist));
      age_chart.data = new AsyncBarChartDataSource(artist.getAgeBreakdown());
      similar_artist_table.data = new AsyncTableDataSource(data.getSimilarArtists(artist, ufView.userFilter));
      songTable.data = new AsyncTableDataSource(data.getArtistSongs(artist));
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
    text(getTitle(), 240, 60);
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
    rect(20, 40, IMAGE_WIDTH, IMAGE_HEIGHT);
    if(artist != null) {
      drawImageInRect(artist.getImage(), 20, 40, IMAGE_WIDTH, IMAGE_HEIGHT);
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
  TableView songInfo;
  
  Song song;
  
  final static int INFO_WIDTH = 400;
  
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
      new TableColumn("Title", 300), new TableColumn("Artist", 100)), new MissingTableDataSource("no data"));
    searchResults.action = new TableAction() {
      public void itemClicked(TableView tv, int index, Object item) {
        Song song = (Song)item;
        showSongDetails(song);
      }
    };
    this.subviews.add(searchResults);
    
    songInfo = new TableView(240, 240, INFO_WIDTH, 340, Arrays.asList(
      new TableColumn("Fact", INFO_WIDTH*0.4), new TableColumn("Value", INFO_WIDTH*0.6)), new MissingTableDataSource("no data"));
//    songInfo.borderColor = 0;
    this.subviews.add(songInfo);
  }
  
  void setSong(Song s)
  {
    song = s;
    if (song == null) {
      songInfo.data = new MissingTableDataSource("no data");
    } else {
      songInfo.data = new AsyncTableDataSource(data.getSongInfo(song));
    }
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


