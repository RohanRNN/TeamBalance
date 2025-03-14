/* 
// Example Usage
Map<String, dynamic> map = jsonDecode(<myJSONString>);
var myRootNode = Root.fromJson(map);
*/ 
import 'package:intl/intl.dart';

class MediaDatum {
    int? id;
    int? postid;
    String? medianame;
    String?thumbnail;
    bool? isvideomedia;

    MediaDatum({this.id, this.postid, this.medianame, this.thumbnail, this.isvideomedia}); 

    MediaDatum.fromJson(Map<String, dynamic> json) {
        id = json['id'];
        postid = json['post_id'];
        medianame = json['media_name'];
        thumbnail = json['thumbnail'];
        isvideomedia = json['is_video_media'];
    }

    Map<String, dynamic> toJson() {
        final Map<String, dynamic> data = Map<String, dynamic>();
        data['id'] = id;
        data['post_id'] = postid;
        data['media_name'] = medianame;
        data['thumbnail'] = thumbnail;
        data['is_video_media'] = isvideomedia;
        return data;
    }
}

class PostModel {
    int? id;
    int? userid;
    String? fullname;
    String? profileimage;
    String? posttype;
    String? postdescription;
    String? thumbnail;
    String? createdate;
    String? date;
    String? time;
    int? totalComments;
    int? totalLikes;
    int? isliked;
    int? likedCount;
    List<MediaDatum?>? mediadata;

    PostModel({this.id, this.userid, this.fullname, this.profileimage, this.posttype, this.postdescription, this.thumbnail, this.createdate, this.date, this.time, this.isliked, this.mediadata, this.totalComments, this.likedCount, this.totalLikes}); 

    PostModel.fromJson(Map<String, dynamic> json) {
        id = json['id'];
        userid = json['user_id'];
        fullname = json['full_name'];
        profileimage = json['profile_image'] ?? '';
        posttype = json['post_type'];
        postdescription = json['post_description'];
        thumbnail = json['thumbnail'];
        createdate = json['created_at'];
        totalComments = json['totalComments'];
        totalLikes = json['totalLikes'] ?? 0;
        isliked = json['is_liked'];
        likedCount = 0;
        // likedCount = json['liked_count'];
            DateTime parsedDate = DateTime.parse(createdate!).toLocal();

    // Format the date and time
            String formattedDate = DateFormat('dd/MM/yyyy').format(parsedDate);
            String formattedTime = DateFormat('hh:mm a').format(parsedDate);
            date = formattedDate;
            time =  formattedTime;
        if (json['media_data'] != null) {
         mediadata = <MediaDatum>[];
         json['media_data'].forEach((v) {
         mediadata!.add(MediaDatum.fromJson(v));
        });
      }
    }

    Map<String, dynamic> toJson() {
        final Map<String, dynamic> data = Map<String, dynamic>();
        data['id'] = id;
        data['user_id'] = userid;
        data['full_name'] = fullname;
        data['profile_image'] = profileimage ?? '';
        data['post_type'] = posttype;
        data['post_description'] = postdescription;
        data['thumbnail'] = thumbnail;
        data['created_at'] = createdate;
        data['date'] = date;
        data['time'] = time;
        data['totalComments'] = totalComments;
        data['totalLikes'] = totalLikes;
        data['is_liked'] = isliked;
        data['liked_count'] = likedCount;
        data['media_data'] = mediadata != null ? mediadata!.map((v) => v?.toJson()).toList() : null;
        return data;
    }
}

