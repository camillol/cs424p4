import org.json.*;
import java.util.*;
import java.util.concurrent.*;

class Artist {
  int id;
  String mbid;
  String name;
  String image_url;
  Future<PImage> image;
  
  Future<ArtistAgeBreakdown> ageBreakdown;
  ArrayList<Artist> similar;
  public int user_count=0,song_count=0;
  Future<ArtistGenderBreakdown> genderBreakdown = null;
  Future<ArtistCountryBreakdown> countryBreakdown = null;
  
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
    if(image == null) image = data.getArtistImage(this);
    if (image.isDone()) try {
      return image.get();
    } catch (InterruptedException e) {
      println(e);
    } catch (ExecutionException e) {
      println("getImage" + e);
//      loadStatus = "Server request failed.";
    }
    return data.getLoadingImage();
  }
  
  
  ArrayList<String> getImageUrls(){
    return LastFmWrapper.getImageUrls(name);
  }

/*  int getSongCount(){
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
  }*/
  
  ArtistCountryBreakdown getCountryBreakdown()
  {
    if (countryBreakdown == null) countryBreakdown = data.getCountryBreakdown(this);
    if (countryBreakdown.isDone()) try {
      return countryBreakdown.get();
    } catch (InterruptedException e) {
      println(e);
    } catch (ExecutionException e) {
      println(e);
//      loadStatus = "Server request failed.";
    }
    return null;
  }
  
  Future<ArtistGenderBreakdown> getGenderBreakdown(){
    if (genderBreakdown == null) genderBreakdown = data.getGenderBreakdown(this);
    return genderBreakdown;
  }

  Future<ArtistAgeBreakdown> getAgeBreakdown(){
    if (ageBreakdown == null) ageBreakdown = data.getAgeBreakdown(this);
    return ageBreakdown;
  }

/*  int getUserCount(){
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
  }*/
}

class JSONDictionarySource implements TableDataSource{
  JSONObject jobj;
  JSONDictionarySource(JSONObject jobj){
    this.jobj = jobj;
  }
  
  PImage getImage(int index, int column){ return null;}
  String getText(int index, int column) {
    try {
      String k = jobj.names().getString(index);
      if (column == 0) return k;
      else return jobj.getString(k);
    } catch (JSONException e) {
      println(e);
      return "";
    }
  }
  Object get(int index){
    return null;
  }
  int count(){
    return jobj.length();
  }
  boolean selected(int index){
    return false;
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
  int users;
  
  Country(int id, String name, String code, int plays, int users) {
    this.name = name;
    this.id = id;
    this.code = code;
    this.plays = plays;
    this.users = users;
  }
}

class Song {
  int id;
  String mbid;
  String title;
  Artist artist;
  
  Song(int id, String mbid, String title, Artist artist) {
    this.title = title;
    this.id = id;
    this.mbid = mbid;
    this.artist = artist;
  }
}

class SongList implements TableDataSource {
  List<Song> songs;
  
  SongList(List<Song> songs) {
    this.songs = songs;
  }
  
  String getText(int index, int column) {
    if (column == 0) return songs.get(index).title;
    else return songs.get(index).artist.name;
  }
  Object get(int index) { return songs.get(index); }
  int count() { return songs.size(); }
  boolean selected(int index) { return false; }
  PImage getImage(int index, int column){ return null; }
}

class ArtistList implements TableDataSource {
  List<Artist> artists;
  
  ArtistList(List<Artist> artists) {
    this.artists = artists;
  }
  
  String getText(int index, int column) {
    if (column == 0) return artists.get(index).name;
    else return artists.get(index).image_url;
  }
  Object get(int index) { return artists.get(index); }
  int count() { return artists.size(); }
  boolean selected(int index) { return false; }
  PImage getImage(int index, int column){ return column == 1 ? artists.get(index).getImage() : null; }
}


class ArtistChartEntry {
  Artist artist;
  int playCount;
  
  ArtistChartEntry(Artist artist, int playCount) {
    this.artist = artist;
    this.playCount = playCount;
  }
}

class ArtistChart implements TableDataSource {
  List<ArtistChartEntry> entries;
  
  ArtistChart(List<ArtistChartEntry> entries) {
    this.entries = entries;
  }
  
