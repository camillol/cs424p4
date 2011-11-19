import org.json.JSONObject;
import org.json.JSONArray;
class WebDataSource implements DataSource {
  String baseURL;
  
  WebDataSource(String baseURL)
  {
    this.baseURL = baseURL;
  }
  
 void reloadCitySightingCounts()
  {
    minCountSightings = 10000;
    maxCountSightings = 0;
    totalCountSightings = 0;

    String request = baseURL + "/artists.json" + activeFilter.toString().replaceAll(" ", "%20");
    try {
      JSONObject result = new JSONObject(join(loadStrings(request), ""));
      JSONArray cities = result.getJSONArray("id");
      for (int i = 0; i < cities.length(); i++) {
        JSONObject city = cities.getJSONObject(i);
        Place p = cityMap.get(city.getInt("id"));
        p.sightingCount = 0;
        
        JSONArray counts = city.getJSONArray("counts");
        int idx = 0;
        for (SightingType st : sightingTypeMap.values()) {
          int typeCount = counts.getInt(idx);
          p.counts[idx] = typeCount;
          if (st.active) p.sightingCount += typeCount;
          idx++;
        }
        minCountSightings = min(p.sightingCount, minCountSightings);
        maxCountSightings = max(p.sightingCount, maxCountSightings);
        totalCountSightings += p.sightingCount;
      }
    }
    catch (JSONException e) {
      println (e);
    }
  }
}
