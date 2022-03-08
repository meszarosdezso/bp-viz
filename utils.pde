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

void sortStops(Stop start) {
  println("Sorting stops...");
  sortedStops.add(start);
  while(sortedStops.size() < stops.size()) {
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
  }
  println("Sorted stops.");
}

float lngToX(float lng) {
  return map(lng, minLng, maxLng, -w/2, w/2);
  
}

float latToY(float lat) {
  return map(lat, minLat, maxLat, h/2, -h/2); 
}

PVector coordsToPixels(float lng, float lat) {
  return new PVector(lngToX(lng), latToY(lat));
}
