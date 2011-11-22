interface RankingDataSource {
  List get(int time);
  int times();
}

class MissingRankingDataSource implements RankingDataSource {
  List get(int time) {return null;}
  int times() {return 0;}
}

class AsyncRankingDataSource implements RankingDataSource {
  Future<? extends RankingDataSource> data;
  MissingRankingDataSource noData;
  AsyncRankingDataSource(Future<? extends RankingDataSource> data) {
    this.data = data;
    noData = new MissingRankingDataSource();
  }
  RankingDataSource getData() {
    if (data.isDone()) try {
      return data.get();
    } catch (InterruptedException e) {
      println(e);
    } catch (ExecutionException e) {
      println(e);
    }
    return noData;
  }
  List get(int time) { return getData().get(time); }
  int times() { return getData().times(); }
}

class RankingView extends View {
  RankingDataSource data;
  color[] colors = { #FFCC00, #008888, #880088, #00FFCC, #888800, #FF00CC, #CC00FF };
  
  RankingView(float x_, float y_, float w_, float h_, RankingDataSource data)
  {
    super(x_,y_,w_,h_);
    this.data = data;
  }
  
  void drawContent(float lx, float ly)
  {
    int times = data.times();
    float timew = w/times;
    List lastTime = null;
    
    strokeWeight(2);
    for (int i = 0; i < times; i++) {
      List thisTime = data.get(i);
      int ranks = thisTime.size();
      float rankh = h/ranks;
      
      for (int j = 0; j < ranks; j++) {
        Object o = thisTime.get(j);
        stroke(colors[abs(o.hashCode()) % colors.length]);
        ellipse(timew*i, rankh*j, 5, 5);
        if (lastTime != null) {
          int lastj = lastTime.indexOf(o);
          if (lastj != -1) {
            line(timew*(i-1), rankh*lastj, timew*i, rankh*j);
          }
        }
      }
      lastTime = thisTime;
    }
    strokeWeight(1);
  }
}

