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
        return artist.image;
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

  class ArtistInfo implements TableDataSource{
      Artist artist;
      ArtistInfo(Artist artist){
        this.artist = artist;
      }
      
      PImage getImage(int index, int column){
        return null; 
      }
      String getText(int index, int column){
        fill(255);
        if(index == 0){
          if(column==0){
            return "User count";
          }
          else{
            return "" + artist.getUserCount();
          }
        }
         if(index == 1){
          if(column==0){
            return "Song count";
          }
          else{
            int song_count = artist.getSongCount();
            if(song_count == 0)
              return "Not Available";
            else
              return "" + song_count;
          }
        }
        return "TEST";
      }
      Object get(int index){
        return new Object();
      }
      int count(){
        return 10;
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
  int COLUMN_3 = 600;
  
  Artist artist; 
  PieChart genderPieChart;
  TableView artist_info;
  
  ArtistDetailView(float x_, float y_, float w_, float h_){
    super(x_,y_,w_,h_);
    
    genderPieChart = new PieChart(COLUMN_2, ROW_2, 200, 200, new MissingPieChartDataSource(), true, "Listeners by gender");
    this.subviews.add(genderPieChart);
    
    artist_info = new TableView(COLUMN_1, ROW_3, 400, 200, Arrays.asList(
      new TableColumn("Fact", 100), new TableColumn("Value", 100)), new MissingTableDataSource("no data"));
    this.subviews.add(artist_info);

    setArtist(null);
  }
  
  void setArtist(Artist a)
  {
    artist = a;
    if (artist == null) {
      genderPieChart.data = new MissingPieChartDataSource();
      artist_info.data = new MissingTableDataSource("no data");
    } else {
      genderPieChart.data = artist.getGenderBreakdown();
      artist_info.data = new ArtistInfo(artist);
    }
  }
  
  String getTitle()
  {
    if (artist == null) return "<no artist>";
    else return artist.name;
  }
 
  void addAgeChart(){
    ArrayList<ArtistAgeBreakdown> age_breakdown = artist.getAgeBreakdown();
    String [] labels = new String[age_breakdown.size()];
    float [] values = new float[age_breakdown.size()];
    int i=0;
    for(ArtistAgeBreakdown artist_age_breakdown : age_breakdown){
      labels[i] = artist_age_breakdown.ageRange;
      values[i] = artist_age_breakdown.count;
      i++;
    }
    final String barLabels[] = labels;
    final float barValues[] = values;
    BarChart age_chart = new BarChart(COLUMN_2, ROW_3, 400, 200, new BarChartDataSource(){
      public String getLabel(int index) { return barLabels[index]; }
      public float getValue(int index) { return barValues[index]; }
      public int count() { return barLabels.length; }
      public float getMaxValue() { return barValues.length > 0 ? max(barValues) : 0;}
      public color getColor(int index) { int x = (int)(((float)(index+1) / barLabels.length) * 255); System.out.println(x); return x; }
    }, true, true);
    age_chart.setTitle("Users count by age");
    this.subviews.add(age_chart);
  }

  void addSimilarArtistsChart(){
  
    ArrayList<Artist> similar = artist.similar();
    TableView similar_artist_table = new TableView(COLUMN_3, ROW_1, 300, 400, Arrays.asList(
      new TableColumn("Name", 100), new TableColumn("Image", 100, true)), new SimilarArtistEntry(similar));
    this.subviews.add(artist_info);
    
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

  void drawSongs(){
    
  }
  
  void drawFacts(){
    
  }
  
  void drawContent(float lx, float ly){
    drawTitle();
    drawImage();
    drawSongs();
    drawFacts();
    
  }
}
