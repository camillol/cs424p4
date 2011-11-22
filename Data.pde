import org.json.*;
import java.util.*;
import java.util.concurrent.*;

String missingImageUrl(){
  return host + "assets/photo_not_available.jpg";
}
public Artist findArtist(int id){
  String request = host + "artists/" + id + ".json";
  println(request);
  try {
    JSONObject result = new JSONObject(join(loadStrings(request), ""));
    return new Artist(result.getInt("id"), result.getString("mbid"), result.getString("name"));
  }
  catch (JSONException e) {
       println (e);
  }
  return null;
}

class Artist {
  int id;
  String mbid;
  String name;
  String image_url;
  PImage image;
  
  ArtistAgeBreakdown age_breakdown;
  ArrayList<Artist> similar;
  public int user_count=0,song_count=0;
  ArtistGenderBreakdown genderBreakdown = null;
  Map<Country,Integer> countryBreakdown = null;
  
  public boolean user_count_set = false, song_count_set=false;
  Artist(String mbid, String name, String image_url){
    this.mbid = mbid;
    this.name = name;
    this.image_url = image_url;
  }

  Artist(int id, String mbid, String name) {
    this.id = id;
    this.mbid = mbid;
    this.name = name;
  }

  PImage getImage(){
    if(image == null){
      if(image_url == null){
        ArrayList<String> image_urls = this.getImageUrls();
        if(image_urls.size() > 0) 
          image_url = image_urls.get(0);
        else
          image_url = missingImageUrl();
      }
      image = loadImage(image_url, "jpg");
    }
    return image;
  }

  ArrayList<Artist> similar(){
    if(similar == null){
      similar = new ArrayList<Artist>();
      String request = host + "artists/" + id + "/similar.json";
      println(request);
      try {
        JSONArray result = new JSONArray(join(loadStrings(request), ""));
        for (int i = 0; i < result.length(); i++){
          JSONObject aj = result.getJSONObject(i);
          System.out.println(aj);
          similar.add(new Artist(aj.getString("mbid"), aj.getString("name"), aj.getString("thumbnail")));
        }
      }
      catch (JSONException e) {
        println (e);
      }
    }
    return similar;
  } 
  
  
  ArrayList<String> getImageUrls(){
    return LastFmWrapper.getImageUrls(name);
  }

  int getSongCount(){
    if(!song_count_set){
      String request = host + "artists/" + id + "/songs.json";
      println(request);
      try {
        JSONArray result = new JSONArray(join(loadStrings(request), ""));
        song_count = result.length();
        song_count_set = true;
      }
      catch (JSONException e) {
        println (e);
      }
    }
    return song_count;
  }
  
  Map<Country,Integer> getCountryBreakdown()
  {
    if(countryBreakdown == null) {
      int total = 0;
      String request = host + "artists/" + id + "/users/country_stats.json";
      println(request);
      try {
        JSONArray result = new JSONArray(join(loadStrings(request), ""));
        countryBreakdown = new HashMap<Country, Integer>();
        for (int i = 0; i < result.length(); i++){
          JSONObject aj = result.getJSONObject(i);
          String cc = aj.getString("code");
          int count = aj.getInt("count");
          Country c = data.getCountryByCode(cc);
          println(cc + " " + count + " " + c);
          total += count;
          countryBreakdown.put(c, count);
        }
        if (!user_count_set) {
          user_count = total;
          user_count_set = true;
        }
      }
      catch (JSONException e) {
        println (e);
      }
    }
    return countryBreakdown;
  }
  
  ArtistGenderBreakdown getGenderBreakdown(){
    user_count = 0;
    if(genderBreakdown == null){
      int mCount = 0, fCount = 0, uCount = 0;
      String request = host + "artists/" + id + "/users/gender_stats.json";
      println(request);
      try {
        JSONArray result = new JSONArray(join(loadStrings(request), ""));
        for (int i = 0; i < result.length(); i++){
          JSONObject aj = result.getJSONObject(i);
          String gender = aj.getString("gender");
          int count = aj.getInt("count");
          user_count += count;
          if(gender.equals("null")) uCount = count;
          else if(gender.equals("m")) mCount = count;
          else if(gender.equals("f")) fCount = count;
        }
        genderBreakdown = new ArtistGenderBreakdown(mCount, fCount, uCount);
      }
      catch (JSONException e) {
        println (e);
      }
    }
    user_count_set = true;
    return genderBreakdown;
  }

