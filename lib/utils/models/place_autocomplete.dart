class PlaceAutocompleteModel {
  String? description;
  String? placeId;

  PlaceAutocompleteModel({this.description, this.placeId});

  PlaceAutocompleteModel.fromJson(Map<String, dynamic> json) {
    description = json['description'];
    placeId = json['place_id'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['description'] = description;
    data['place_id'] = placeId;
    return data;
  }
}
