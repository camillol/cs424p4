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
          fill(lerpColor(#000000, #ff0000, 1.0*count/artist.getCountryBreakdown().maxCount));
        } else {
          fill(0);
        }
        super.drawCountry(cShape, cc);
      }
    };
    this.subviews.add(mapView);
    
    similar_artist_table = new TableView(COLUMN_3, ROW_1, 300, 400, Arrays.asList(
      new TableColumn("Name", 100), new TableColumn("Image", 100, true)), new MissingTableDataSource("no data"));
    similar_artist_table.setRowHeight(200);
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
      similar_artist_table.data = new AsyncTableDataSource(data.getSimilarArtists(artist, null));
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
