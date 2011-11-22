import org.json.*;
import java.util.*;
import java.util.concurrent.*;



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
  
  ArrayList<ArtistGenderBreakdown> gender_breakdown;
  ArrayList<ArtistAgeBreakdown> age_breakdown;
  ArrayList<ARtist> similar;
  public int user_count=0,song_count=0;
  
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

  ArrayList<ArtistAgeBreakdown> getAgeBreakdown(){
    if(age_breakdown == null){
      age_breakdown = new ArrayList<ArtistAgeBreakdown>();
      String request = host + "artists/" + id + "/users/age_stats.json";
      println(request);
      try {
        JSONArray result = new JSONArray(join(loadStrings(request), ""));
        for (int i = 0; i < result.length(); i++){
          JSONObject aj = result.getJSONObject(i);
          System.out.println(aj);
          age_breakdown.add(new ArtistAgeBreakdown(aj.getString("age_range"), aj.getInt("count")));
        }
      }
      catch (JSONException e) {
        println (e);
      }
    }
    return age_breakdown;
  }

  ArrayList<ArtistGenderBreakdown> getGenderBreakdown(){
    user_count = 0;
    if(gender_breakdown == null){
      gender_breakdown = new ArrayList<ArtistGenderBreakdown>();
      String request = host + "artists/" + id + "/users/gender_stats.json";
      println(request);
      try {
        JSONArray result = new JSONArray(join(loadStrings(request), ""));
        for (int i = 0; i < result.length(); i++){
          JSONObject aj = result.getJSONObject(i);
          String gender = aj.getString("gender");
          int count = aj.getInt("count");
          user_count+=count;
          if(gender.equals("null")){
            gender_breakdown.add(new ArtistGenderBreakdown(UNKNOWN, count));
          }
          else if(gender.equals("m")){
            gender_breakdown.add(new ArtistGenderBreakdown(MALE, count));
          }
          else if(gender.equals("f")){
            gender_breakdown.add(new ArtistGenderBreakdown(FEMALE, count));
          }
        }
      }
      catch (JSONException e) {
        println (e);
      }
    }
    user_count_set = true;
    return gender_breakdown;
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

class ArtistGenderBreakdown{
  public int gender;
  public int count;
  ArtistGenderBreakdown(int gender, int count){
    this.gender = gender;
    this.count = count;
  }
}

class ArtistAgeBreakdown{
  public String ageRange;
  public int count;
  ArtistAgeBreakdown(String ageRange, int count){
    this.ageRange = ageRange;
    this.count = count;
  }
}

class WebDataSource {
  String baseURL;
  ExecutorService loadExec;
  
  List<Country> countries;
  Map<String, Country> countryCodeMap;
  
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
