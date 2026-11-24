/// A request for a product that staff price and issue manually.
class InsuranceRequest {
  const InsuranceRequest({
    required this.id,
    required this.requestNo,
    required this.productCode,
    required this.productName,
    required this.kind,
    required this.kindLabel,
    required this.status,
    required this.statusLabel,
    required this.details,
    required this.documents,
    required this.canCancel,
    required this.createdAt,
    this.notes,
    this.staffReply,
    this.quotedAmount,
    this.repliedAt,
  });

  factory InsuranceRequest.fromJson(Map<String, dynamic> json) {
    final product = json['product'] as Map<String, dynamic>;
    final kind = json['kind'] as Map<String, dynamic>;
    final status = json['status'] as Map<String, dynamic>;
    return InsuranceRequest(
      id: (json['id'] as num).toInt(),
      requestNo: json['request_no'] as String,
      productCode: product['value'] as String,
      productName: product['label'] as String,
      kind: kind['value'] == 'quote' ? RequestKind.quote : RequestKind.issue,
      kindLabel: kind['label'] as String,
      status: RequestStatus.fromValue(status['value'] as String),
      statusLabel: status['label'] as String,
      details: (json['details'] as List)
          .cast<Map<String, dynamic>>()
          .map((d) => (label: d['label'] as String, value: d['value'] as String))
          .toList(),
      documents: ((json['documents'] as List?) ?? const [])
          .cast<Map<String, dynamic>>()
          .map((d) => (label: d['label'] as String, name: d['name'] as String))
          .toList(),
      notes: json['notes'] as String?,
      staffReply: json['staff_reply'] as String?,
      quotedAmount: json['quoted_amount']?.toString(),
      repliedAt: json['replied_at'] as String?,
      canCancel: json['can_cancel'] == true,
      createdAt: json['created_at'] as String,
    );
  }

  final int id;
  final String requestNo;
  final String productCode;
  final String productName;
  final RequestKind kind;
  final String kindLabel;
  final RequestStatus status;
  final String statusLabel;
  final List<({String label, String value})> details;
  final List<({String label, String name})> documents;
  final String? notes;
  final String? staffReply;
  final String? quotedAmount;
  final String? repliedAt;
  final bool canCancel;
  final String createdAt;

  /// Short summary for lists: the first answers of the form.
  String get summary => details.take(2).map((d) => d.value).join(' · ');
}

enum RequestKind {
  issue('issue'),
  quote('quote');

  const RequestKind(this.value);

  final String value;

  static RequestKind fromValue(String? value) => value == 'quote' ? RequestKind.quote : RequestKind.issue;
}

enum RequestStatus {
  submitted('SUBMITTED'),
  inReview('IN_REVIEW'),
  quoted('QUOTED'),
  completed('COMPLETED'),
  rejected('REJECTED'),
  cancelled('CANCELLED');

  const RequestStatus(this.value);

  final String value;

  static RequestStatus fromValue(String value) =>
      RequestStatus.values.firstWhere((s) => s.value == value, orElse: () => RequestStatus.submitted);
}
