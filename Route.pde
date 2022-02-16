class Route {
  String id;
  String type;
  color colour;
  
  public Route(TableRow row) {
    this.id = row.getString("route_id");
    this.type = row.getString("route_type");
    
    String hex = row.getString("route_color");
    this.colour = color(unhex("FF" + hex));
  }
}
