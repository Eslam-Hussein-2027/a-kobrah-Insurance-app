// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Alarabia Kobrah Insurance';

  @override
  String get welcome => 'Welcome';

  @override
  String get loginSubtitle => 'Sign in with your phone number to manage your car insurance';

  @override
  String get phoneLabel => 'Phone number';

  @override
  String get sendCode => 'Send verification code';

  @override
  String get verifyPolicyLink => 'Verify an insurance policy';

  @override
  String get otpTitle => 'Verification code';

  @override
  String otpSubtitle(String phone) {
    return 'Enter the 6-digit code sent to $phone';
  }

  @override
  String get otpLength => 'The code must be 6 digits';

  @override
  String get confirm => 'Confirm';

  @override
  String get resendCode => 'Resend code';

  @override
  String resendIn(int seconds) {
    return 'Resend in $seconds s';
  }

  @override
  String get codeResent => 'A new code has been sent';

  @override
  String get registerTitle => 'Complete registration';

  @override
  String get registerSubtitle => 'Your phone number is verified. Complete your details to create the account.';

  @override
  String get fullName => 'Full name';

  @override
  String get nationalNumber => 'National number';

  @override
  String get idImage => 'Identity document image';

  @override
  String get licenseImage => 'Driving license image';

  @override
  String get documentsOptionalHint =>
      'You can upload documents now or later from \"Account\". They are required before a policy is issued.';

  @override
  String get chooseImage => 'Choose image';

  @override
  String get imageSelected => 'Image selected';

  @override
  String get createAccount => 'Create account';

  @override
  String get registrationExpired => 'Registration session expired. Please request a new code.';

  @override
  String get camera => 'Camera';

  @override
  String get gallery => 'Gallery';

  @override
  String get tabVehicles => 'My vehicles';

  @override
  String get tabPolicies => 'My policies';

  @override
  String get tabProfile => 'Account';

  @override
  String get addVehicle => 'Add vehicle';

  @override
  String get editVehicle => 'Edit vehicle';

  @override
  String get noVehicles => 'You haven\'t added a vehicle yet';

  @override
  String get noVehiclesHint => 'Add your vehicle to insure it';

  @override
  String get plateNo => 'Plate number';

  @override
  String get plateHint => 'e.g. 5-123456';

  @override
  String get vin => 'Chassis number (VIN)';

  @override
  String get vinHint => '17 letters and digits';

  @override
  String get make => 'Make';

  @override
  String get model => 'Model';

  @override
  String get year => 'Year';

  @override
  String get engineCc => 'Engine (cc)';

  @override
  String get ccUnit => 'cc';

  @override
  String get save => 'Save';

  @override
  String get delete => 'Delete';

  @override
  String get edit => 'Edit';

  @override
  String get cancel => 'Cancel';

  @override
  String get insureVehicle => 'Insure vehicle';

  @override
  String get deleteVehicleTitle => 'Delete vehicle';

  @override
  String deleteVehicleConfirm(String plate) {
    return 'Delete vehicle $plate?';
  }

  @override
  String get vehicleAdded => 'Vehicle added';

  @override
  String get vehicleUpdated => 'Vehicle updated';

  @override
  String get vehicleDeleted => 'Vehicle deleted';

  @override
  String get vehicleNotFound => 'Vehicle not found';

  @override
  String get noPolicies => 'No insurance policies yet';

  @override
  String get noPoliciesHint => 'Go to \"My vehicles\" and tap \"Insure vehicle\"';

  @override
  String get policyNo => 'Policy number';

  @override
  String get coverage => 'Insurance type';

  @override
  String get startDate => 'Start date';

  @override
  String get endDate => 'End date';

  @override
  String get issuedAt => 'Issue date';

  @override
  String get premium => 'Premium';

  @override
  String get vehicle => 'Vehicle';

  @override
  String get policyDetails => 'Policy details';

  @override
  String get downloadPdf => 'Download policy for printing (PDF)';

  @override
  String get pdfMobileOnly => 'Policy download is available in the mobile app';

  @override
  String get pendingPaymentTitle => 'Awaiting payment';

  @override
  String get pendingPaymentBody =>
      'You can pay the premium online now. Once the payment is confirmed you can download and print the policy right away.';

  @override
  String get customerService => 'Customer service';

  @override
  String get cancelRequest => 'Cancel request';

  @override
  String get cancelRequestConfirm => 'Cancel this policy request?';

  @override
  String get policyCancelled => 'Request cancelled';

  @override
  String get policyCreated => 'Policy created. Please complete the payment to activate it';

  @override
  String get quoteTitle => 'Insurance price';

  @override
  String get basePrice => 'Base price';

  @override
  String get priceDetails => 'Price details';

  @override
  String get totalPremium => 'Total premium';

  @override
  String get coverageStart => 'Coverage start date';

  @override
  String get issuePolicy => 'Issue policy';

  @override
  String get kycMissingTitle => 'Documents required';

  @override
  String get kycMissingBody => 'Upload your identity document and driving license images before issuing a policy.';

  @override
  String get goToProfile => 'Upload documents';

  @override
  String get documents => 'Documents';

  @override
  String get uploaded => 'Uploaded';

  @override
  String get notUploaded => 'Not uploaded';

  @override
  String get upload => 'Upload';

  @override
  String get replace => 'Replace';

  @override
  String get documentUploaded => 'Document uploaded';

  @override
  String get language => 'Language';

  @override
  String get logout => 'Log out';

  @override
  String get logoutConfirm => 'Do you want to log out?';

  @override
  String get verifyTitle => 'Verify a policy';

  @override
  String get verifySubtitle => 'Enter the policy number and plate number to check validity';

  @override
  String get check => 'Check';

  @override
  String get retry => 'Retry';

  @override
  String get requiredField => 'This field is required';

  @override
  String get networkError => 'Can\'t reach the server. Check your connection and try again.';

  @override
  String get unexpectedError => 'Something went wrong. Please try again.';

  @override
  String get currency => 'LYD';

  @override
  String get payOnline => 'Pay online now';

  @override
  String get checkPaymentStatus => 'Check payment status';

  @override
  String get orPayAtOffice => 'Or pay at one of our offices and mention the policy number.';

  @override
  String get paymentSucceeded => 'Payment successful, policy activated';

  @override
  String get paymentFailed => 'The payment was not completed. You can try again';

  @override
  String get paymentNotConfirmedYet => 'Payment not confirmed yet, try again in a moment';
}
