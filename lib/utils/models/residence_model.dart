/* 
// Example Usage
Map<String, dynamic> map = jsonDecode(<myJSONString>);
var myRootNode = Root.fromJson(map);
*/ 
import 'package:intl_phone_field/countries.dart';

class ResidenceModel {
    int? id;
    int? userid;
    String? postcodedistirct;
    String? housenumber;
    String? streetname;
    String? area;
    String? city;
    String? country;
    String? fullAddress;

    ResidenceModel({this.id, this.userid, this.postcodedistirct, this.housenumber, this.streetname, this.area, this.city, this.country, this.fullAddress}); 

    ResidenceModel.fromJson(Map<String, dynamic> json) {
        id = json['id'];
        userid = json['user_id'];
        postcodedistirct = json['postcode_distirct'] ?? "";
        housenumber = json['house_number'] ?? "";
        streetname = json['street_name'] ?? "";
        area = json['area'] ?? "";
        city = json['city'] ?? "";
        country = json['country'] ?? "";
        fullAddress = housenumber! +', '+streetname!+', '+area!+', '+city!+', '+country!+'.';
    }

    Map<String, dynamic> toJson() {
        final Map<String, dynamic> data = Map<String, dynamic>();
        data['id'] = id;
        data['user_id'] = userid;
        data['postcode_distirct'] = postcodedistirct;
        data['house_number'] = housenumber;
        data['street_name'] = streetname;
        data['area'] = area;
        data['city'] = city;
        data['country'] = country;
        data['full_address'] = fullAddress;
        return data;
    }
}

