import processing.pdf.*;

Table stopsTable;
ArrayList<Stop> stops = new ArrayList<Stop>();
ArrayList<Stop> sorted = new ArrayList<Stop>();

Table shapesTable;
ArrayList<Shape> shapes = new ArrayList<Shape>();

float minLat = 999;
float maxLat = -1;

float minLng = 999;
float maxLng = -1;

float w, h;

void setup() {
  size(800, 800);
  background(255);

  stopsTable = loadTable("stops.txt", "header, csv");
  shapesTable = loadTable("shapes.txt", "header, csv");
  
  String firstId = shapesTable.getRow(0).getString("shape_id");
  Shape current = new Shape(firstId); 
  for (TableRow raw : shapesTable.rows()) {
    String id = raw.getString("shape_id");
    if (!id.equals(current.id)) {
      shapes.add(current);
      current = new Shape(id);
    }
    current.addPoint(raw);
  }
  
  for (TableRow raw : stopsTable.rows()) {
    Stop s = new Stop(raw);
    
    if (s.lat < minLat) minLat = s.lat;
    if (s.lat > maxLat) maxLat = s.lat;
    
    if (s.lng < minLng) minLng = s.lng;
    if (s.lng > maxLng) maxLng = s.lng; 
    
    stops.add(s);
  }
  
  for (TableRow raw : stopsTable.rows()) {
    Stop s = new Stop(raw);
    
    if (s.lat < minLat) minLat = s.lat;
    if (s.lat > maxLat) maxLat = s.lat;
    
    if (s.lng < minLng) minLng = s.lng;
    if (s.lng > maxLng) maxLng = s.lng; 
    
    stops.add(s);
  }
  
  float earthW = maxLng - minLng;
  float earthH = maxLat - minLat;
  
  float scale = height / earthH;
  
  w = earthW * scale - 150;
  h = earthH * scale - 50;
  
  int startIndex = floor(random(stops.size()));
  Stop start = stops.get(startIndex);
  sorted.add(start);
  
  beginRecord(PDF, "bp.pdf");
}


int i = 1;
void draw() {
  translate(width / 2, height / 2);
  
  drawShapes();
}

void drawSortedStopLines() {
  stroke(0);
  strokeWeight(1);
  
  Stop current = sorted.get(sorted.size() - 1);
  
  Stop next = current;
  double recordDist = 999;
  
  for (Stop s : stops) { 
    if (!sorted.contains(s)) {
      double d = Math.pow(s.lat - current.lat, 2) + Math.pow(s.lng - current.lng, 2);
      if (d < recordDist) {
         recordDist = d;
         next = s;
      }
    }
  }
  
  sorted.add(next);
  
  if (recordDist < 0.001) {
    float x1 = map(next.lng, minLng, maxLng, -w/2, w/2);
    float x2 = map(current.lng, minLng, maxLng, -w/2, w/2);
    
    float y1 = map(next.lat, minLat, maxLat, h/2, -h/2);
    float y2 = map(current.lat, minLat, maxLat, h/2, -h/2);
    
    line(x1, y1, x2, y2);
  }
 
  i++;
  
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
  
  Shape current = shapes.get(i);
  current.draw();
  
  i++;
  
  if (i > shapes.size() - 1) {
    noLoop();
    endRecord();
    println("DONE");
  }
}
