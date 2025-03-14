class BusinessPromotionPostcode {
    int? id;
    String? postcodedistrict;
    int? postcodedistrictid;
    bool? isactive;

    BusinessPromotionPostcode({this.id, this.postcodedistrict, this.isactive, this.postcodedistrictid}); 

    BusinessPromotionPostcode.fromJson(Map<String, dynamic> json) {
        id = json['id'];
        postcodedistrict = json['postcode_district'];
        postcodedistrictid = json['postcode_district_id'];
        isactive = json['is_active'];
    }

    Map<String, dynamic> toJson() {
        final Map<String, dynamic> data = Map<String, dynamic>();
        data['id'] = id;
        data['postcode_district'] = postcodedistrict;
        data['postcode_district_id'] = postcodedistrictid;
        data['is_active'] = isactive;
        return data;
    }
}

class CategoryDetail {
    int? id;
    String? categoryname;

    CategoryDetail({this.id, this.categoryname}); 

    CategoryDetail.fromJson(Map<String, dynamic> json) {
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

class BusinessModel {
    int? id;
    int? userid;
    String? businessname;
    String? businesslogo;
    String? location;
    String? latitude;
    String? longitude;
    int? totalcreditbalanceforads;
    List<CategoryDetail?>? categorydetails;
    List<BusinessPromotionPostcode?>? businesspromotionpostcodes;

    BusinessModel({this.id, this.userid, this.businessname, this.businesslogo, this.location, this.latitude, this.longitude, this.totalcreditbalanceforads, this.categorydetails, this.businesspromotionpostcodes}); 

    BusinessModel.fromJson(Map<String, dynamic> json) {
        id = json['id'];
        userid = json['user_id'];
        businessname = json['business_name'];
        businesslogo = json['business_logo'];
        location = json['location'];
        latitude = json['latitude'];
        longitude = json['longitude'];
        totalcreditbalanceforads = json['total_credit_balance_for_ads'];
        if (json['category_details'] != null) {
         categorydetails = <CategoryDetail>[];
         json['category_details'].forEach((v) {
         categorydetails!.add(CategoryDetail.fromJson(v));
        });
      }
        if (json['business_promotion_postcodes'] != null) {
         businesspromotionpostcodes = <BusinessPromotionPostcode>[];
         json['business_promotion_postcodes'].forEach((v) {
         businesspromotionpostcodes!.add(BusinessPromotionPostcode.fromJson(v));
        });
      }
    }

    Map<String, dynamic> toJson() {
        final Map<String, dynamic> data = Map<String, dynamic>();
        data['id'] = id;
        data['user_id'] = userid;
        data['business_name'] = businessname;
        data['business_logo'] = businesslogo;
        data['location'] = location;
        data['latitude'] = latitude;
        data['longitude'] = longitude;
        data['total_credit_balance_for_ads'] = totalcreditbalanceforads;
        data['category_details'] =categorydetails != null ? categorydetails!.map((v) => v?.toJson()).toList() : null;
        data['business_promotion_postcodes'] =businesspromotionpostcodes != null ? businesspromotionpostcodes!.map((v) => v?.toJson()).toList() : null;
        return data;
    }
}

