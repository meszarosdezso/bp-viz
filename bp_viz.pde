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

void setup() {
  size(800, 800);
  background(255);

  loadData();
  
  int startIndex = floor(random(stops.size()));
  String startId = (String) stops.keySet().toArray()[startIndex];
  Stop start = stops.get(startId);
  sortedStops.add(start);
   
  beginRecord(PDF, "bp.pdf");
}


int i = 1;
void draw() {
  translate(width / 2, height / 2);
  
  drawShapes();
}

void drawSortedStopLines(int perFrame) {
  stroke(0);
  strokeWeight(1);
  
  for (int n = 0; n < perFrame; n++) {
    int currentIndex = sortedStops.size() - 1;
    Stop current = sortedStops.get(currentIndex);
    
    Stop next = current;
    double recordDist = 999;
    
    for (String sId : stops.keySet()) {
      Stop s = stops.get(sId);
      if (!sortedStops.contains(s)) {
        double d = Math.pow(s.lat - current.lat, 2) + Math.pow(s.lng - current.lng, 2);
        if (d < recordDist) {
           recordDist = d;
           next = s;
        }
      }
    }
    
    sortedStops.add(next);
    
    if (recordDist < 0.001) {
      float x1 = map(next.lng, minLng, maxLng, -w/2, w/2);
      float x2 = map(current.lng, minLng, maxLng, -w/2, w/2);
      
      float y1 = map(next.lat, minLat, maxLat, h/2, -h/2);
      float y2 = map(current.lat, minLat, maxLat, h/2, -h/2);
      
      line(x1, y1, x2, y2);
    }
   
    i++;
  }
  
  // save frames to create GIFs
  // save("export/frame_" + i + ".png");
  
  if (i > stops.size() - 1) {
    noLoop();
    endRecord();
    println("DONE");
  }
}

void drawShapes() {
  stroke(0, 5);
  strokeJoin(MITER);
  strokeCap(PROJECT);
  strokeWeight(1);
  
  //Shape current = (Shape)shapes.values().toArray()[i];
  //current.draw();
  
  for (Shape s : shapes.values()) {
    s.drawAnim(i);
  }
  
  save("export/frame_" + i + ".png");
  
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
}

void sortTripsByRouteType() {
  String[] sort = new String[]{"3", "0", "800", "1", "109", "4"};
  
  for (String type : sort) {
    for (String tripId : trips.keySet()) {
      Trip t = trips.get(tripId);
      Route r = routes.get(t.routeId);
      if (r.type.equals(type)) {
        sortedTrips.add(t); 
      }
    }
  }
  
  println("Sorted trips by route type.");
}
