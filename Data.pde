import org.json.*;
import java.util.concurrent.*;

class Artist {
  int id;
  String mbid;
  String name;
  
  Artist(int id, String mbid, String name) {
    this.id = id;
    this.mbid = mbid;
    this.name = name;
  }
}

final static int MALE = 1;
final static int FEMALE = 2;
final static int UNKNOWN = 4;
final static int DONTCARE = -1;

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

class WebDataSource {
  String baseURL;
  ExecutorService loadExec;
  
  WebDataSource(String baseURL)
  {
    this.baseURL = baseURL;
    loadExec = Executors.newSingleThreadExecutor();
  }
  
  Future<List<ArtistChartEntry>> getTopArtists(final UserFilter userFilter)
  {
    return loadExec.submit(new Callable<List<ArtistChartEntry>>() {
      public List<ArtistChartEntry> call() {
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
    });
  }
}