  String getText(int index, int column) {
    if (column == 0) return entries.get(index).artist.name;
    else return str(entries.get(index).playCount);
  }
  Object get(int index) { return entries.get(index); }
  int count() { return entries.size(); }
  boolean selected(int index) { return false; }
  PImage getImage(int index, int column){return null;}
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

class ArtistCountryBreakdown {
  Map<Country,Integer> counts;
  int maxCount;
  ArtistCountryBreakdown() {
    counts = new HashMap<Country,Integer>();
    maxCount = 0;
  }
  void put(Country c, int count) {
    counts.put(c,count);
    maxCount = max(maxCount, count);
  }
  int get(Country c) {
    Integer countInt = counts.get(c);
    return countInt == null ? 0 : countInt;
  }
}

class LocalTimePlays implements BarChartDataSource {
  Map<Country, int[]> byCountry;
  int byHour[];
  int maxValue;
  
  LocalTimePlays() {
    byCountry = new HashMap<Country,int[]>();
    byHour = new int[24];
    maxValue = 0;
  }
  
  void put(Country c, int hr, int count) {
    if (!byCountry.containsKey(c)) byCountry.put(c, new int[24]);
//    byHour[hr] -= byCountry.get(c)[hr];
    byCountry.get(c)[hr] = count;
    byHour[hr] += count;
    maxValue = max(maxValue, byHour[hr]);
  }
  
  String getLabel(int index) {return str(index);}
  float getValue(int index) { return byHour[index]; }
  int count() {return 24;}
  float getMaxValue() {return maxValue;}
  color getColor(int index) { return #aaaaaa; }
}

class GMTTimePlays {
  Map<Country, int[]> byCountry;
  
  GMTTimePlays() {
    byCountry = new HashMap<Country,int[]>();
  }
  
  void put(Country c, int hr, int count) {
    if (!byCountry.containsKey(c)) byCountry.put(c, new int[25]);  // 24 is used for max
//    byHour[hr] -= byCountry.get(c)[hr];
    byCountry.get(c)[hr] = count;
    byCountry.get(c)[24] = max(byCountry.get(c)[24], count);
  }
}

class WebDataSource {
  String baseURL;
  ExecutorService loadExec;
  
  List<Country> countries;
  Map<String, Country> countryCodeMap;
  
  PImage missingImage = null;
  PImage loadingImage = null;
  
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
          countries.add(new Country(aj.getInt("id"), aj.getString("name"), aj.getString("code"), aj.getInt("plays"), aj.getInt("user_count")));
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
    if (getCountries() != null) for (Country c : getCountries()) {
      if (c.name.equalsIgnoreCase(name)) return c;
    }
    return null;
  }
  
  Country getCountryByCode(String code)
  {
    if (getCountries() != null) return countryCodeMap.get(code);
    else return null;
  }
  
  Future<ArtistChart> getTopArtists(final UserFilter userFilter)
  {
    return loadExec.submit(new Callable<ArtistChart>() {
      public ArtistChart call() {
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
        return new ArtistChart(entries);
      }
    });
  }
  
  Future<ArtistChart> getTopArtistsForWeek(final int yr, final int week)
  {
    return loadExec.submit(new Callable<ArtistChart>() {
      public ArtistChart call() {
        List<ArtistChartEntry> entries = new ArrayList<ArtistChartEntry>(10);
        String request = baseURL + "artists/top_by_week/" + yr + "/" + week + ".json";
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
        return new ArtistChart(entries);
      }
    });
  }
  
  String missingImageUrl(){
    return baseURL + "assets/photo_not_available.jpg";
  }
  
  PImage getMissingImage()
  {
    if (missingImage == null) {
      missingImage = loadImage(missingImageUrl(), "jpg");
    }
    return missingImage;
  }
  
  PImage getLoadingImage()
  {
    if (loadingImage == null) {
      loadingImage = loadImage(missingImageUrl(), "jpg");
    }
    return loadingImage;
  }
  
