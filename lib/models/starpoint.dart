class Starpoint {
  int star;

  Starpoint({this.star});

  Starpoint.fromMap(Map<String, dynamic> json) {
    star = json['star'];
  }

  Map<String, dynamic> toMap() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['star'] = this.star;
    return data;
  }
}
