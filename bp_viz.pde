import processing.pdf.*;

Table stopsTable;
ArrayList<Stop> stops = new ArrayList<Stop>();
ArrayList<Stop> sorted = new ArrayList<Stop>();

float minLat = 999;
float maxLat = -1;

float minLng = 999;
float maxLng = -1;

float w, h;

void setup() {
  size(800, 800);
  background(255);

  stopsTable = loadTable("stops.txt", "header, csv");
  
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