  Future<ArtistCountryBreakdown> getCountryBreakdown(final Artist artist)
  {
    return loadExec.submit(new Callable<ArtistCountryBreakdown>() {
      public ArtistCountryBreakdown call() {
        ArtistCountryBreakdown countryBreakdown = null;
        int total = 0;
        String request = baseURL + "artists/" + artist.id + "/users/country_stats.json";
        println(request);
        
        try {
          JSONArray result = new JSONArray(join(loadStrings(request), ""));
          countryBreakdown = new ArtistCountryBreakdown();
          for (int i = 0; i < result.length(); i++){
            JSONObject aj = result.getJSONObject(i);
            String cc = aj.getString("code");
            int count = aj.getInt("count");
            Country c = getCountryByCode(cc);
            countryBreakdown.put(c, count);
            total += count;
          }
          if (!artist.user_count_set) {
            artist.user_count = total;
            artist.user_count_set = true;
          }
        }
        catch (JSONException e) {
          println (e);
        }
        return countryBreakdown;
      }
    });
  }
  
  Future<ArtistGenderBreakdown> getGenderBreakdown(final Artist artist)
  {
    return loadExec.submit(new Callable<ArtistGenderBreakdown>() {
      public ArtistGenderBreakdown call() {
        int total = 0;
        ArtistGenderBreakdown genderBreakdown = null;
        int mCount = 0, fCount = 0, uCount = 0;
        String request = baseURL + "artists/" + artist.id + "/users/gender_stats.json";
        println(request);
        
        try {
          JSONArray result = new JSONArray(join(loadStrings(request), ""));
          for (int i = 0; i < result.length(); i++){
            JSONObject aj = result.getJSONObject(i);
            String gender = aj.getString("gender");
            int count = aj.getInt("count");
            total += count;
            if(gender.equals("null")) uCount = count;
            else if(gender.equals("m")) mCount = count;
            else if(gender.equals("f")) fCount = count;
          }
          genderBreakdown = new ArtistGenderBreakdown(mCount, fCount, uCount);
          if (!artist.user_count_set) {
            artist.user_count = total;
            artist.user_count_set = true;
          }
        }
        catch (JSONException e) {
          println("getGenderBreakdown");
          println (e);
        }
        return genderBreakdown;
      }
    });
  }
  
  Future<ArtistAgeBreakdown> getAgeBreakdown(final Artist artist){
    return loadExec.submit(new Callable<ArtistAgeBreakdown>() {
      public ArtistAgeBreakdown call() {
        ArtistAgeBreakdown age_breakdown = new ArtistAgeBreakdown();
        String request = baseURL + "artists/" + artist.id + "/users/age_stats.json";
        println(request);
        try {
          JSONArray result = new JSONArray(join(loadStrings(request), ""));
          for (int i = 0; i < result.length(); i++){
            JSONObject aj = result.getJSONObject(i);
            age_breakdown.add(new ArtistAgeBreakdownEntry(aj.getString("age_range"), aj.getInt("count")));
          }
        }
        catch (JSONException e) {
          println("getAgeBreakdown");
          println (e);
        }
        return age_breakdown;
      }
    });
  }
  
  Future<JSONDictionarySource> getArtistInfo(final Artist artist) {
    return loadExec.submit(new Callable<JSONDictionarySource>() {
      public JSONDictionarySource call() {
        String request = baseURL + "artists/" + artist.id + "/info.json";
        println(request);
        try {
          JSONObject result = new JSONObject(join(loadStrings(request), ""));
          return new JSONDictionarySource(result);
        }
        catch (JSONException e) {
          println("getArtistInfo");
          println (e);
        }
        return null;
      }
    });
  }
  
  Future<ArtistList> getSimilarArtists(final Artist artist, final UserFilter userFilter){
    return loadExec.submit(new Callable<ArtistList>() {
      public ArtistList call() {
        List<Artist> similar = new ArrayList<Artist>();
        String request = baseURL + "artists/" + artist.id + "/similar.json" + userFilter.queryString();
        println(request);
        try {
          JSONArray result = new JSONArray(join(loadStrings(request), ""));
          for (int i = 0; i < result.length(); i++){
            JSONObject aj = result.getJSONObject(i);
            similar.add(new Artist(aj.getString("mbid"), aj.getString("name"), aj.getString("thumbnail")));
          }
        }
        catch (JSONException e) {
          println("getSimilarArtists");
          println (e);
        }
        return new ArtistList(similar);
      }
    });
  }
  
  Future<PImage> getArtistImage(final Artist artist)
  {
    return loadExec.submit(new Callable<PImage>() {
      public PImage call() {
        if(artist.image_url == null){
          ArrayList<String> image_urls = LastFmWrapper.getImageUrls(artist.name);
          if(image_urls.size() > 0) artist.image_url = image_urls.get(0);
          else artist.image_url = missingImageUrl();
        }
        return loadImage(artist.image_url, "jpg");
      }
    });
  }
  
