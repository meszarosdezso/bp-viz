class Shape {
  final String id;
  final ArrayList<PVector> points;
  
  public Shape(String id) {
    this.id = id;
    this.points = new ArrayList();
  }
  
  void addPoint(PVector point) {
    this.points.add(point);
  }
  
  void addPoint(TableRow row) {
    float lat = row.getFloat("shape_pt_lat");
    float lng = row.getFloat("shape_pt_lon");
    
    PVector point = new PVector(lng, lat);
    this.points.add(point);
  }
  
  void draw() {
    for (int i = 1; i < this.points.size(); i++) {
      PVector prev = this.points.get(i-1);
      PVector current = this.points.get(i);
      
      float x1 = map(prev.x, minLng, maxLng, -w/2, w/2);
      float x2 = map(current.x, minLng, maxLng, -w/2, w/2);
    
      float y1 = map(prev.y, minLat, maxLat, h/2, -h/2);
      float y2 = map(current.y, minLat, maxLat, h/2, -h/2);
      
      line(x1, y1, x2, y2);      
    }
  }
}
