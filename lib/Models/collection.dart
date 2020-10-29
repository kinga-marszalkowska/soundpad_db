
class Collection{
  int id;
  String name;
  String soundIDs;

  Collection.withSounds(this.name, [this.soundIDs]);
  Collection.withID(this.id, this.name, [this.soundIDs]);
  Collection(this.name);

  // Convert a Collection object into a Collection object
  Map<String, dynamic> toMap() {

    var map = Map<String, dynamic>();
    if (id != null) {
      map['id'] = id;
    }
    map['name'] = name;
    map['soundIDs'] = soundIDs;

    return map;
  }

  // Extract a Collection object from a Map object
  Collection.fromMap(Map<String, dynamic> map) {
    this.id = map['id'];
    this.name = map['name'];
    this.soundIDs = map['soundIDs'];
  }

}