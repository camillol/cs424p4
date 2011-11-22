import java.util.*;

class ArtistDetailView extends View {
  class ArtistInfo implements TableDataSource{
      Artist artist;
      ArtistInfo(Artist artist){
        this.artist = artist;
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
  
  Artist artist; 
  PImage artist_image;
  PieChart genderPieChart;
  TableView artist_info;
  
  ArtistDetailView(float x_, float y_, float w_, float h_){
    super(x_,y_,w_,h_);
    
    genderPieChart = new PieChart(COLUMN_2, ROW_2, 200, 200, new MissingPieChartDataSource("no data"), true, "Listeners by gender");
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
      artist_image = data.getMissingImage();
      genderPieChart.data = new MissingPieChartDataSource("no data");
      artist_info.data = new MissingTableDataSource("no data");
    } else {
      ArrayList<String> image_urls = artist.getImageUrls();
      if(image_urls.size() > 0) artist_image = loadImage(image_urls.get(0), "jpg");
      else artist_image = data.getMissingImage();
      genderPieChart.data = artist.getGenderBreakdown();
      artist_info.data = new ArtistInfo(artist);
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
  
  void drawImage(){ 
    if(artist_image!=null)
      image(artist_image, COLUMN_1, ROW_2);
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
