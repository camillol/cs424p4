import org.json.*;
import java.util.*;

class Artist {
  int id;
  String mbid;
  String name;
  
  ArrayList<ArtistGenderBreakdown> gender_breakdown;
  public int user_count=0;
  Artist(int id, String mbid, String name) {
    this.id = id;
    this.mbid = mbid;
    this.name = name;
  }
  
  ArrayList<String> getImageUrls(){
    return LastFmWrapper.getImageUrls(name);
    
  }

  ArrayList<ArtistGenderBreakdown> getGenderBreakdown(){
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
    String genderQ = "";
    if ((gender & MALE) != 0) genderQ += "m";
    if ((gender & FEMALE) != 0) genderQ += "f";
    if ((gender & UNKNOWN) != 0) genderQ += "u";
    if (genderQ.length() < 3 && genderQ.length() > 0) return "?gender=" + genderQ;
    else return "";
  }
}

class Country {
  int id;
  String name;
  
  Country(int id, String name) {
    this.name = name;
    this.id = id;
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

class WebDataSource {
  String baseURL;
  
  WebDataSource(String baseURL)
  {
    this.baseURL = baseURL;
  }
  
  List<ArtistChartEntry> getTopArtists(UserFilter userFilter)
  {
    List<ArtistChartEntry> entries = new ArrayList<ArtistChartEntry>(10);
    String request = baseURL + "top_artists" + userFilter.queryString();
    println(request);
    try {
      JSONArray result = new JSONArray(join(loadStrings(request), ""));
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
}

