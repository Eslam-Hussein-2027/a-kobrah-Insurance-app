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
  String get loginSubtitle => 'Sign in with your phone number to manage your insurance';

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
      'You can upload the documents now or later from More → Personal information. They are required before issuing a compulsory policy.';

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
  String get tabVehicles => 'Vehicles';

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
  String get engineCc => 'Engine size';

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
  String get noPolicies => 'No insurance policies yet';

  @override
  String get noPoliciesHint => 'Choose a product on the home screen to issue your first policy.';

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
  String get cancelRequestConfirm => 'Cancel this policy request?';

  @override
  String get policyCancelled => 'Request cancelled';

  @override
  String get policyCreated => 'Policy created. Please complete the payment to activate it';

  @override
  String get basePrice => 'Base price';

  @override
  String get priceDetails => 'Price details';

  @override
  String get coverageStart => 'Coverage start date';

  @override
  String get issuePolicy => 'Issue policy';

  @override
  String get kycMissingTitle => 'Documents required';

  @override
  String get kycMissingBody => 'Upload your ID and driving licence images before issuing a compulsory policy.';

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

  @override
  String get verificationQrTitle => 'Policy verification code';

  @override
  String get verificationQrHint =>
      'Traffic police, government bodies and companies can scan this code with a phone camera to confirm the policy is genuine.';

  @override
  String get tabHome => 'Home';

  @override
  String get tabMyInsurance => 'My insurance';

  @override
  String get tabAccount => 'My account';

  @override
  String get hello => 'Hello,';

  @override
  String get contactUs => 'Contact us';

  @override
  String get insuranceProducts => 'Insurance products';

  @override
  String myPoliciesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'My policies ($count)',
      zero: 'My policies',
    );
    return '$_temp0';
  }

  @override
  String get instantIssue => 'Instant issue';

  @override
  String get onRequest => 'On request';

  @override
  String get calculatePrice => 'Calculate price';

  @override
  String get verifyPolicyShort => 'Verify a policy';

  @override
  String get branches => 'Branches';

  @override
  String get uninsuredVehicle => 'Vehicle without insurance';

  @override
  String get insureItNow => 'Insure it now';

  @override
  String get noActivePolicy => 'No active policy';

  @override
  String get noActivePolicyHint => 'Issue your vehicle\'s compulsory policy in minutes.';

  @override
  String get verificationCode => 'Verification code';

  @override
  String endsOn(String date) {
    return 'Ends on $date';
  }

  @override
  String daysLeft(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count days left',
      one: '1 day left',
      zero: 'Ends today',
    );
    return '$_temp0';
  }

  @override
  String otherActivePolicies(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'You have $count more active policies in My insurance',
      one: 'You have 1 more active policy in My insurance',
    );
    return '$_temp0';
  }

  @override
  String get issuedInstantly => 'Issued instantly in the app';

  @override
  String get issuedAfterReview => 'Issued after the company reviews your request';

  @override
  String get issuePolicyHint => 'Pay online and get the policy right away';

  @override
  String get requestPolicy => 'Request a policy';

  @override
  String get requestPolicyHint => 'Send your details and an employee will contact you';

  @override
  String get knowThePrice => 'Know the price';

  @override
  String get knowThePriceHint => 'Calculate the price before you buy';

  @override
  String get requestQuote => 'Request a price offer';

  @override
  String get requestQuoteHint => 'You\'ll get a price within one working day';

  @override
  String get whatIsCovered => 'What is covered';

  @override
  String get requiredDocuments => 'Required documents';

  @override
  String get haveAQuestion => 'Questions? Call us on';

  @override
  String get add => 'Add';

  @override
  String get more => 'More';

  @override
  String get choose => 'Choose';

  @override
  String get optional => 'optional';

  @override
  String get notes => 'Notes';

  @override
  String get notice => 'Please note';

  @override
  String get total => 'Total';

  @override
  String get continueLabel => 'Continue';

  @override
  String get stepReview => 'Step 2 of 3 · Review';

  @override
  String get payAfterIssueHint => 'After issuing, you\'ll go to the policy page to pay online or at the head office.';

  @override
  String get issueNow => 'Issue the policy now';

  @override
  String get estimateDisclaimer => 'This is an estimate; the final price is shown when you issue the policy.';

  @override
  String get estimatedPrice => 'Estimated price';

  @override
  String get estimatedPriceOneYear => 'Estimated price for one year';

  @override
  String get increase => 'Increase';

  @override
  String get decrease => 'Decrease';

  @override
  String get call => 'Call';

  @override
  String get motorIssueTitle => 'Compulsory insurance';

  @override
  String get motorStepVehicle => 'Step 1 of 3 · Vehicle';

  @override
  String get checkDataNotice => 'Please check the vehicle details before issuing; they are printed on the policy.';

  @override
  String get chooseVehicle => 'Choose the vehicle';

  @override
  String get addNewVehicle => 'Add a new vehicle';

  @override
  String get policyData => 'Policy details';

  @override
  String get policyDuration => 'Duration';

  @override
  String get oneYear => 'One year';

  @override
  String get insuredPerson => 'Insured';

  @override
  String insuredUntil(String date) {
    return 'Insured until $date';
  }

  @override
  String get hasPendingPolicy => 'Has a policy awaiting payment';

  @override
  String get notInsured => 'Not insured';

  @override
  String get viewPolicy => 'View policy';

  @override
  String get motorPriceTitle => 'Compulsory insurance price';

  @override
  String get engineCcInvalid => 'Enter a valid engine size (50 - 10000)';

  @override
  String get travelIssueTitle => 'Travel insurance';

  @override
  String get travelStepTrip => 'Step 1 of 3 · Trip and travellers';

  @override
  String get travelPriceTitle => 'Travel insurance price';

  @override
  String get travelUnavailable => 'Travel insurance is not available right now. Please contact customer service.';

  @override
  String get destination => 'Destination';

  @override
  String get tripLength => 'Trip length';

  @override
  String get tripDetails => 'Trip details';

  @override
  String get travelDate => 'Travel date';

  @override
  String coverageEndsOn(String date) {
    return 'Cover ends on $date';
  }

  @override
  String get travellers => 'Travellers';

  @override
  String get travellersNumber => 'Number of travellers';

  @override
  String travellersCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count travellers',
      one: '1 traveller',
      zero: 'No travellers selected',
    );
    return '$_temp0';
  }

  @override
  String daysCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(count, locale: localeName, other: '$count days', one: '1 day');
    return '$_temp0';
  }

  @override
  String fromPrice(String price) {
    return 'from $price';
  }

  @override
  String get pricePerTraveller => 'Price per traveller';

  @override
  String get addTravellersHint => 'Add the travellers first (name, date of birth and passport number).';

  @override
  String get passportMissing => 'No passport number';

  @override
  String passportRequiredFor(String names) {
    return 'Please add a passport number for: $names';
  }

  @override
  String get addPassport => 'Add passport number';

  @override
  String get addPerson => 'Add person';

  @override
  String get editPerson => 'Edit person';

  @override
  String get deletePerson => 'Delete person';

  @override
  String deletePersonConfirm(String name) {
    return 'Delete $name from your people? Policies already issued are not affected.';
  }

  @override
  String get personAdded => 'Person added';

  @override
  String get personUpdated => 'Details updated';

  @override
  String get personDeleted => 'Person deleted';

  @override
  String get relationship => 'Relationship';

  @override
  String get relationshipSelf => 'Me';

  @override
  String get relationshipSpouse => 'Spouse';

  @override
  String get relationshipChild => 'Child';

  @override
  String get relationshipParent => 'Parent';

  @override
  String get relationshipSibling => 'Sibling';

  @override
  String get relationshipOther => 'Other';

  @override
  String get birthDate => 'Date of birth';

  @override
  String bornOn(String date) {
    return 'Born $date';
  }

  @override
  String get passportNo => 'Passport number';

  @override
  String passportShort(String number) {
    return 'Passport $number';
  }

  @override
  String get passportNeededForTravel => 'Required for travel insurance';

  @override
  String get sendRequest => 'Send request';

  @override
  String get requestSent => 'Your request was sent. A company employee will contact you.';

  @override
  String get attach => 'Attach';

  @override
  String get documentsLaterHint => 'You can send the request now and provide the documents later.';

  @override
  String get addVehicleFirst => 'Add your vehicle first in Vehicles.';

  @override
  String requestContactHint(String phone) {
    return 'A company employee will contact you on $phone within one working day.';
  }

  @override
  String get requestDetails => 'Request details';

  @override
  String sentOn(String date) {
    return 'Sent on $date';
  }

  @override
  String get requestWaitingHint => 'Your request is being handled; the company\'s reply will appear here.';

  @override
  String get requestData => 'Request details';

  @override
  String get companyReply => 'Company reply';

  @override
  String get offeredPrice => 'Offered price';

  @override
  String get acceptOfferHint => 'To accept the offer, contact customer service or wait for the employee\'s call.';

  @override
  String get withdrawRequest => 'Withdraw request';

  @override
  String get withdrawRequestConfirm => 'Withdraw this request?';

  @override
  String get requestWithdrawn => 'Request withdrawn';

  @override
  String get noRequests => 'No requests';

  @override
  String get noRequestsHint => 'Requests you send for other products appear here.';

  @override
  String get requestsNotificationHint => 'You\'ll be notified when the company replies.';

  @override
  String get filterAllPolicies => 'All policies';

  @override
  String get filterActive => 'Active';

  @override
  String get filterRequests => 'Requests';

  @override
  String validUntil(String date) {
    return 'Valid until $date';
  }

  @override
  String endedOn(String date) {
    return 'Ended $date';
  }

  @override
  String get awaitingPayment => 'Awaiting payment';

  @override
  String get cancelPolicyRequest => 'Cancel this policy';

  @override
  String get account => 'Account';

  @override
  String get settings => 'Settings';

  @override
  String get personalInfo => 'Personal information';

  @override
  String get documentsMissing => 'Documents incomplete';

  @override
  String get branchesAndAgents => 'Branches and agents';

  @override
  String get headOffice => 'Head office';

  @override
  String get agentsComingSoon => 'New branches and agents appear here once appointed.';

  @override
  String get website => 'Website';

  @override
  String get privacy => 'Privacy';

  @override
  String get aboutCompany => 'About us';

  @override
  String get appVersion => 'Version';

  @override
  String get aboutApp => 'About the app';

  @override
  String get aboutAppBody =>
      'The Alarabia Kobrah Insurance app lets you issue your insurance policy from your phone and pay for it online. Your policies stay with you at all times, each with a verification code that proves it is genuine.';

  @override
  String get aboutAppFeatureIssue => 'Get your policy in minutes without visiting an office';

  @override
  String get aboutAppFeaturePay => 'Pay online with Libyan wallets and banking apps';

  @override
  String get aboutAppFeatureVerify => 'A QR code on every policy for traffic police and official checks';

  @override
  String get aboutAppFeatureSupport => 'Follow your requests and reach customer service from the app';

  @override
  String aboutAppCopyright(int year) {
    return '© $year Alarabia Kobrah Insurance Co.';
  }

  @override
  String get payWith => 'Pay with';

  @override
  String get paymentService => 'the payment service';

  @override
  String walletPhone(String method) {
    return 'Your phone number registered with $method';
  }

  @override
  String get walletPhoneHint => 'You\'ll receive a code on this number';

  @override
  String get sendPaymentCode => 'Send the code';

  @override
  String enterPaymentCode(String phone) {
    return 'Enter the code sent to $phone to complete the payment.';
  }

  @override
  String get confirmPayment => 'Confirm payment';

  @override
  String get changeNumberOrResend => 'Change number or resend the code';

  @override
  String get checkBeforeSending => 'Please check the details before sending them.';

  @override
  String get insuredDetails => 'Insured details';

  @override
  String get vehicleDetails => 'Vehicle details';

  @override
  String get ownerName => 'Owner name';

  @override
  String get ownerNameHint => 'Vehicle owner\'s name';

  @override
  String get ownerAddress => 'Owner address';

  @override
  String get ownerAddressHint => 'Vehicle owner\'s address';

  @override
  String get vehicleColor => 'Colour';

  @override
  String get countryOfOrigin => 'Country of manufacture';

  @override
  String get licensePurpose => 'Licensed for';

  @override
  String get seats => 'Seats';

  @override
  String get metalPlate => 'Plate number';

  @override
  String get licensingAuthority => 'Licensing authority';

  @override
  String get tapToChoose => 'Tap to choose';

  @override
  String get tapToChooseYear => 'Tap to choose the year';

  @override
  String get search => 'Search';

  @override
  String useTypedValue(String value) {
    return 'Use “$value”';
  }

  @override
  String get noResults => 'No results';

  @override
  String numberBetween(int min, int max) {
    return 'Enter a number from $min to $max';
  }

  @override
  String get vehicleDetailsMissing => 'Vehicle details are incomplete';

  @override
  String get vehicleDetailsMissingHint =>
      'Complete the owner and registration details before issuing; they are printed on the policy.';

  @override
  String get completeDetails => 'Complete details';
}
