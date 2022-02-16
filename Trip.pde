class Trip {
  String id;
  String routeId;
  String shapeId;
  
  public Trip(TableRow row) {
     this.id = row.getString("trip_id");
     this.routeId = row.getString("route_id");
     this.shapeId = row.getString("shape_id");
  }
}