  ArtistAgeBreakdown getAgeBreakdown(){
    if(age_breakdown == null){
      age_breakdown = new ArtistAgeBreakdown();
      String request = host + "artists/" + id + "/users/age_stats.json";
      println(request);
      try {
        JSONArray result = new JSONArray(join(loadStrings(request), ""));
        for (int i = 0; i < result.length(); i++){
          JSONObject aj = result.getJSONObject(i);
          System.out.println(aj);
          age_breakdown.add(new ArtistAgeBreakdownEntry(aj.getString("age_range"), aj.getInt("count")));
        }
      }
      catch (JSONException e) {
        println (e);
      }
    }
    return age_breakdown;
  }

  int getUserCount(){
    if(!user_count_set){
      String request = host + "artists/" + id + "/users.json";
      println(request);
      try {
        JSONArray result = new JSONArray(join(loadStrings(request), ""));
        user_count = result.length();
        user_count_set = true;
        
      }
      catch (JSONException e) {
        println (e);
      }
    }
    return user_count;
  }
}

final static int MALE = 1;
final static int FEMALE = 2;
final static int UNKNOWN = 4;
final static int DONTCARE = -1;

public String getGenderName(int gender){
  switch(gender){
    case MALE: return "Male";
    case FEMALE: return "Female";
    case UNKNOWN: return "Unknown";
    case DONTCARE: return "Don't care";
    default: return "";
  }
}

class User {
  String name;
  int id;
  String ref;
  int age;
  int gender;
  Country country;
  
  User(int id, String ref, String name, int age, int gender, Country country) {
    this.name = name;
    this.id = id;
    this.ref = ref;
    this.age = age;
    this.gender = gender;
    this.country = country;
  }
}

class UserFilter {
  int gender;
  int ageMin, ageMax;
  Country country;
  
  UserFilter(int gender, int ageMin, int ageMax, Country country) {
    this.gender = gender;
    this.ageMin = ageMin;
    this.ageMax = ageMax;
    this.country = country;
  }
  
  UserFilter() {
    gender = DONTCARE;
    ageMin = DONTCARE;
    ageMax = DONTCARE;
    country = null;
  }
  
  String queryString()
  {
    List<String> params = new ArrayList<String>();
    String genderQ = "";
    if ((gender & MALE) != 0) genderQ += "m";
    if ((gender & FEMALE) != 0) genderQ += "f";
    if ((gender & UNKNOWN) != 0) genderQ += "u";
    if (genderQ.length() < 3 && genderQ.length() > 0) params.add("gender=" + genderQ);
    
    if (ageMin != DONTCARE) params.add("ageMin=" + ageMin);
    if (ageMax != DONTCARE) params.add("ageMax=" + ageMax);
    
    if (country != null) params.add("country=" + country.id);
    
    if (params.size() > 0) {
      String paramString = "?";
      boolean first = true;
      for (String p : params) {
        if (first) first = false;
        else paramString += "&";
        paramString += p;
      }
      return paramString;
    }
    else return "";
  }
}

class Country {
  int id;
  String name;
  String code;
  int plays;
  
  Country(int id, String name, String code, int plays) {
    this.name = name;
    this.id = id;
    this.code = code;
    this.plays = plays;
  }
}

class Song {
  int id;
  String ref;
  String title;
  Artist artist;
  
  Song(int id, String ref, String title, Artist artist) {
    this.title = title;
    this.id = id;
    this.ref = ref;
    this.artist = artist;
  }
}



class ArtistChartEntry {
  Artist artist;
  int playCount;
  
  ArtistChartEntry(Artist artist, int playCount) {
    this.artist = artist;
    this.playCount = playCount;
  }
}

class ArtistGenderBreakdown implements PieChartDataSource {
  int mCount, fCount, uCount;
  ArtistGenderBreakdown(int mCount, int fCount, int uCount){
    this.mCount = mCount;
    this.fCount = fCount;
    this.uCount = uCount;
  }
  
  String getLabel(int index) {
    if (index == 0) return "Male (" + mCount + ")";
    else if (index == 1) return "Female (" + fCount + ")";
    else return "Unknown (" + uCount + ")";
  }
  float getValue(int index) {
    if (index == 0) return mCount;
    else if (index == 1) return fCount;
    else return uCount;
  }
  int count() { return 3; }
  float getTotal() {
    return mCount + fCount + uCount;
  }
  color getColor(int index) {
    return int(index / 3.0 * 255.0);
  }
}

class ArtistAgeBreakdownEntry {
  public String ageRange;
  public int count;
  ArtistAgeBreakdownEntry(String ageRange, int count){
    this.ageRange = ageRange;
    this.count = count;
  }
}
class ArtistAgeBreakdown implements BarChartDataSource {
  List<ArtistAgeBreakdownEntry> ranges;
  int maxCount;
  ArtistAgeBreakdown() {
    ranges = new ArrayList<ArtistAgeBreakdownEntry>();
    maxCount = 0;
  }
  
