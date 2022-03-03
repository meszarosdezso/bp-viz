class Stop {
   String id;
   String name;
   float lat;
   float lng;
   
   public Stop(String id, String name, float lat, float lng) {
       this.id = id;
       this.name = name;
       this.lat = lat;
       this.lng = lng;
   }
   
   public Stop(TableRow raw) {
      this.id = raw.getString("stop_id");
      this.name = raw.getString("stop_name");
      this.lat = raw.getFloat("stop_lat");
      this.lng = raw.getFloat("stop_lon");
   }
   
   void draw() {
      float x = map(this.lng, minLng, maxLng, -w/2, w/2);
      float y = map(this.lat, minLat, maxLat, h/2, -h/2);
      float r = 2;
      
      ellipse(x, y, r, r);
   }
}
