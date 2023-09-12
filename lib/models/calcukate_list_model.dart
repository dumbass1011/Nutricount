class CalculateListModel {
  Map? data;
  String? quantity;

  CalculateListModel({this.data, this.quantity});

  CalculateListModel.fromJson(Map<String, dynamic> json) {
    data = json['data'];
    quantity = json['quantity'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['data'] = this.data;
    data['quantity'] = this.quantity;
    return data;
  }
}
