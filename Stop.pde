class Stop {
   int id;
   String name;
   float lat;
   float lng;
   
   public Stop(int id, String name, float lat, float lng) {
       this.id = id;
       this.name = name;
       this.lat = lat;
       this.lng = lng;
   }
   
   public Stop(TableRow raw) {
      this.id = raw.getInt("stop_id");
      this.name = raw.getString("stop_name");
      this.lat = raw.getFloat("stop_lat");
      this.lng = raw.getFloat("stop_lon");
   }  
}
