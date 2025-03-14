

class UserModel {
    int? id;
    String? fullname;
    String? emailid;
    String? countrycode;
    String? phonenumber;
    String? profileimage;
    String? gender;
    String? dateofbirth;
    int? totalposts;
    int? totalcreditsbalanceforads;
    String? bio;
    int? reportedpostcount;
    int? reportedcommentscount;
    bool? isbusinesscreated;
    bool? isresidencecreated;
    bool? isadmin;
    bool? isactive;
    String? emailOTP = '';
    String? postcodedistirct;
    String? streetname;
    bool? updateavailable;
    bool? isforceupdate;
    bool? isnewnotification;
    bool? isInConversationScreen;
  

    UserModel({this.id, this.fullname, this.emailid, this.countrycode, this.phonenumber, this.profileimage, this.gender, this.dateofbirth, this.totalposts, this.totalcreditsbalanceforads, this.bio, this.reportedpostcount, this.reportedcommentscount, this.isbusinesscreated,this.isresidencecreated, this.isadmin, this.isactive, this.postcodedistirct, this.streetname, this.updateavailable, this.isforceupdate, this.isnewnotification, this.isInConversationScreen}); 

    UserModel.fromJson(Map<String, dynamic> json) {
        id = json['id'];
        fullname = json['full_name'] ?? '';
        emailid = json['email_id']?? '';
        countrycode = json['country_code'] ?? '';
        phonenumber = json['phone_number'] ?? '';
        profileimage = json['profile_image'] ?? '';
        gender = json['gender'] ?? '0';

        // if(json['date_of_birth'] is String){
        //   dateofbirth = json['date_of_birth'];
              
        // }else{
        //  DateTime parsedDate = DateTime.parse(json['date_of_birth']==null ?'': json['date_of_birth']);
        //     dateofbirth = DateFormat('dd/MM/yyyy').format(parsedDate); 
        // }
        //     //  DateTime parsedDate = DateTime.parse(json['date_of_birth']!);
            // dateofbirth = DateFormat('dd/MM/yyyy').format(parsedDate); 
            dateofbirth = json['date_of_birth'] ?? '';
        totalposts = json['total_posts'] ?? 0;
        totalcreditsbalanceforads = json['total_credits_balance_for_ads'] ?? 0;
        bio = json['bio'] ?? '';
        reportedpostcount = json['reported_post_count'] ?? 0;
        reportedcommentscount = json['reported_comments_count'] ?? 0;
        isbusinesscreated = json['is_business_created'] ?? false;
        isresidencecreated = json['is_residence_created'] ?? false;
        isadmin = json['is_admin'] ?? false;
        isactive = json['is_active'] ?? false;
        emailOTP = json['new_otp'] ?? '';
        postcodedistirct = json['postcode_distirct']?? '';
        streetname = json['street_name']?? '';
        updateavailable = json['update_available'] ?? false;
        isforceupdate = json['is_force_update'] ?? false;
        isnewnotification = json['is_new_notification'] ?? false;
        isInConversationScreen = false;
    }

    Map<String, dynamic> toJson() {
        final Map<String, dynamic> data = Map<String, dynamic>();
        data['id'] = id;
        data['full_name'] = fullname;
        data['email_id'] = emailid;
        data['country_code'] = countrycode;
        data['phone_number'] = phonenumber;
        data['profile_image'] = profileimage;
        data['gender'] = gender;
        data['date_of_birth'] = dateofbirth;
        data['total_posts'] = totalposts;
        data['total_credits_balance_for_ads'] = totalcreditsbalanceforads;
        data['bio'] = bio;
        data['reported_post_count'] = reportedpostcount;
        data['reported_comments_count'] = reportedcommentscount;
        data['is_business_created'] = isbusinesscreated;
        data['is_residence_created'] = isresidencecreated;
        data['is_admin'] = isadmin;
        data['is_active'] = isactive;
        data['new_otp'] = emailOTP;
        data['postcode_distirct'] = postcodedistirct;
        data['street_name'] = streetname;
        data['update_available'] = updateavailable;
        data['is_force_update'] = isforceupdate;
        data['is_new_notification'] = isnewnotification;
        return data;
    }
}