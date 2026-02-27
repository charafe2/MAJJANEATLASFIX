import 'package:dio/dio.dart';
import 'package:image_picker/image_picker.dart';
import '../../core/netwrok/api_client.dart';
import '../../core/constants/api_constants.dart';

// ── Models ────────────────────────────────────────────────────────────────────

class Conversation {
  final int     id;
  final String  otherName;
  final String  otherRole;
  final String? otherAvatar;
  final int?    otherProfileId;
  final String  lastMessage;
  final DateTime? lastAt;
  final int     unread;

  const Conversation({
    required this.id, required this.otherName, required this.otherRole,
    this.otherAvatar, this.otherProfileId,
    required this.lastMessage, this.lastAt, required this.unread,
  });

  factory Conversation.fromJson(Map<String, dynamic> j) => Conversation(
    id:              j['id'] as int,
    otherName:       j['other_name'] as String? ?? 'Utilisateur',
    otherRole:       j['other_role'] as String? ?? '',
    otherAvatar:     j['other_avatar'] as String?,
    otherProfileId:  j['other_profile_id'] as int?,
    lastMessage:     j['last_message'] as String? ?? '',
    lastAt:          DateTime.tryParse(j['last_message_at'] as String? ?? ''),
    unread:          j['unread_count'] as int? ?? 0,
  );
}

class Message {
  final int     id;
  final int     senderId;
  final String? content;
  final String  type;       // text | image
  final String? imageUrl;
  final bool    isRead;
  final DateTime createdAt;

  const Message({
    required this.id, required this.senderId, this.content,
    required this.type, this.imageUrl, required this.isRead,
    required this.createdAt,
  });

  bool get isImage => type == 'image';

  factory Message.fromJson(Map<String, dynamic> j) => Message(
    id:        j['id'] as int,
    senderId:  j['sender_id'] as int,
    content:   j['content'] as String?,
    type:      j['message_type'] as String? ?? 'text',
    imageUrl:  j['image_url'] as String?,
    isRead:    j['is_read'] as bool? ?? false,
    createdAt: DateTime.tryParse(j['created_at'] as String? ?? '')
               ?? DateTime.now(),
  );
}

class ConversationDetail {
  final int     id;
  final String  otherName;
  final String  otherRole;
  final String? otherAvatar;
  final int?    otherProfileId;
  const ConversationDetail({
    required this.id, required this.otherName, required this.otherRole,
    this.otherAvatar, this.otherProfileId,
  });

  factory ConversationDetail.fromJson(Map<String, dynamic> j) => ConversationDetail(
    id:             j['id'] as int,
    otherName:      j['other_name'] as String? ?? 'Utilisateur',
    otherRole:      j['other_role'] as String? ?? '',
    otherAvatar:    j['other_avatar'] as String?,
    otherProfileId: j['other_profile_id'] as int?,
  );
}

// ── Repository ────────────────────────────────────────────────────────────────

class ConversationRepository {
  final _dio = ApiClient.instance;

  Future<List<Conversation>> getConversations() async {
    final res = await _dio.get(ApiConstants.conversations);
    final raw = (res.data['data'] ?? res.data) as List<dynamic>;
    return raw.map((e) => Conversation.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<ConversationDetail> getOrCreate({
    int? artisanId,
    int? clientId,
    int? serviceRequestId,
  }) async {
    final res = await _dio.post(ApiConstants.conversations, data: {
      if (artisanId != null) 'artisan_id': artisanId,
      if (clientId  != null) 'client_id':  clientId,
      if (serviceRequestId != null) 'service_request_id': serviceRequestId,
    });
    return ConversationDetail.fromJson(
        (res.data['data'] ?? res.data) as Map<String, dynamic>);
  }

  Future<ConversationDetail> getConversation(int id) async {
    final res = await _dio.get('${ApiConstants.conversations}/$id');
    return ConversationDetail.fromJson(
        (res.data['data'] ?? res.data) as Map<String, dynamic>);
  }

  Future<List<Message>> getMessages(int conversationId) async {
    final res = await _dio.get('${ApiConstants.conversations}/$conversationId/messages');
    final raw = (res.data['data'] ?? res.data) as List<dynamic>;
    return raw.map((e) => Message.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<Message> sendText(int conversationId, String content) async {
    final res = await _dio.post(
      '${ApiConstants.conversations}/$conversationId/messages',
      data: {'content': content},
    );
    return Message.fromJson((res.data['data'] ?? res.data) as Map<String, dynamic>);
  }

  Future<Message> sendImage(int conversationId, XFile image, {String? caption}) async {
    final bytes = await image.readAsBytes();
    final ext = image.name.contains('.') ? image.name.split('.').last : 'jpg';
    final fd = FormData.fromMap({
      'image': MultipartFile.fromBytes(bytes, filename: 'image.$ext'),
      if (caption != null && caption.isNotEmpty) 'content': caption,
    });
    final res = await _dio.post(
      '${ApiConstants.conversations}/$conversationId/messages',
      data:    fd,
      options: Options(contentType: 'multipart/form-data'),
    );
    return Message.fromJson((res.data['data'] ?? res.data) as Map<String, dynamic>);
  }

  Future<void> markRead(int conversationId) =>
      _dio.post('${ApiConstants.conversations}/$conversationId/read');

  Future<void> report(int conversationId, String reason) =>
      _dio.post('${ApiConstants.conversations}/$conversationId/report',
          data: {'reason': reason});

  static String errorMessage(Object e) {
    if (e is DioException) {
      final b = e.response?.data;
      if (b is Map) {
        return (b['message'] ?? b['error'] ?? 'Une erreur est survenue').toString();
      }
      if (e.type == DioExceptionType.connectionError ||
          e.type == DioExceptionType.connectionTimeout) {
        return 'Impossible de se connecter au serveur.';
      }
    }
    return 'Une erreur est survenue.';
  }
}
