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

class CountryChooser extends Button implements ListDataSource {
  boolean showing = false;
  int chosen = 0;
  ListBox countryListbox;
  List<Country> countries;
  
  CountryChooser(float x_, float y_, float w_, float h_)
  {
    super(x_,y_,w_,h_,"");
    title = getText(chosen);
    align = LEFT;
    countries = data.getCountries();
    countryListbox = new ListBox(x_, y_+h_, w_, 200, this);
    countryListbox.setAction(new ListAction() {
      public void itemClicked(ListBox lb, int index, Object item) {
        setChosen(index);
        if (action != null) action.respond(CountryChooser.this);
      }
    });
  }
  
  void setChosen(int index)
  {
    chosen = index;
    title = getText(chosen);
  }
  
  boolean contentClicked(float lx, float ly)
  {
    showing = !showing;
    if (showing) {
      countries = data.getCountries();  /* if it failed to load, we only want to retry when the menu is reopened */
      countryListbox.x = mouseX - lx;
      countryListbox.y = mouseY - ly + h;
      rootView.subviews.add(countryListbox);
    } else rootView.subviews.remove(countryListbox);
    return true;
  }
  
  String getText(int index) {
    if (index == 0) return "Any country";
    else return countries.get(index - 1).name;
  }
  Object get(int index) {
    if (index == 0) return null;
    else return countries.get(index - 1);
  }
  int count() {
    try {
      return countries.size() + 1;
    }
    catch (NullPointerException e) {
      return 1;
    }
  }
  boolean selected(int index)
  {
    return index == chosen;
  }
}

class TopArtistsTable extends TableView {
  TopArtistsTable(float x_, float y_, float w_, float h_, List<TableColumn> columns, TableDataSource data) {
    super(x_, y_, w_, h_, columns, data);
  }
  
  void drawCell(int i, int j, TableColumn col, float colx)
  {
    if (j == 1) {
      ArtistChartEntry topA = (ArtistChartEntry)data.get(0);
      ArtistChartEntry thisA = (ArtistChartEntry)data.get(i);
      if (thisA != null) {
        float barw = (float)col.w * thisA.playCount / topA.playCount;
        fill(64);
        rect(colx + col.w - barw, 0, barw, rowHeight);
        fill(textColor);
      }
    }
    super.drawCell(i, j, col, colx);
  }
}

class TopArtistView extends View implements TableDataSource {
  UserFilter userFilter;
  GlyphCheckbox maleCB;
  GlyphCheckbox femaleCB;
  GlyphCheckbox noGenderCB;
  TextField ageFromField;
  TextField ageToField;
  TableView artistTable;
  Future<List<ArtistChartEntry>> artists;
  String artistsStatus;
  CountryChooser countryChooser;
  
  final static int GENDER_LABEL_WIDTH = 40;
  final static int AGE_LABEL_WIDTH = 50;
  
  TopArtistView(float x_, float y_, float w_, float h_, UserFilter initialFilter)
  {
    super(x_,y_,w_,h_);
    this.userFilter = initialFilter;
    
    artistTable = new TopArtistsTable(0, 40, w, h-40, Arrays.asList(
      new TableColumn("Artist", w*0.8),
      new TableColumn("Plays", w*0.2, RIGHT)
    ), this); // new MissingListDataSource("no artists")
    artistTable.action = new TableAction() {
      public void itemClicked(TableView tv, int index, Object item) {
        ArtistChartEntry entry = (ArtistChartEntry)item;
        showArtistDetails(entry.artist);
      }
    };
    subviews.add(artistTable);
    subviews.add(new TableHeader(0, 20, w, 20, artistTable));
    
    HorizontalLayout layout = new HorizontalLayout(this);
    
    layout.add(new Label(0, 0, GENDER_LABEL_WIDTH,20, "Sex:", RIGHT));
    
    layout.add(maleCB = makeGenderCheckbox(MALE, "M", 0, 0));
    layout.add(femaleCB = makeGenderCheckbox(FEMALE, "F", 0, 0));
    layout.add(noGenderCB = makeGenderCheckbox(UNKNOWN, "?", 0, 0));
    
    layout.add(new Label(0, 0, AGE_LABEL_WIDTH, 20, "Age:", RIGHT));
    
    layout.add(ageFromField = new TextField(0, 0, 30, 20));
    layout.add(new Label(0, 0, 20, 20, "-", CENTER));
    layout.add(ageToField = new TextField(0, 0, 30, 20));
    
    ageFromField.setAction(new Action<TextField>() {
      public void respond(TextField tf) {
        userFilter.ageMin = stringToAge(ageFromField.value);
        filterChanged();
      }
    });
    ageToField.setAction(new Action<TextField>() {
      public void respond(TextField tf) {
        userFilter.ageMax = stringToAge(ageToField.value);
        filterChanged();
      }
    });
    
    if (userFilter.ageMin != DONTCARE) ageFromField.value = str(userFilter.ageMin);
    if (userFilter.ageMax != DONTCARE) ageToField.value = str(userFilter.ageMax);
    
    layout.add(new Label(0, 0, 90, 20, "Country:", RIGHT));
    layout.add(countryChooser = new CountryChooser(0, 0, 120, 20));
    if (userFilter.country != null) {
      countryChooser.setChosen(data.countries.indexOf(userFilter.country) + 1);
    }
    countryChooser.setAction(new Action<Button>() {
      public void respond(Button b) {
        userFilter.country = (Country)countryChooser.get(countryChooser.chosen);
        filterChanged();
      }
    });
    
//    ageFromField.value = "0";
//    ageToField.value = "122";  // longest documented human life

    reloadArtists();
  }
  PImage getImage(int index, int column){return null;}
  
  int stringToAge(String s)
  {
    int a;
    try {
      a = Integer.parseInt(s);
    }
    catch (NumberFormatException e) {
      a = DONTCARE;
    }
    return a;
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
        filterChanged();
      }
    });
    return cb;
  }
  
  void filterChanged()
  {
    reloadArtists();
  }
  
  void reloadArtists()
  {
    if (artists != null && !artists.isDone()) artists.cancel(true);
    artists = data.getTopArtists(userFilter);
    artistsStatus = "Loading...";
  }
  
  void drawContent(float lx, float ly)
  {
    strokeWeight(1);
    stroke(borderColor);
    noFill();
    rect(0, 0, w, h);
  }
  
  List<ArtistChartEntry> getArtists()
  {
    List<ArtistChartEntry> a = null;
    if (!artists.isDone()) return null;
    try {
      a = artists.get();
    } catch (InterruptedException e) {
      println(e);
    } catch (ExecutionException e) {
      artistsStatus = "Server request failed.";
    }
    return a;
  }

  String getText(int index, int column) {
    List<ArtistChartEntry> as = getArtists();
    if (as != null) {
      if (column == 0) return as.get(index).artist.name;
      else return str(getArtists().get(index).playCount);
    } else {
      if (column == 0) return artistsStatus;
      else return "";
    }
  }
  Object get(int index) { return getArtists() != null ? getArtists().get(index) : null; }
  int count() { return getArtists() != null ? getArtists().size() : 1; }
  boolean selected(int index) { return false; }
}

