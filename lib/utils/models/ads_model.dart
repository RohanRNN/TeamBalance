class AdsMediaModel {
    int? id;
    int? businessadvertisementid;
    String? medianame;
    String? thumbnail;
    bool? isvideomedia;

    AdsMediaModel({this.id, this.businessadvertisementid, this.medianame, this.thumbnail, this.isvideomedia}); 

    AdsMediaModel.fromJson(Map<String, dynamic> json) {
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

class AdvertisementModel {
    int? businessadvertisementid;
    String? advertisementpromotionarea;
    bool? isactive;
    String? expirydate;
    List<AdsMediaModel?>? ads;

    AdvertisementModel({this.businessadvertisementid, this.advertisementpromotionarea, this.isactive, this.expirydate, this.ads}); 

    AdvertisementModel.fromJson(Map<String, dynamic> json) {
        businessadvertisementid = json['business_advertisement_id'];
        advertisementpromotionarea = json['advertisement_promotion_area'];
        isactive = json['is_active'];
        expirydate = json['expiry_date'];
        if (json['ads'] != null) {
         ads = <AdsMediaModel>[];
         json['ads'].forEach((v) {
         ads!.add(AdsMediaModel.fromJson(v));
        });
      }
    }

    Map<String, dynamic> toJson() {
        final Map<String, dynamic> data = Map<String, dynamic>();
        data['business_advertisement_id'] = businessadvertisementid;
        data['advertisement_promotion_area'] = advertisementpromotionarea;
        data['is_active'] = isactive;
        data['expiry_date'] = expirydate;
        data['ads'] =ads != null ? ads!.map((v) => v?.toJson()).toList() : null;
        return data;
    }
}