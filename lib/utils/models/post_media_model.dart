import 'dart:io';

class PostMediaModel {
    String? media_type;
    File? media_name;
    File? thumbnail;

    PostMediaModel({this.media_type, this.media_name, this.thumbnail}); 

    PostMediaModel.fromJson(Map<String, dynamic> json) {
        media_type = json['media_type'];
        media_name = json['media_name'];
        thumbnail = json['thumbnail'];
    }

    Map<String, dynamic> toJson() {
        final Map<String, dynamic> data = Map<String, dynamic>();
        data['media_type'] = media_type;
        data['media_name'] = media_name;
        data['thumbnail'] = thumbnail;
        return data;
    }
}