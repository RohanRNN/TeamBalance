class CommentModel {
  CommentModel({
    required this.id,
    required this.userId,
    required this.fullName,
    required this.profileImage,
    required this.postId,
    required this.commentType,
    required this.subCommentsData,
    required this.parentCommentId,
    required this.comment,
    required this.createdAt,
    required this.commentMediaData,
  });
  late final int id;
  late final int userId;
  late final String fullName;
  late final String profileImage;
  late final int postId;
  late final String commentType;
  late final List<SubCommentsData> subCommentsData;
  late final int parentCommentId;
  late final String comment;
  late final String createdAt;
  late final List<dynamic> commentMediaData;
  
  CommentModel.fromJson(Map<String, dynamic> json){
    id = json['id']??0;
    userId = json['user_id']?? 0;
    fullName = json['full_name'] ?? '';
    profileImage = json['profile_image'] ?? '';
    postId = json['post_id'] ?? '';
    commentType = json['comment_type'] ?? '';
    subCommentsData = List.from(json['sub_comments_data']).map((e)=>SubCommentsData.fromJson(e)).toList();
    parentCommentId = json['parent_comment_id'] ?? 0;
    comment = json['comment'] ?? '';
    createdAt = json['created_at'];
    commentMediaData = List.castFrom<dynamic, dynamic>(json['comment_media_data']);
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['id'] = id;
    _data['user_id'] = userId;
    _data['full_name'] = fullName;
    _data['profile_image'] = profileImage;
    _data['post_id'] = postId;
    _data['comment_type'] = commentType;
    _data['sub_comments_data'] = subCommentsData.map((e)=>e.toJson()).toList();
    _data['parent_comment_id'] = parentCommentId;
    _data['comment'] = comment;
    _data['created_at'] = createdAt;
    _data['comment_media_data'] = commentMediaData;
    return _data;
  }
}

class SubCommentsData {
  SubCommentsData({
    required this.id,
    required this.userId,
    required this.fullName,
    required this.profileImage,
    required this.postId,
    required this.commentType,
    required this.parentCommentId,
     required this.comment,
    required this.createdAt,
    required this.commentMediaData,
  });
  late final int id;
  late final int userId;
  late final String fullName;
  late final String profileImage;
  late final int postId;
  late final String commentType;
  late final int parentCommentId;
  late final String comment;
  late final String createdAt;
  late final List<CommentMediaData> commentMediaData;
  
  SubCommentsData.fromJson(Map<String, dynamic> json){
    id = json['id'] ?? 0;
    userId = json['user_id'] ?? 0;
    fullName = json['full_name'] ?? '';
    profileImage = json['profile_image'] ?? '';
    postId = json['post_id'] ?? 0;
    commentType = json['comment_type'] ?? '';
    parentCommentId = json['parent_comment_id'] ?? 0;
    comment = json['comment'] ?? '';
    createdAt = '';
    // createdAt = json['created_at'] ?? '';
    commentMediaData = List.from(json['comment_media_data']).map((e)=>CommentMediaData.fromJson(e)).toList();
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['id'] = id;
    _data['user_id'] = userId;
    _data['full_name'] = fullName;
    _data['profile_image'] = profileImage;
    _data['post_id'] = postId;
    _data['comment_type'] = commentType;
    _data['parent_comment_id'] = parentCommentId;
    _data['comment'] = comment;
    _data['created_at'] = createdAt;
    _data['comment_media_data'] = commentMediaData.map((e)=>e.toJson()).toList();
    return _data;
  }
}

class CommentMediaData {
  CommentMediaData({
    required this.id,
    required this.postCommentId,
    required this.commentMediaName,
  });
  late final int id;
  late final int postCommentId;
  late final String commentMediaName;
  
  CommentMediaData.fromJson(Map<String, dynamic> json){
    id = json['id'];
    postCommentId = json['post_comment_id'] ?? 0;
    commentMediaName = json['comment_media_name'] ?? '';
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['id'] = id;
    _data['post_comment_id'] = postCommentId;
    _data['comment_media_name'] = commentMediaName;
    return _data;
  }
}