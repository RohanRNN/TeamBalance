/* 
// Example Usage
Map<String, dynamic> map = jsonDecode(<myJSONString>);
var myRootNode = Root.fromJson(map);
*/ 
class UserListModel {
    int? id;
    int? blockeruserid;
    int? blockeduserid;
    User? user;

    UserListModel({this.id, this.blockeruserid, this.blockeduserid, this.user}); 

    UserListModel.fromJson(Map<String, dynamic> json) {
        id = json['id'];
        blockeruserid = json['blocker_user_id'];
        blockeduserid = json['blocked_user_id'];
        user = json['user'] != null ? User?.fromJson(json['user']) : null;
    }

    Map<String, dynamic> toJson() {
        final Map<String, dynamic> data = Map<String, dynamic>();
        data['id'] = id;
        data['blocker_user_id'] = blockeruserid;
        data['blocked_user_id'] = blockeduserid;
        data['user'] = user!.toJson();
        return data;
    }
}

class User {
    int? id;
    String? fullname;
    String? profileimage;

    User({this.id, this.fullname, this.profileimage}); 

    User.fromJson(Map<String, dynamic> json) {
        id = json['id'];
        fullname = json['full_name'];
        profileimage = json['profile_image'] ?? '';
    }

    Map<String, dynamic> toJson() {
        final Map<String, dynamic> data = Map<String, dynamic>();
        data['id'] = id;
        data['full_name'] = fullname;
        data['profile_image'] = profileimage ?? '';
        return data;
    }
}

