class PathOfID
{
  PathOfID();

  List<int> path = [];

  factory PathOfID.ToJson(Map<String, dynamic> json)
  {
    final newPath = PathOfID();
    newPath.path = json['path'] as List<int>;
    return newPath  ;
  }
}