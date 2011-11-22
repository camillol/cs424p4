
import java.util.*;

import de.umass.lastfm.Artist;
import de.umass.lastfm.Chart;
import de.umass.lastfm.Event;
import de.umass.lastfm.PaginatedResult;
import de.umass.lastfm.*;

/**
 * @author zitterbewegung
 *
 */
public class LastFmWrapper {
	private static String key = "16fdacc5a11d94902d8977f40c25cdce"; //this is the key that I generated
	/**
	 * @return String 
	 * This returns a string with the the set of
	 */
	public static String getTopTracks(){
		String returnVar = "";
		PaginatedResult<Track> topTracks = Chart.getTopTracks(key);
		System.out.println("Top Tracks on last.fm");
		
		for (Track track : topTracks.getPageResults()) {
			returnVar = returnVar + track.getName();
			returnVar = returnVar + Integer.toString(track.getPlaycount());
			System.out.printf("%s (%d plays)%n", track.getName(), track.getPlaycount());
			}
		return returnVar;	
		}
	/**
	 * @param artist 
	 * This parameter is a string which is the artist to get a relative
	 * @return
	 */
	public static String getPastEvents(String artist){
		String returnVar = "";
		System.out.println("Related artist to " + artist);
		PaginatedResult<Event> pastEvents = Artist.getPastEvents(artist, key);
		for (Event event : pastEvents.getPageResults()){
			returnVar = returnVar + event.getVenue().getLatitude() + ","+ event.getVenue().getLongitude() + event.getStartDate().toString() + "\n";
		}
		return returnVar;
	}
  public static ArrayList<String> getImageUrls(String artist_name){
    ArrayList<String> images = new ArrayList<String>();
		for(Image image : Artist.getImages(artist_name, key).getPageResults()){
		  images.add(image.getImageURL(ImageSize.EXTRALARGE));
    }
    return images;
  }

	/**
	 * @param artist 
	 * This parameter is a string which is the artist to get a relative
	 * @return
	 */
   /*
	public static ArrayList<Artist> getRelArtist(String artist){
		System.out.println("Related artist to " + artist);
    ArrayList<String> related_artists = new ArrayList<String>();
		Collection<Artist> similarArtists = Artist.getSimilar(artist, key);
		for (Artist artist : similarArtists){
      related_artists.add(new Artist(artist.getMBID(), artist.getName(), artist.getImageUrl());
		}
		return related_artists;
	}
  */

	public static void main(String[] args) {
		if(args[0].equals("test")){
			System.out.println(getTopTracks() + getRelArtist("Coldplay"));
		}
		
		
	}
}

