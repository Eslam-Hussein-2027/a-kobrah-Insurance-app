import '../vehicles/vehicle.dart';

class CoverageType {
  const CoverageType({
    required this.id,
    required this.code,
    required this.name,
    required this.basePrice,
    required this.isMandatory,
    this.description,
  });

  factory CoverageType.fromJson(Map<String, dynamic> json) => CoverageType(
    id: (json['id'] as num).toInt(),
    code: json['code'] as String,
    name: json['name'] as String,
    description: json['description'] as String?,
    basePrice: json['base_price'].toString(),
    isMandatory: json['is_mandatory'] == true,
  );

  final int id;
  final String code;
  final String name;
  final String? description;
  final String basePrice;
  final bool isMandatory;
}

class QuoteFactor {
  const QuoteFactor({required this.type, required this.label, required this.input, required this.multiplier});

  factory QuoteFactor.fromJson(Map<String, dynamic> json) => QuoteFactor(
    type: json['type'] as String,
    label: json['label'] as String,
    input: (json['input'] as num).toInt(),
    multiplier: json['multiplier'].toString(),
  );

  final String type;
  final String label;
  final int input;
  final String multiplier;
}

class Quote {
  const Quote({required this.basePrice, required this.factors, required this.premium, required this.currency});

  factory Quote.fromJson(Map<String, dynamic> json) => Quote(
    basePrice: json['base_price'].toString(),
    factors: (json['factors'] as List).cast<Map<String, dynamic>>().map(QuoteFactor.fromJson).toList(),
    premium: json['premium'].toString(),
    currency: json['currency'] as String,
  );

  final String basePrice;
  final List<QuoteFactor> factors;
  final String premium;
  final String currency;
}

enum PolicyStatus {
  pendingPayment('PENDING_PAYMENT'),
  active('ACTIVE'),
  expired('EXPIRED'),
  cancelled('CANCELLED'),
  unknown('');

  const PolicyStatus(this.value);

  final String value;

  static PolicyStatus fromValue(String value) =>
      PolicyStatus.values.firstWhere((s) => s.value == value, orElse: () => PolicyStatus.unknown);
}

class Policy {
  const Policy({
    required this.id,
    required this.policyNo,
    required this.status,
    required this.statusLabel,
    required this.startDate,
    required this.endDate,
    required this.premium,
    required this.canDownloadPdf,
    this.issuedAt,
    this.vehicle,
    this.coverageType,
  });

  factory Policy.fromJson(Map<String, dynamic> json) {
    final status = json['status'] as Map<String, dynamic>;
    return Policy(
      id: (json['id'] as num).toInt(),
      policyNo: json['policy_no'] as String,
      status: PolicyStatus.fromValue(status['value'] as String),
      statusLabel: status['label'] as String,
      startDate: json['start_date'] as String,
      endDate: json['end_date'] as String,
      premium: json['premium'].toString(),
      issuedAt: json['issued_at'] as String?,
      canDownloadPdf: json['can_download_pdf'] == true,
      vehicle: json['vehicle'] is Map ? Vehicle.fromJson((json['vehicle'] as Map).cast<String, dynamic>()) : null,
      coverageType: json['coverage_type'] is Map
          ? CoverageType.fromJson((json['coverage_type'] as Map).cast<String, dynamic>())
          : null,
    );
  }

  final int id;
  final String policyNo;
  final PolicyStatus status;

  /// Localized by the server.
  final String statusLabel;
  final String startDate;
  final String endDate;
  final String premium;
  final String? issuedAt;
  final bool canDownloadPdf;
  final Vehicle? vehicle;
  final CoverageType? coverageType;
}

class PolicyVerification {
  const PolicyVerification({
    required this.result,
    required this.label,
    this.policyNo,
    this.coverageType,
    this.startDate,
    this.endDate,
  });

  factory PolicyVerification.fromJson(Map<String, dynamic> json) {
    final result = json['result'] as Map<String, dynamic>;
    return PolicyVerification(
      result: result['value'] as String,
      label: result['label'] as String,
      policyNo: json['policy_no'] as String?,
      coverageType: json['coverage_type'] as String?,
      startDate: json['start_date'] as String?,
      endDate: json['end_date'] as String?,
    );
  }

  /// VALID | EXPIRED | NOT_FOUND
  final String result;
  final String label;
  final String? policyNo;
  final String? coverageType;
  final String? startDate;
  final String? endDate;

  bool get isValid => result == 'VALID';

  bool get isExpired => result == 'EXPIRED';
}
