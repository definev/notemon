class Starpoint {
  int star;

  Starpoint({this.star});

  Starpoint.fromMap(Map<String, dynamic> json) {
    int addStar = json['addStar'];
    int loseStar = json['loseStar'];
    star = addStar - loseStar;
  }
}
