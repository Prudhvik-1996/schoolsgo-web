class BusLatLong {
  double? latitude;
  double? longitude;
  int? busId;
  String? busName;
  int? driverId;
  String? driverName;
  int? schoolId;
  String? schoolName;

  BusLatLong({this.latitude, this.longitude, this.busId, this.busName, this.driverId, this.driverName, this.schoolId, this.schoolName});

  @override
  String toString() {
    return "{'latitude': $latitude, 'longitude': $longitude, 'busId': $busId, 'busName': '$busName', 'driverId': $driverId, 'driverName': '$driverName, 'schoolId': '$schoolId, 'schoolName': '$schoolName'}";
  }
}
