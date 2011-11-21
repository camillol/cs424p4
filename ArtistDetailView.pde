import java.util.*;

class ArtistDetailView extends View {
  
  int ROW_1 = 50;
  int ROW_2 = 100;
  int COLUMN_1 = 20;
  int COLUMN_2 = 400;
  
  Artist artist; 
  PImage artist_image;
  String photo_not_available = host + "assets/photo_not_available.jpg";

  
  ArtistDetailView(float x_, float y_, float w_, float h_, Artist artist){
    super(x_,y_,w_,h_);
    this.artist = artist;
    
    ArrayList<String> image_urls = artist.getImageUrls();
    String image_url = photo_not_available;
    if(image_urls.size() > 0)
      image_url = image_urls.get(0);
    artist_image = loadImage(image_url, "jpg");
    createChartPopularityByAge();
    
  }
  
  void drawTitle(){
    textAlign(BOTTOM);
    fill(200);
    textSize(40);
    text(artist.name, COLUMN_1,ROW_1);
  }
  
  void drawImage(){ 
    if(artist_image!=null)
      image(artist_image, COLUMN_1, ROW_2);
  }

  void drawSongs(){
    
  }
  
  void drawFacts(){
    
  }
  
  void createChartPopularityByAge(){
    ArrayList<ArtistGenderBreakdown> gender_breakdown = artist.getGenderBreakdown(); 
    ArrayList<Integer> angles = new ArrayList<Integer>(gender_breakdown.size());
    ArrayList<String> labels  = new ArrayList<String>(gender_breakdown.size());
    for( ArtistGenderBreakdown br : gender_breakdown){
      angles.add( new Integer(round(((float)br.count) / artist.user_count * 360)));
      labels.add(getGenderName(br.gender) + " (" + br.count + ")");
    }
    PieChart genderPieChart = new PieChart(COLUMN_2,ROW_2,200,200, labels, angles, PieChart.CHART_TYPE_GENDER, "Listeners by gender");
    this.subviews.add(genderPieChart);
  }
  
  void drawContent(float lx, float ly){
    drawTitle();
    drawImage();
    drawSongs();
    drawFacts();
    
  }
}
