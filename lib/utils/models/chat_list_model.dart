/* 
// Example Usage
Map<String, dynamic> map = jsonDecode(<myJSONString>);
var myRootNode = Root.fromJson(map);
*/ 
class ConversationModel {
    int? id;
    int? createdby;
    int? receiverid;
    int? conversationid;
    int? senderid;
    String? messagecontent;
    bool? readat;
    int? profileuserid;
    String? fullname;
    String? profileimage;
    String? createdAt;
    String? updatedAt;
    bool? isDelete;
    int? newMessage;
    int? profileuserisDelete;

    ConversationModel({this.id, this.createdby, this.receiverid, this.conversationid, this.senderid, this.messagecontent, this.readat, this.profileuserid, this.fullname, this.profileimage, this.createdAt, this.updatedAt, this.isDelete, this.newMessage, this.profileuserisDelete}); 

    ConversationModel.fromJson(Map<String, dynamic> json) {
        id = json['id'];
        createdby = json['created_by'];
        receiverid = json['receiver_id'];
        conversationid = json['conversation_id'];
        senderid = json['sender_id'];
        messagecontent = json['message_content'];
        readat = json['read_at'];
        profileuserid = json['profile_user_id'];
        fullname = json['full_name'];
        profileimage = json['profile_image'] ?? '';
        createdAt = json['created_at'] ?? '';
        updatedAt = json['updated_at'] ?? '';
        profileimage = json['profile_image'] ?? '';
        isDelete = false;
        newMessage = json['read_at'] ? 0 : 1;
        profileuserisDelete = json['profile_user_is_delete'] ?? 0;
    }

    Map<String, dynamic> toJson() {
        final Map<String, dynamic> data = Map<String, dynamic>();
        data['id'] = id;
        data['created_by'] = createdby;
        data['receiver_id'] = receiverid;
        data['conversation_id'] = conversationid;
        data['sender_id'] = senderid;
        data['message_content'] = messagecontent;
        data['read_at'] = readat;
        data['profile_user_id'] = profileuserid;
        data['full_name'] = fullname;
        data['profile_image'] = profileimage ?? '';
        data['created_at'] = createdAt ?? '';
        data['updated_at'] = updatedAt ?? '';
        data['profile_image'] = isDelete ?? '';
        data['newMessage'] = newMessage ?? 0;
        data['profile_user_is_delete'] = profileuserisDelete ?? 0;
        return data;
    }
}