  Future<LocalTimePlays> getLocalTimePlays()
  {
    return loadExec.submit(new Callable<LocalTimePlays>() {
      public LocalTimePlays call() {
        LocalTimePlays ltp = null;
        String request = baseURL + "plays_by_hour";
        println(request);
        try {
          JSONArray result = new JSONArray(join(loadStrings(request), ""));
          ltp = new LocalTimePlays();
          for (int i = 0; i < result.length(); i++){
            JSONObject aj = result.getJSONObject(i);
            Country c = getCountryByCode(aj.getString("country_code"));
            ltp.put(c, aj.getInt("local_hour"), aj.getInt("plays"));
          }
        }
        catch (JSONException e) {
          println("getLocalTimePlays");
          println (e);
        }
        return ltp;
      }
    });
  }
  
  Future<GMTTimePlays> getGMTTimePlays()
  {
    return loadExec.submit(new Callable<GMTTimePlays>() {
      public GMTTimePlays call() {
        GMTTimePlays gtp = null;
        String request = baseURL + "plays_by_hour_gmt";
        println(request);
        try {
          JSONArray result = new JSONArray(join(loadStrings(request), ""));
          gtp = new GMTTimePlays();
          for (int i = 0; i < result.length(); i++){
            JSONObject aj = result.getJSONObject(i);
            Country c = getCountryByCode(aj.getString("country_code"));
            gtp.put(c, aj.getInt("gmt_hour"), aj.getInt("plays"));
          }
        }
        catch (JSONException e) {
          println("getLocalTimePlays");
          println (e);
        }
        return gtp;
      }
    });
  }
  
  public Artist findArtist(int id){
    String request = baseURL + "artists/" + id + ".json";
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
  
  Future<SongList> searchSongs(final String q){
    return loadExec.submit(new Callable<SongList>() {
      public SongList call() {
        List<Song> songs = new ArrayList<Song>();
        String resultStr = null;
        try {
          String request = baseURL + "songs/by_title/" + java.net.URLEncoder.encode(q, "UTF-8") + ".json";
          println(request);
          resultStr = join(loadStrings(request), "");
          JSONArray result = new JSONArray(resultStr);
          for (int i = 0; i < result.length(); i++){
            JSONObject aj = result.getJSONObject(i);
            JSONObject artj = aj.getJSONObject("artist");
            songs.add(new Song(aj.getInt("id"), aj.getString("mbid"), aj.getString("title"),
              new Artist(artj.getInt("id"), artj.getString("mbid"), artj.getString("name"))));
          }
        }
        catch (UnsupportedEncodingException e) {
          println("searchSongs");
          println (e);
        }
        catch (JSONException e) {
          println("searchSongs");
          println (e);
          println(resultStr);
        }
        return new SongList(songs);
      }
    });
  }
  
  
  Future<SongList> getArtistSongs(final Artist artist){
    return loadExec.submit(new Callable<SongList>() {
      public SongList call() {
        List<Song> songs = new ArrayList<Song>();
        String resultStr = null;
        try {
          String request = baseURL + "artists/" + artist.id + "/songs/brainz";
          println(request);
          resultStr = join(loadStrings(request), "");
          JSONArray result = new JSONArray(resultStr);
          for (int i = 0; i < result.length(); i++){
            JSONObject aj = result.getJSONObject(i);
            JSONObject artj = aj.getJSONObject("artist");
            songs.add(new Song(-1, aj.getString("mbid"), aj.getString("title"),
              new Artist(artj.getInt("id"), artj.getString("mbid"), artj.getString("name"))));
          }
        }
        catch (JSONException e) {
          println("artistSongs");
          println (e);
          println(resultStr);
        }
        return new SongList(songs);
      }
    });
  }
  
  Future<JSONDictionarySource> getSongInfo(final Song song) {
    return loadExec.submit(new Callable<JSONDictionarySource>() {
      public JSONDictionarySource call() {
        String request = baseURL + "songs/" + song.id + "/info.json?mbid=" + song.mbid;
        println(request);
        try {
          JSONObject result = new JSONObject(join(loadStrings(request), ""));
          return new JSONDictionarySource(result);
        }
        catch (JSONException e) {
          println("getArtistInfo");
          println (e);
        }
        return null;
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

