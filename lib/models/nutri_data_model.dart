class NutriDataModel {
  String? title;
  double? value;
  String? unit;

  NutriDataModel({this.title, this.value, this.unit});

  NutriDataModel.fromJson(Map<String, dynamic> json) {
    title = json['title'];
    value = json['value'];
    unit = json['unit'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['title'] = this.title;
    data['value'] = this.value;
    data['unit'] = this.unit;
    return data;
  }
}
