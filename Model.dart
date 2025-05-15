/// id : 3
/// name : "Ali Khan"
/// courseTitle : "Computer Science"
/// marks : 87
/// department : "IT"
/// created_at : "2025-04-25T10:39:34.000000Z"
/// updated_at : "2025-04-25T10:39:34.000000Z"

class Model {
  Model({
      num? id, 
      String? name, 
      String? courseTitle, 
      num? marks, 
      String? department, 
      String? createdAt, 
      String? updatedAt,}){
    _id = id;
    _name = name;
    _courseTitle = courseTitle;
    _marks = marks;
    _department = department;
    _createdAt = createdAt;
    _updatedAt = updatedAt;
}

  Model.fromJson(dynamic json) {
    _id = json['id'];
    _name = json['name'];
    _courseTitle = json['courseTitle'];
    _marks = json['marks'];
    _department = json['department'];
    _createdAt = json['created_at'];
    _updatedAt = json['updated_at'];
  }
  num? _id;
  String? _name;
  String? _courseTitle;
  num? _marks;
  String? _department;
  String? _createdAt;
  String? _updatedAt;
Model copyWith({  num? id,
  String? name,
  String? courseTitle,
  num? marks,
  String? department,
  String? createdAt,
  String? updatedAt,
}) => Model(  id: id ?? _id,
  name: name ?? _name,
  courseTitle: courseTitle ?? _courseTitle,
  marks: marks ?? _marks,
  department: department ?? _department,
  createdAt: createdAt ?? _createdAt,
  updatedAt: updatedAt ?? _updatedAt,
);
  num? get id => _id;
  String? get name => _name;
  String? get courseTitle => _courseTitle;
  num? get marks => _marks;
  String? get department => _department;
  String? get createdAt => _createdAt;
  String? get updatedAt => _updatedAt;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['id'] = _id;
    map['name'] = _name;
    map['courseTitle'] = _courseTitle;
    map['marks'] = _marks;
    map['department'] = _department;
    map['created_at'] = _createdAt;
    map['updated_at'] = _updatedAt;
    return map;
  }

}