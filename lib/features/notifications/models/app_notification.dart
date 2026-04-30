class AppNotification {
  final String id;
  final String title;
  final String body;
  final DateTime? createdAt;
  final bool read;

  const AppNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.createdAt,
    required this.read,
  });

  static bool _truthy(dynamic v) {
    if (v == null) return false;
    if (v is bool) return v;
    if (v is num) return v != 0;
    if (v is String) {
      final s = v.trim().toLowerCase();
      return s == 'true' || s == '1' || s == 'yes' || s == 'read';
    }
    return false;
  }

  static DateTime? _parseDate(dynamic v) {
    if (v == null) return null;
    if (v is DateTime) return v;
    final s = v.toString().trim();
    if (s.isEmpty) return null;
    return DateTime.tryParse(s);
  }

  factory AppNotification.fromJson(Map<String, dynamic> json) {
    final id =
        (json['id'] ??
                json['_id'] ??
                json['notification_id'] ??
                json['notificationId'] ??
                '')
            .toString();

    final title =
        (json['title'] ?? json['subject'] ?? json['type'] ?? 'Notification')
            .toString();

    final body =
        (json['body'] ??
                json['message'] ??
                json['content'] ??
                json['detail'] ??
                '')
            .toString();

    final createdAt = _parseDate(
      json['created_at'] ??
          json['createdAt'] ??
          json['timestamp'] ??
          json['time'],
    );

    final read = _truthy(json['read'] ?? json['is_read'] ?? json['isRead']);

    return AppNotification(
      id: id.isEmpty ? title.hashCode.toString() : id,
      title: title,
      body: body,
      createdAt: createdAt,
      read: read,
    );
  }
}

