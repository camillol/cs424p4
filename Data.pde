import org.json.*;

class Artist {
  String name;
  int id;
  String ref;
  
  Artist(int id, String ref, String name) {
    this.name = name;
    this.id = id;
    this.ref = ref;
  }
}

final static int UNKNOWN = 0;
final static int MALE = 1;
final static int FEMALE = 2;
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
  int userCount;
  
  ArtistChartEntry(Artist artist, int userCount) {
    this.artist = artist;
    this.userCount = userCount;
  }
}

class WebDataSource {
  String baseURL;
  
  WebDataSource(String baseURL)
  {
    this.baseURL = baseURL;
  }
  
/*  List<ArtistChartEntry> getTopArtists(UserFilter userFilter)
  {
    
  }*/
}

