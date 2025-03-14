/* 
// Example Usage
Map<String, dynamic> map = jsonDecode(<myJSONString>);
var myRootNode = Root.fromJson(map);
*/ 
class HelpAndSupport {
    String? contactemail;
    String? contactphonenumber;

    HelpAndSupport({this.contactemail, this.contactphonenumber}); 

    HelpAndSupport.fromJson(Map<String, dynamic> json) {
        contactemail = json['contact_email'];
        contactphonenumber = json['contact_phone_number'];
    }

    Map<String, dynamic> toJson() {
        final Map<String, dynamic> data = Map<String, dynamic>();
        data['contact_email'] = contactemail;
        data['contact_phone_number'] = contactphonenumber;
        return data;
    }
}

/* 
// Example Usage
Map<String, dynamic> map = jsonDecode(<myJSONString>);
var myRootNode = Root.fromJson(map);
*/ 

class CityData {
  int? id;
  String? city;
  int? countryId;

  CityData({this.id, this.city, this.countryId}); 

  CityData.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    city = json['city'];
    countryId = json['country_id'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['id'] = id;
    data['city'] = city;
    data['country_id'] = countryId;
    return data;
  }
}
// class CityData {
//     int? id;
//     String? city;

//     CityData({this.id, this.city}); 

//     CityData.fromJson(Map<String, dynamic> json) {
//         id = json['id'];
//         city = json['city'];
//     }

//     Map<String, dynamic> toJson() {
//         final Map<String, dynamic> data = Map<String, dynamic>();
//         data['id'] = id;
//         data['city'] = city;
//         return data;
//     }
// }

class CommentReportReason {
    int? id;
    String? reportreason;
    String? reporttype;

    CommentReportReason({this.id, this.reportreason, this.reporttype}); 

    CommentReportReason.fromJson(Map<String, dynamic> json) {
        id = json['id'];
        reportreason = json['report_reason'];
        reporttype = json['report_type'];
    }

    Map<String, dynamic> toJson() {
        final Map<String, dynamic> data = Map<String, dynamic>();
        data['id'] = id;
        data['report_reason'] = reportreason;
        data['report_type'] = reporttype;
        return data;
    }
}

class CountryData {
    int? id;
    String? country;

    CountryData({this.id, this.country}); 

    CountryData.fromJson(Map<String, dynamic> json) {
        id = json['id'];
        country = json['country'];
    }

    Map<String, dynamic> toJson() {
        final Map<String, dynamic> data = Map<String, dynamic>();
        data['id'] = id;
        data['country'] = country;
        return data;
    }
}

class PostcodeDistirctData {
  int? id;
  String? postcodedistrict;
  String? region;
  int? cityId;

  PostcodeDistirctData({this.id, this.postcodedistrict, this.region, this.cityId});

  PostcodeDistirctData.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    postcodedistrict = json['postcode_district'];
    region = json['region'];
    cityId = json['city_id'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['id'] = id;
    data['postcode_district'] = postcodedistrict;
    data['region'] = region;
    data['city_id'] = cityId;
    return data;
  }
}

// class PostcodeDistirctData {
//     int? id;
//     String? postcodedistrict;

//     PostcodeDistirctData({this.id, this.postcodedistrict}); 

//     PostcodeDistirctData.fromJson(Map<String, dynamic> json) {
//         id = json['id'];
//         postcodedistrict = json['postcode_district'];
//     }

//     Map<String, dynamic> toJson() {
//         final Map<String, dynamic> data = Map<String, dynamic>();
//         data['id'] = id;
//         data['postcode_district'] = postcodedistrict;
//         return data;
//     }
// }

class PostReportReason {
    int? id;
    String? reportreason;
    String? reporttype;

    PostReportReason({this.id, this.reportreason, this.reporttype}); 

    PostReportReason.fromJson(Map<String, dynamic> json) {
        id = json['id'];
        reportreason = json['report_reason'];
        reporttype = json['report_type'];
    }

    Map<String, dynamic> toJson() {
        final Map<String, dynamic> data = Map<String, dynamic>();
        data['id'] = id;
        data['report_reason'] = reportreason;
        data['report_type'] = reporttype;
        return data;
    }
}

class MasterDataModel {
    List<PostcodeDistirctData?>? postcodedistirctdata;
    List<CityData?>? citydata;
    List<CountryData?>? countrydata;
    List<PostReportReason?>? postreportreasons;
    List<CommentReportReason?>? commentreportreasons;

    MasterDataModel({this.postcodedistirctdata, this.citydata, this.countrydata, this.postreportreasons, this.commentreportreasons}); 

    MasterDataModel.fromJson(Map<String, dynamic> json) {
        if (json['postcode_distirct_data'] != null) {
         postcodedistirctdata = <PostcodeDistirctData>[];
         json['postcode_distirct_data'].forEach((v) {
         postcodedistirctdata!.add(PostcodeDistirctData.fromJson(v));
        });
      }
        if (json['city_data'] != null) {
         citydata = <CityData>[];
         json['city_data'].forEach((v) {
         citydata!.add(CityData.fromJson(v));
        });
      }
        if (json['country_data'] != null) {
         countrydata = <CountryData>[];
         json['country_data'].forEach((v) {
         countrydata!.add(CountryData.fromJson(v));
        });
      }
        if (json['post_report_reasons'] != null) {
         postreportreasons = <PostReportReason>[];
         json['post_report_reasons'].forEach((v) {
         postreportreasons!.add(PostReportReason.fromJson(v));
        });
      }
        if (json['comment_report_reasons'] != null) {
         commentreportreasons = <CommentReportReason>[];
         json['comment_report_reasons'].forEach((v) {
         commentreportreasons!.add(CommentReportReason.fromJson(v));
        });
      }
    }

    Map<String, dynamic> toJson() {
        final Map<String, dynamic> data = Map<String, dynamic>();
        data['postcode_distirct_data'] =postcodedistirctdata != null ? postcodedistirctdata!.map((v) => v?.toJson()).toList() : '';
        data['city_data'] =citydata != null ? citydata!.map((v) => v?.toJson()).toList() : '';
        data['country_data'] =countrydata != null ? countrydata!.map((v) => v?.toJson()).toList() : '';
        data['post_report_reasons'] =postreportreasons != null ? postreportreasons!.map((v) => v?.toJson()).toList() : '';
        data['comment_report_reasons'] =commentreportreasons != null ? commentreportreasons!.map((v) => v?.toJson()).toList() : '';
        return data;
    }
}


class CategoryModel {
    int? id;
    String? categoryname;

    CategoryModel({this.id, this.categoryname}); 

    CategoryModel.fromJson(Map<String, dynamic> json) {
        id = json['id'];
        categoryname = json['category_name'];
    }

    Map<String, dynamic> toJson() {
        final Map<String, dynamic> data = Map<String, dynamic>();
        data['id'] = id;
        data['category_name'] = categoryname;
        return data;
    }
}
