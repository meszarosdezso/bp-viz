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
      PVector p = coordsToPixels(this.lng, this.lat);
      float r = 2;
      
      ellipse(p.x, p.y, r, r);
   }
}
