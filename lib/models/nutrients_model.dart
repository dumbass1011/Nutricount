class NutrientsModel {
  String? key;
  String? title;

  NutrientsModel({this.key, this.title});

  NutrientsModel.fromJson(Map<String, dynamic> json) {
    key = json['key'];
    title = json['title'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['key'] = this.key;
    data['title'] = this.title;
    return data;
  }
}
