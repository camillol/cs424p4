class TopArtistView extends View {
  UserFilter userFilter;
  GlyphCheckbox maleCB;
  GlyphCheckbox femaleCB;
  GlyphCheckbox noGenderCB;
  ListBox artistListbox;
  
  TopArtistView(float x_, float y_, float w_, float h_)
  {
    super(x_,y_,w_,h_);
    userFilter = new UserFilter();
    
    maleCB = makeGenderCheckbox(MALE, "M", 0);
    femaleCB = makeGenderCheckbox(FEMALE, "F", 1);
    noGenderCB = makeGenderCheckbox(UNKNOWN, "?", 2);
    
    artistListbox = new ListBox(0, 20, w, h-2, new MissingListDataSource("no artists"));
    subviews.add(artistListbox);
  }
  
  GlyphCheckbox makeGenderCheckbox(final int flag, String letter, int idx)
  {
    GlyphCheckbox cb = new GlyphCheckbox(20*idx, 0, 20, 20, letter);
    cb.checked = (userFilter.gender | flag) != 0;
    cb.setAction(new Action<Button>() {
      public void respond(Button b) {
        Checkbox cb = (Checkbox)b;
        if (cb.checked) userFilter.gender |= flag;
        else userFilter.gender &= ~flag;
      }
    });
    subviews.add(cb);
    return cb;
  }
  
  void drawContent(float lx, float ly)
  {
    strokeWeight(1);
    stroke(255);
    noFill();
    rect(0, 0, w, h);
  }
}

