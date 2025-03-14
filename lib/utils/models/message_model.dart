/* 
// Example Usage
Map<String, dynamic> map = jsonDecode(<myJSONString>);
var myRootNode = Root.fromJson(map);
*/
class MessageModel {
  int? conversationid;
  String? createdat;
  int? id;
  String? isdelete;
  String? istestdata;
  String? messagecontent;
  int? currentstatus;
  int? senderid;
  String? updatedat;

  MessageModel(
      {this.conversationid,
      this.createdat,
      this.id,
      this.isdelete,
      this.istestdata,
      this.messagecontent,
      this.currentstatus,
      this.senderid,
      this.updatedat});

  MessageModel.fromJson(Map<String, dynamic> json) {
    conversationid = json['conversation_id'];
    createdat = json['created_at'];
    id = json['id'];
    isdelete = json['is_delete'];
    istestdata = json['is_testdata'];
    messagecontent = json['message_content'];
    currentstatus =  0;
    senderid = json['sender_id'];
    updatedat = json['updated_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['conversation_id'] = conversationid;
    data['created_at'] = createdat;
    data['id'] = id;
    data['is_delete'] = isdelete;
    data['is_testdata'] = istestdata;
    data['message_content'] = messagecontent;
    data['current_status'] = currentstatus ?? 0;
    data['sender_id'] = senderid;
    data['updated_at'] = updatedat;
    return data;
  }
}
