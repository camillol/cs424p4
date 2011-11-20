class HorizontalLayout {
  int nextx = 0;
  View view;
  HorizontalLayout(View view) {
    this.view = view;
  }
  
  void add(View subview) {
    subview.x = nextx;
    nextx += subview.w;
    view.subviews.add(subview);
  }
}

class TopArtistView extends View implements ListDataSource {
  UserFilter userFilter;
  GlyphCheckbox maleCB;
  GlyphCheckbox femaleCB;
  GlyphCheckbox noGenderCB;
  TextField ageFromField;
  TextField ageToField;
  ListBox artistListbox;
  Future<List<ArtistChartEntry>> artists;
  
  final static int GENDER_LABEL_WIDTH = 40;
  final static int AGE_LABEL_WIDTH = 50;
  
  TopArtistView(float x_, float y_, float w_, float h_)
  {
    super(x_,y_,w_,h_);
    userFilter = new UserFilter();
    
    HorizontalLayout layout = new HorizontalLayout(this);
    
    layout.add(new Label(0, 0, GENDER_LABEL_WIDTH,20, "Sex:", RIGHT));
    
    layout.add(maleCB = makeGenderCheckbox(MALE, "M", 0, 0));
    layout.add(femaleCB = makeGenderCheckbox(FEMALE, "F", 0, 0));
    layout.add(noGenderCB = makeGenderCheckbox(UNKNOWN, "?", 0, 0));
    
    layout.add(new Label(0, 0, AGE_LABEL_WIDTH, 20, "Age:", RIGHT));
    
    layout.add(ageFromField = new TextField(0, 0, 30, 20));
    layout.add(new Label(0, 0, 20, 20, "-", CENTER));
    layout.add(ageToField = new TextField(0, 0, 30, 20));
    
    ageFromField.value = "a";
    ageToField.value = "b";

    reloadArtists();
    
    artistListbox = new ListBox(0, 20, w, h-2, this); // new MissingListDataSource("no artists")
    subviews.add(artistListbox);
  }
  
  GlyphCheckbox makeGenderCheckbox(final int flag, String letter, int x, int y)
  {
    GlyphCheckbox cb = new GlyphCheckbox(x, y, 20, 20, letter);
    cb.checked = (userFilter.gender & flag) != 0;
    cb.setAction(new Action<Button>() {
      public void respond(Button b) {
        Checkbox cb = (Checkbox)b;
        if (cb.checked) userFilter.gender |= flag;
        else userFilter.gender &= ~flag;
        reloadArtists();
      }
    });
    return cb;
  }
  
  void reloadArtists()
  {
    artists = data.getTopArtists(userFilter);
  }
  
  void drawContent(float lx, float ly)
  {
    strokeWeight(1);
    stroke(255);
    noFill();
    rect(0, 0, w, h);
  }
  
  List<ArtistChartEntry> getArtists()
  {
    List<ArtistChartEntry> a = null;
    try {
      a = artists.get();
    } catch (InterruptedException e) {
      println(e);
    } catch (ExecutionException e) {
      println(e);
    }
    return a;
  }

  String getText(int index) { return artists.isDone() ? getArtists().get(index).artist.name : "Loading..."; }
  Object get(int index) { return artists.isDone() ? getArtists().get(index) : null; }
  int count() { return artists.isDone() ? getArtists().size() : 1; }
  boolean selected(int index) { return false; }
}

