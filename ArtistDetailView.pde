import java.util.*;

class ArtistDetailView extends View {
  class SimilarArtistEntry implements TableDataSource{
    ArrayList<Artist> artists;

    SimilarArtistEntry(ArrayList<Artist> artists){
      this.artists = artists;
    }
    String getText(int index, int column){
      Artist artist = artists.get(index);
      if(column == 0){
        return artist.name;
      }
      else{
        return artist.image_url;
      }
    }

    PImage getImage(int index, int column){
      Artist artist = artists.get(index);
      if(column == 1){
        return artist.getImage();
      }
      else{
        return null;
      }
    }

    Object get(int index){
        return new Object();
    }

    int count(){
      return artists.size();
    }
    boolean selected(int index){
      return false;
    }
  }

  int ROW_1 = 50;
  int ROW_2 = 100;
  int ROW_3 = 400;
  int COLUMN_1 = 20;
  int COLUMN_2 = 400;
  int COLUMN_3 = 500;
  
  Artist artist; 
  PieChart genderPieChart;
  TableView artist_info;
  BarChart age_chart;
  MapView mapView;
  
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
      public void drawCountry(PShape cShape, String cc) {
        Country c = data.getCountryByCode(cc);
        if (c != null && artist != null && artist.getCountryBreakdown() != null) {
          Integer countInt = artist.getCountryBreakdown().get(c);
          int count = countInt == null ? 0 : countInt;
          fill(lerpColor(#ffffff, #ff0000, 1.0*count/artist.user_count));
        } else {
          fill(#eeeeee);
        }
        super.drawCountry(cShape, cc);
      }
    };
    this.subviews.add(mapView);

    setArtist(null);
  }
  
  void setArtist(Artist a)
  {
    artist = a;
    if (artist == null) {
      genderPieChart.data = new MissingPieChartDataSource("no data");
      artist_info.data = new MissingTableDataSource("no data");
      age_chart.data = new MissingBarChartDataSource("no data");
    } else {
      genderPieChart.data = new AsyncPieChartDataSource(artist.getGenderBreakdown());
      artist_info.data = new AsyncTableDataSource(data.getArtistInfo(artist));
      age_chart.data = new AsyncBarChartDataSource(artist.getAgeBreakdown());
      addSimilarArtistsTable();
    }
  }
  
  String getTitle()
  {
    if (artist == null) return "<no artist>";
    else return artist.name;
  }

  void addSimilarArtistsTable(){
  
    ArrayList<Artist> similar = artist.similar();
    System.out.println("SIZE OF SIMILAR ITEMS: " + similar.size());
    TableView similar_artist_table = new TableView(COLUMN_3, ROW_1, 300, 400, Arrays.asList(
      new TableColumn("Name", 100), new TableColumn("Image", 100, true)), new SimilarArtistEntry(similar));
    similar_artist_table.setRowHeight(200);
    this.subviews.add(similar_artist_table);
  }

  void drawTitle(){
    textAlign(BOTTOM);
    fill(200);
    textSize(40);
    text(getTitle(), COLUMN_1,ROW_1);
    textSize(normalFontSize);
  }
  
  void drawImage(){ 
    if(artist!=null)
      image(artist.getImage(), COLUMN_1, ROW_2);
  }
  
  void drawContent(float lx, float ly){
    drawTitle();
    drawImage();   
  }
}
