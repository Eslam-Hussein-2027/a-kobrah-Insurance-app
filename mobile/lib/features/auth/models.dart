class DocumentStatus {
  const DocumentStatus({required this.uploaded, this.url});

  factory DocumentStatus.fromJson(Object? json) {
    if (json is! Map) {
      return const DocumentStatus(uploaded: false);
    }
    return DocumentStatus(uploaded: json['uploaded'] == true, url: json['url'] as String?);
  }

  final bool uploaded;

  /// Short-lived signed URL (private storage).
  final String? url;
}

class AppUser {
  const AppUser({
    required this.id,
    required this.name,
    required this.phone,
    required this.role,
    required this.kycCompleted,
    required this.idImage,
    required this.licenseImage,
    this.nationalId,
  });

  factory AppUser.fromJson(Map<String, dynamic> json) {
    final documents = (json['documents'] as Map?)?.cast<String, dynamic>() ?? const {};
    return AppUser(
      id: (json['id'] as num).toInt(),
      name: json['name'] as String,
      phone: json['phone'] as String,
      nationalId: json['national_id'] as String?,
      role: ((json['role'] as Map?)?['value'] as String?) ?? 'customer',
      kycCompleted: json['kyc_completed'] == true,
      idImage: DocumentStatus.fromJson(documents['id_image']),
      licenseImage: DocumentStatus.fromJson(documents['license_image']),
    );
  }

  final int id;
  final String name;
  final String phone;
  final String? nationalId;
  final String role;
  final bool kycCompleted;
  final DocumentStatus idImage;
  final DocumentStatus licenseImage;

  bool get isCustomer => role == 'customer';
}

/// Result of verifying an OTP code.
sealed class OtpVerification {
  const OtpVerification();
}

class LoggedIn extends OtpVerification {
  const LoggedIn({required this.token, required this.user});

  final String token;
  final AppUser user;
}

class NeedsRegistration extends OtpVerification {
  const NeedsRegistration(this.registrationToken);

  final String registrationToken;
}
