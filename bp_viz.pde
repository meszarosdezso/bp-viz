import processing.pdf.*;

Table stopsTable;
Table shapesTable;
Table tripsTable;
Table routesTable;

HashMap<String, Stop> stops = new HashMap();
HashMap<String, Shape> shapes = new HashMap();
HashMap<String, Trip> trips = new HashMap();
HashMap<String, Route> routes = new HashMap();

ArrayList<Stop> sortedStops = new ArrayList();
ArrayList<Trip> sortedTrips = new ArrayList();   

float minLat = 999;
float maxLat = -1;

float minLng = 999;
float maxLng = -1;

float w, h;


void loadData() {
  stopsTable = loadTable("stops.txt", "header, csv");
  shapesTable = loadTable("shapes.txt", "header, csv");
  tripsTable = loadTable("trips.txt", "header, csv");
  routesTable = loadTable("routes.txt", "header, csv");
 
  // load shapes
  println("Loading shapes...");
  String firstId = shapesTable.getRow(0).getString("shape_id");
  Shape current = new Shape(firstId); 
  for (TableRow raw : shapesTable.rows()) {
    String id = raw.getString("shape_id");
    if (!id.equals(current.id)) {
      shapes.put(id, current);
      current = new Shape(id);
    }
    current.addPoint(raw);
  }
  println("Loaded " + shapes.size() + " shapes.");
  
  // load stops
  println("Loading stops...");
  for (TableRow raw : stopsTable.rows()) {
    Stop s = new Stop(raw);
    
    if (s.lat < minLat) minLat = s.lat;
    if (s.lat > maxLat) maxLat = s.lat;
    
    if (s.lng < minLng) minLng = s.lng;
    if (s.lng > maxLng) maxLng = s.lng; 
    
    stops.put(s.id, s);
  }
  println("Loaded " + stops.size() + " stops.");
  
  println("Loading trips...");
  for (TableRow raw : tripsTable.rows()) {
    String id = raw.getString("shape_id");
    Trip t = new Trip(raw);
    trips.putIfAbsent(id, t);
  }
  println("Loaded " + trips.size() + " trips.");
  
  println("Loading routes...");
  for (TableRow raw : routesTable.rows()) {
    String id = raw.getString("route_id");
    Route r = new Route(raw);
    routes.put(id, r);
  }
  println("Loaded " + routes.size() + " routes.");
  
  // calc vizualization width and height
  float earthW = maxLng - minLng;
  float earthH = maxLat - minLat;
  
  float scale = height / earthH;
  
  w = earthW * scale - 150;
  h = earthH * scale - 50;
  
  sortTripsByRouteType();
  
  int startIndex = floor(random(stops.size()));
  Stop start = (Stop) stops.values().toArray()[startIndex];
  sortStops(start);
}

void setup() {
  size(800, 800);
  background(255);
  loadData();
  //beginRecord(PDF, "bp.pdf");
}


int i = 1;
void draw() {
  translate(width / 2, height / 2);

  drawAbstractStopLines();
}

void drawStops() {
  background(255);
  for (Stop s : stops.values()) {
    noStroke();
    fill(0, 50);
    s.draw();
    //if (random(1) < 0.05) {
    //  Stop other = (Stop)stops.values().toArray()[floor(random(stops.size()))];
    //  PVector p1 = coordsToPixels(other.lng, other.lat);
    //  PVector p2 = coordsToPixels(s.lng, s.lat);
    //  stroke(0, 50);
    //  line(p1.x, p1.y, p2.x, p2.y);
    //}
  }
  noLoop();
  endRecord();
}

void drawTriangles() {
  // noStroke();
  // fill(0, 4);
  int step = 20;
  stroke(0, 50);
  noFill();
  beginShape(TRIANGLE_FAN);
  for (int n = 0; n < step; n++) {
    Stop s = sortedStops.get(i+n); 
    PVector p = coordsToPixels(s.lng, s.lat);
    vertex(p.x, p.y);
  }
  endShape();
  
  i += step / 2;
  
  if (i > stops.size() - step) {
    noLoop();
    endRecord();
  }
}

void drawCenteredStops(Stop center) {
  stroke(0, 10);
  noFill();
  
  Stop next = (Stop)stops.values().toArray()[i];
  
  PVector p1 = coordsToPixels(next.lng, next.lat);
  PVector p2 = coordsToPixels(center.lng, center.lat);
      
  line(p1.x, p1.y, p2.x, p2.y);
  
  i++;
  
  if (i > stops.size() - 1) {
    noLoop();
    endRecord();
  }
}


void drawAbstractStopLines() {
  stroke(0, 10);
  noFill();
  Stop prev = (Stop)stops.values().toArray()[0];
  for (int s = 1; s < stops.size(); s++) {
     Stop current = (Stop)stops.values().toArray()[s];
     
     PVector p1 = coordsToPixels(prev.lng, prev.lat);
     PVector p2 = coordsToPixels(current.lng, current.lat);
      
     line(p1.x, p1.y, p2.x, p2.y);
     
     prev = current;
  }
  
  noLoop();
  endRecord();
}    


void drawSortedStopLines() {
  noFill();
  stroke(0);
  strokeWeight(1);
  
  Stop prev = sortedStops.get(i-1);
  Stop current = sortedStops.get(i);
  
  PVector start = coordsToPixels(prev.lng, prev.lat);
  PVector end = coordsToPixels(current.lng, current.lat);
  
  line(start.x, start.y, end.x, end.y);
  
  // save frames to create GIFs
  // save("export/frame_" + i + ".png");
  
  i++;
  
  if (i > stops.size() - 1) {
    noLoop();
    endRecord();
    println("DONE");
  }
}

void drawShapes() {
  stroke(0, 5);
  strokeJoin(ROUND);
  strokeCap(SQUARE);
  strokeWeight(1);
  
  // Shape current = (Shape)shapes.values().toArray()[i];
  // current.draw();
  
  for (Shape s : shapes.values()) {
    s.drawAnim(i);
  }
  
  // save("export/frame_" + i + ".png");
  
  i++;
  
  if (i > shapes.size() - 1) {
    noLoop();
    endRecord();
    println("DONE");
  }
}

void drawTrips(int perFrame) {
  strokeJoin(MITER);
  strokeCap(PROJECT);
  
  for (int n = 0; n < perFrame; n++) {
    Trip t = sortedTrips.get(i-1);
    Route r = routes.get(t.routeId);
    Shape s = shapes.get(t.shapeId);
    stroke(r.colour);
    strokeWeight(1);
    
    if (r.type.equals("1")) {
      strokeWeight(3); 
    }
     
    if (s != null) {
      s.draw();  
    }
    
    i++;
  }
  
  if (i > sortedTrips.size() - 1) {
    noLoop();
    endRecord();
    println("DONE");  
  }
}
