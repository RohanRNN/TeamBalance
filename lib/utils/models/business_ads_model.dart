class AdsMediaForHome {
    int? id;
    int? businessadvertisementid;
    
    String? medianame;
    String? thumbnail;
    bool? isvideomedia;

    AdsMediaForHome({this.id, this.businessadvertisementid,  this.medianame, this.thumbnail, this.isvideomedia}); 

    AdsMediaForHome.fromJson(Map<String, dynamic> json) {
        id = json['id'];
        businessadvertisementid = json['business_advertisement_id'];
        
        medianame = json['media_name'];
        thumbnail = json['thumbnail'];
        isvideomedia = json['is_video_media'];
    }

    Map<String, dynamic> toJson() {
        final Map<String, dynamic> data = Map<String, dynamic>();
        data['id'] = id;
        data['business_advertisement_id'] = businessadvertisementid;
         
        data['media_name'] = medianame;
        data['thumbnail'] = thumbnail;
        data['is_video_media'] = isvideomedia;
        return data;
    }
}

class BusinessAdvertise {
    int? userid;
    int? businessid;
    int? businessadvertisementid;
    String? advertisementpromotionarea;
    String? businessname;
    String? businesslogo;
    bool? isactive;
    String? expirydate;
    List<AdsMediaForHome?>? ads;

    BusinessAdvertise({this.userid, this.businessid, this.businessadvertisementid, this.advertisementpromotionarea, this.businesslogo, this.isactive, this.expirydate, this.ads, this.businessname}); 

    BusinessAdvertise.fromJson(Map<String, dynamic> json) {
        userid = json['user_id'];
        businessid = json['business_id'];
        businessadvertisementid = json['business_advertisement_id'];
        advertisementpromotionarea = json['advertisement_promotion_area'];
        businessname = json['business_name'];
        businesslogo = json['business_logo'];
        isactive = json['is_active'];
        expirydate = json['expiry_date'];
        if (json['ads'] != null) {
         ads = <AdsMediaForHome>[];
         json['ads'].forEach((v) {
         ads!.add(AdsMediaForHome.fromJson(v));
        });
      }
    }

    Map<String, dynamic> toJson() {
        final Map<String, dynamic> data = Map<String, dynamic>();
        data['user_id'] = userid;
        data['business_id'] = businessid;
        data['business_advertisement_id'] = businessadvertisementid;
        data['advertisement_promotion_area'] = advertisementpromotionarea;
        data['business_name'] = businessname;
        data['business_logo'] = businesslogo;
        data['is_active'] = isactive;
        data['expiry_date'] = expirydate;
        data['ads'] =ads != null ? ads!.map((v) => v?.toJson()).toList() : null;
        return data;
    }
}