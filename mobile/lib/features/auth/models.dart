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
    this.address,
  });

  factory AppUser.fromJson(Map<String, dynamic> json) {
    final documents = (json['documents'] as Map?)?.cast<String, dynamic>() ?? const {};
    return AppUser(
      id: (json['id'] as num).toInt(),
      name: json['name'] as String,
      phone: json['phone'] as String,
      nationalId: json['national_id'] as String?,
      address: json['address'] as String?,
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
  final String? address;
  final String role;
  final bool kycCompleted;
  final DocumentStatus idImage;
  final DocumentStatus licenseImage;

  bool get isCustomer => role == 'customer';
}

/// A signed-in session returned by login, registration and password reset.
class LoggedIn {
  const LoggedIn({required this.token, required this.user});

  final String token;
  final AppUser user;
}

/// The sign-up form.
class RegistrationInput {
  const RegistrationInput({
    required this.firstName,
    required this.lastName,
    required this.phone,
    required this.address,
    required this.password,
  });

  final String firstName;
  final String lastName;

  /// Local format, e.g. 0911234567.
  final String phone;
  final String address;
  final String password;

  Map<String, dynamic> toJson() => {
    'first_name': firstName,
    'last_name': lastName,
    'phone': phone,
    'address': address,
    'password': password,
    'password_confirmation': password,
  };
}

/// What happened after sending the sign-up form.
sealed class RegistrationStep {
  const RegistrationStep();
}

/// An SMS code was sent: send the form again with it.
class PhoneCodeSent extends RegistrationStep {
  const PhoneCodeSent({required this.resendAfterSeconds});

  final int resendAfterSeconds;
}

/// The account exists and the user is signed in.
class Registered extends RegistrationStep {
  const Registered();
}