  void add(ArtistAgeBreakdownEntry e)
  {
    ranges.add(e);
    maxCount = max(maxCount, e.count);
  }

  String getLabel(int index) { return ranges.get(index).ageRange; }
  float getValue(int index) { return ranges.get(index).count; }
  public int count() { return ranges.size(); }
  public float getMaxValue() { return maxCount; }
  public color getColor(int index) { int x = (int)(((float)(index+1) / ranges.size()) * 255); return x; }
}

class WebDataSource {
  String baseURL;
  ExecutorService loadExec;
  
  List<Country> countries;
  Map<String, Country> countryCodeMap;
  
  PImage missingImage = null;
  
  WebDataSource(String baseURL)
  {
    this.baseURL = baseURL;
    loadExec = Executors.newCachedThreadPool();
    getCountries();
  }
  
  String loadRequest(String request)
  {
    try {
      InputStream is = createInput(request);
      if (is == null) return null;
      BufferedReader reader = new BufferedReader(new InputStreamReader(is, "UTF-8"));
      StringBuffer buf = new StringBuffer();
      String line = null;
      while ((line = reader.readLine()) != null) {
        buf.append(line);
      }
      reader.close();
      return buf.toString();
    } catch (IOException e) {
      println(e);
      return null;
    }
  }
  
  List<Country> getCountries()
  {
    if (countries == null) {
      String request = baseURL + "countries.json";
      println(request);
      
      try {
        JSONArray result = new JSONArray(loadRequest(request));
        countries = new ArrayList<Country>(239);
        for (int i = 0; i < result.length(); i++) {
          JSONObject aj = result.getJSONObject(i);
          countries.add(new Country(aj.getInt("id"), aj.getString("name"), aj.getString("code"), aj.getInt("plays")));
        }
      }
      catch (JSONException e) {
        println (e);
      }
      catch (NullPointerException e) {
        
      }
      if (countries != null) {
        countryCodeMap = new HashMap<String, Country>(countries.size());
        for (Country c : countries) countryCodeMap.put(c.code, c);
      }
    }
    return countries;
  }
  
  Country getCountryNamed(String name)
  {
    for (Country c : getCountries()) {
      if (c.name.equalsIgnoreCase(name)) return c;
    }
    return null;
  }
  
  Country getCountryByCode(String code)
  {
    getCountries();
    return countryCodeMap.get(code);
  }
  
  Future<List<ArtistChartEntry>> getTopArtists(final UserFilter userFilter)
  {
    return loadExec.submit(new Callable<List<ArtistChartEntry>>() {
      public List<ArtistChartEntry> call() {
        List<ArtistChartEntry> entries = new ArrayList<ArtistChartEntry>(10);
        String request = baseURL + "top_artists" + userFilter.queryString();
        println(request);
        
        try {
          JSONArray result = new JSONArray(loadRequest(request));
          for (int i = 0; i < result.length(); i++) {
            JSONObject aj = result.getJSONObject(i);
            Artist artist = new Artist(aj.getInt("id"), aj.getString("mbid"), aj.getString("name"));
            entries.add(new ArtistChartEntry(artist, aj.getInt("plays")));
          }
        }
        catch (JSONException e) {
          println (e);
        }
        return entries;
      }
    });
  }
  PImage getMissingImage()
  {
    if (missingImage == null) {
      missingImage = loadImage(missingImageUrl(), "jpg");
    }
    return missingImage;
  }
}

class mbArtist{
  String name;
  String begin;
  String end; 
  mbArtist(String n, String b, String end){
    this.name = n;
    this.begin = b;
    this.end = end;
  }
  
}
String songtoMbid(String song){
  XMLElement xml;
  String request = "http://musicbrainz.org/ws/2/recording/?query=" + song;
  xml = new XMLElement(this, request);
  return xml.getChild(0).getChild(0).getString("id");

}
 mbArtist mbidtoArtist(String mbid){
     XMLElement xml;
    String testentry = "b10bbbfc-cf9e-42e0-be17-e2c3e1d2600d";
    String request =  "http://musicbrainz.org/ws/2/artist/" + mbid;  
    xml = new XMLElement(this, request);
    println(xml.getChild(0).getChild(0).getContent() +  xml.getChild(0).getChild(3).getChild(0).getContent() + xml.getChild(0).getChild(3).getChild(1).getContent());
    return new mbArtist(xml.getChild(0).getChild(0).getContent(), 
                    xml.getChild(0).getChild(3).getChild(0).getContent(), 
                    xml.getChild(0).getChild(3).getChild(1).getContent());
}

