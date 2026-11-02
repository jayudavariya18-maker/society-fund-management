import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_gu.dart';
import 'app_localizations_hi.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('gu'),
    Locale('hi')
  ];

  /// Application Title
  ///
  /// In en, this message translates to:
  /// **'Bajrang Society'**
  String get appTitle;

  /// No description provided for @tagline.
  ///
  /// In en, this message translates to:
  /// **'Transparent Society Finance & Festival Management'**
  String get tagline;

  /// No description provided for @home.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// No description provided for @funds.
  ///
  /// In en, this message translates to:
  /// **'Funds'**
  String get funds;

  /// No description provided for @festivals.
  ///
  /// In en, this message translates to:
  /// **'Festivals'**
  String get festivals;

  /// No description provided for @reports.
  ///
  /// In en, this message translates to:
  /// **'Reports'**
  String get reports;

  /// No description provided for @profile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// No description provided for @transactions.
  ///
  /// In en, this message translates to:
  /// **'Transactions'**
  String get transactions;

  /// No description provided for @members.
  ///
  /// In en, this message translates to:
  /// **'Members'**
  String get members;

  /// No description provided for @announcements.
  ///
  /// In en, this message translates to:
  /// **'Announcements'**
  String get announcements;

  /// No description provided for @approvals.
  ///
  /// In en, this message translates to:
  /// **'Registration Requests'**
  String get approvals;

  /// No description provided for @auditLogs.
  ///
  /// In en, this message translates to:
  /// **'Audit History'**
  String get auditLogs;

  /// No description provided for @totalSocietyBalance.
  ///
  /// In en, this message translates to:
  /// **'Total Society Balance'**
  String get totalSocietyBalance;

  /// No description provided for @generalFundBalance.
  ///
  /// In en, this message translates to:
  /// **'General Fund'**
  String get generalFundBalance;

  /// No description provided for @festivalFundBalance.
  ///
  /// In en, this message translates to:
  /// **'Festival Funds'**
  String get festivalFundBalance;

  /// No description provided for @totalContributions.
  ///
  /// In en, this message translates to:
  /// **'Total Received'**
  String get totalContributions;

  /// No description provided for @totalExpenses.
  ///
  /// In en, this message translates to:
  /// **'Total Spent'**
  String get totalExpenses;

  /// No description provided for @activeMembers.
  ///
  /// In en, this message translates to:
  /// **'Active Members'**
  String get activeMembers;

  /// No description provided for @upcomingFestivals.
  ///
  /// In en, this message translates to:
  /// **'Upcoming Festivals'**
  String get upcomingFestivals;

  /// No description provided for @recentTransactions.
  ///
  /// In en, this message translates to:
  /// **'Recent Transactions'**
  String get recentTransactions;

  /// No description provided for @recentAnnouncements.
  ///
  /// In en, this message translates to:
  /// **'Latest Announcements'**
  String get recentAnnouncements;

  /// No description provided for @quickActions.
  ///
  /// In en, this message translates to:
  /// **'Quick Actions'**
  String get quickActions;

  /// No description provided for @viewAll.
  ///
  /// In en, this message translates to:
  /// **'View All'**
  String get viewAll;

  /// No description provided for @addContribution.
  ///
  /// In en, this message translates to:
  /// **'Add Contribution'**
  String get addContribution;

  /// No description provided for @addExpense.
  ///
  /// In en, this message translates to:
  /// **'Add Expense'**
  String get addExpense;

  /// No description provided for @createFestival.
  ///
  /// In en, this message translates to:
  /// **'Create Festival'**
  String get createFestival;

  /// No description provided for @createEvent.
  ///
  /// In en, this message translates to:
  /// **'Add Event'**
  String get createEvent;

  /// No description provided for @createAnnouncement.
  ///
  /// In en, this message translates to:
  /// **'New Notice'**
  String get createAnnouncement;

  /// No description provided for @fundName.
  ///
  /// In en, this message translates to:
  /// **'Fund Name'**
  String get fundName;

  /// No description provided for @fundType.
  ///
  /// In en, this message translates to:
  /// **'Fund Type'**
  String get fundType;

  /// No description provided for @generalFund.
  ///
  /// In en, this message translates to:
  /// **'General Society Fund'**
  String get generalFund;

  /// No description provided for @festivalFund.
  ///
  /// In en, this message translates to:
  /// **'Festival Fund'**
  String get festivalFund;

  /// No description provided for @openingBalance.
  ///
  /// In en, this message translates to:
  /// **'Opening Balance'**
  String get openingBalance;

  /// No description provided for @currentBalance.
  ///
  /// In en, this message translates to:
  /// **'Current Balance'**
  String get currentBalance;

  /// No description provided for @availableBalance.
  ///
  /// In en, this message translates to:
  /// **'Available Balance'**
  String get availableBalance;

  /// No description provided for @amount.
  ///
  /// In en, this message translates to:
  /// **'Amount'**
  String get amount;

  /// No description provided for @inr.
  ///
  /// In en, this message translates to:
  /// **'₹'**
  String get inr;

  /// No description provided for @member.
  ///
  /// In en, this message translates to:
  /// **'Member / Donor'**
  String get member;

  /// No description provided for @flatNumber.
  ///
  /// In en, this message translates to:
  /// **'Flat / Unit No.'**
  String get flatNumber;

  /// No description provided for @fullName.
  ///
  /// In en, this message translates to:
  /// **'Full Name'**
  String get fullName;

  /// No description provided for @phoneNumber.
  ///
  /// In en, this message translates to:
  /// **'Mobile Number'**
  String get phoneNumber;

  /// No description provided for @contributionType.
  ///
  /// In en, this message translates to:
  /// **'Contribution Type'**
  String get contributionType;

  /// No description provided for @paymentMethod.
  ///
  /// In en, this message translates to:
  /// **'Payment Method'**
  String get paymentMethod;

  /// No description provided for @transactionReference.
  ///
  /// In en, this message translates to:
  /// **'Transaction Reference / UTR'**
  String get transactionReference;

  /// No description provided for @paymentDate.
  ///
  /// In en, this message translates to:
  /// **'Payment Date'**
  String get paymentDate;

  /// No description provided for @expenseDate.
  ///
  /// In en, this message translates to:
  /// **'Expense Date'**
  String get expenseDate;

  /// No description provided for @notes.
  ///
  /// In en, this message translates to:
  /// **'Notes / Remarks'**
  String get notes;

  /// No description provided for @receiptNumber.
  ///
  /// In en, this message translates to:
  /// **'Receipt Number'**
  String get receiptNumber;

  /// No description provided for @vendorName.
  ///
  /// In en, this message translates to:
  /// **'Vendor / Payee'**
  String get vendorName;

  /// No description provided for @expenseCategory.
  ///
  /// In en, this message translates to:
  /// **'Expense Category'**
  String get expenseCategory;

  /// No description provided for @description.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get description;

  /// No description provided for @attachment.
  ///
  /// In en, this message translates to:
  /// **'Attach Bill / Receipt'**
  String get attachment;

  /// No description provided for @status.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get status;

  /// No description provided for @typeMonthlyMaintenance.
  ///
  /// In en, this message translates to:
  /// **'Monthly Maintenance'**
  String get typeMonthlyMaintenance;

  /// No description provided for @typeGeneralDonation.
  ///
  /// In en, this message translates to:
  /// **'General Donation'**
  String get typeGeneralDonation;

  /// No description provided for @typeFestivalContribution.
  ///
  /// In en, this message translates to:
  /// **'Festival Contribution'**
  String get typeFestivalContribution;

  /// No description provided for @typeSpecialContribution.
  ///
  /// In en, this message translates to:
  /// **'Special Contribution'**
  String get typeSpecialContribution;

  /// No description provided for @typeOther.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get typeOther;

  /// No description provided for @catElectricity.
  ///
  /// In en, this message translates to:
  /// **'Electricity'**
  String get catElectricity;

  /// No description provided for @catCleaning.
  ///
  /// In en, this message translates to:
  /// **'Cleaning & Sanitation'**
  String get catCleaning;

  /// No description provided for @catSecurity.
  ///
  /// In en, this message translates to:
  /// **'Security Guard'**
  String get catSecurity;

  /// No description provided for @catRepairs.
  ///
  /// In en, this message translates to:
  /// **'Repairs & Maintenance'**
  String get catRepairs;

  /// No description provided for @catDecoration.
  ///
  /// In en, this message translates to:
  /// **'Decoration & Lighting'**
  String get catDecoration;

  /// No description provided for @catFood.
  ///
  /// In en, this message translates to:
  /// **'Food & Mahaprasad'**
  String get catFood;

  /// No description provided for @catSoundSystem.
  ///
  /// In en, this message translates to:
  /// **'Sound & Orchestra'**
  String get catSoundSystem;

  /// No description provided for @catTransportation.
  ///
  /// In en, this message translates to:
  /// **'Transportation'**
  String get catTransportation;

  /// No description provided for @catEventArrangements.
  ///
  /// In en, this message translates to:
  /// **'Event Arrangements'**
  String get catEventArrangements;

  /// No description provided for @catMaintenance.
  ///
  /// In en, this message translates to:
  /// **'General Maintenance'**
  String get catMaintenance;

  /// No description provided for @catPrinting.
  ///
  /// In en, this message translates to:
  /// **'Printing & Stationery'**
  String get catPrinting;

  /// No description provided for @catOther.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get catOther;

  /// No description provided for @methodCash.
  ///
  /// In en, this message translates to:
  /// **'Cash'**
  String get methodCash;

  /// No description provided for @methodUpi.
  ///
  /// In en, this message translates to:
  /// **'UPI / QR Code'**
  String get methodUpi;

  /// No description provided for @methodBankTransfer.
  ///
  /// In en, this message translates to:
  /// **'Bank Transfer / NEFT'**
  String get methodBankTransfer;

  /// No description provided for @methodCheque.
  ///
  /// In en, this message translates to:
  /// **'Cheque'**
  String get methodCheque;

  /// No description provided for @methodOther.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get methodOther;

  /// No description provided for @statusPosted.
  ///
  /// In en, this message translates to:
  /// **'Posted'**
  String get statusPosted;

  /// No description provided for @statusReversed.
  ///
  /// In en, this message translates to:
  /// **'Reversed'**
  String get statusReversed;

  /// No description provided for @statusAdjusted.
  ///
  /// In en, this message translates to:
  /// **'Adjusted'**
  String get statusAdjusted;

  /// No description provided for @statusPending.
  ///
  /// In en, this message translates to:
  /// **'Pending Approval'**
  String get statusPending;

  /// No description provided for @statusApproved.
  ///
  /// In en, this message translates to:
  /// **'Approved'**
  String get statusApproved;

  /// No description provided for @statusRejected.
  ///
  /// In en, this message translates to:
  /// **'Rejected'**
  String get statusRejected;

  /// No description provided for @loginTitle.
  ///
  /// In en, this message translates to:
  /// **'Society Member Login'**
  String get loginTitle;

  /// No description provided for @loginSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Enter your registered mobile number to receive a secure OTP'**
  String get loginSubtitle;

  /// No description provided for @sendOtp.
  ///
  /// In en, this message translates to:
  /// **'Send OTP'**
  String get sendOtp;

  /// No description provided for @verifyOtp.
  ///
  /// In en, this message translates to:
  /// **'Verify & Login'**
  String get verifyOtp;

  /// No description provided for @enterOtp.
  ///
  /// In en, this message translates to:
  /// **'Enter 6-digit OTP'**
  String get enterOtp;

  /// No description provided for @resendOtp.
  ///
  /// In en, this message translates to:
  /// **'Resend OTP'**
  String get resendOtp;

  /// No description provided for @newMemberPrompt.
  ///
  /// In en, this message translates to:
  /// **'New resident in society?'**
  String get newMemberPrompt;

  /// No description provided for @registerHere.
  ///
  /// In en, this message translates to:
  /// **'Submit Registration Request'**
  String get registerHere;

  /// No description provided for @registrationTitle.
  ///
  /// In en, this message translates to:
  /// **'Resident Registration'**
  String get registrationTitle;

  /// No description provided for @registrationSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Provide your details. An existing society resident will verify your request.'**
  String get registrationSubtitle;

  /// No description provided for @additionalInfo.
  ///
  /// In en, this message translates to:
  /// **'Additional Information (e.g. Ownership, Possession Date)'**
  String get additionalInfo;

  /// No description provided for @submitRequest.
  ///
  /// In en, this message translates to:
  /// **'Submit Request'**
  String get submitRequest;

  /// No description provided for @pendingTitle.
  ///
  /// In en, this message translates to:
  /// **'Application Under Review'**
  String get pendingTitle;

  /// No description provided for @pendingMessage.
  ///
  /// In en, this message translates to:
  /// **'Your registration request has been submitted to society members for verification. Once any existing active member confirms your residency, your account will be activated.'**
  String get pendingMessage;

  /// No description provided for @rejectedTitle.
  ///
  /// In en, this message translates to:
  /// **'Application Rejected'**
  String get rejectedTitle;

  /// No description provided for @checkStatus.
  ///
  /// In en, this message translates to:
  /// **'Refresh Status'**
  String get checkStatus;

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'Sign Out'**
  String get logout;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @selectLanguage.
  ///
  /// In en, this message translates to:
  /// **'Select Language'**
  String get selectLanguage;

  /// No description provided for @english.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// No description provided for @gujarati.
  ///
  /// In en, this message translates to:
  /// **'ગુજરાતી'**
  String get gujarati;

  /// No description provided for @hindi.
  ///
  /// In en, this message translates to:
  /// **'हिन्दी'**
  String get hindi;

  /// No description provided for @approve.
  ///
  /// In en, this message translates to:
  /// **'Approve Resident'**
  String get approve;

  /// No description provided for @reject.
  ///
  /// In en, this message translates to:
  /// **'Reject Request'**
  String get reject;

  /// No description provided for @approvalNotes.
  ///
  /// In en, this message translates to:
  /// **'Approval / Rejection Comments'**
  String get approvalNotes;

  /// No description provided for @selfApprovalError.
  ///
  /// In en, this message translates to:
  /// **'You cannot approve your own application. Another resident must verify you.'**
  String get selfApprovalError;

  /// No description provided for @approvalSuccess.
  ///
  /// In en, this message translates to:
  /// **'Resident approved successfully! Member profile activated.'**
  String get approvalSuccess;

  /// No description provided for @rejectionSuccess.
  ///
  /// In en, this message translates to:
  /// **'Resident request rejected.'**
  String get rejectionSuccess;

  /// No description provided for @receiptTitle.
  ///
  /// In en, this message translates to:
  /// **'Society Official Receipt'**
  String get receiptTitle;

  /// No description provided for @downloadReceipt.
  ///
  /// In en, this message translates to:
  /// **'Download PDF Receipt'**
  String get downloadReceipt;

  /// No description provided for @shareReceipt.
  ///
  /// In en, this message translates to:
  /// **'Share Receipt'**
  String get shareReceipt;

  /// No description provided for @printReceipt.
  ///
  /// In en, this message translates to:
  /// **'Print Receipt'**
  String get printReceipt;

  /// No description provided for @exportPdf.
  ///
  /// In en, this message translates to:
  /// **'Export PDF Report'**
  String get exportPdf;

  /// No description provided for @exportCsv.
  ///
  /// In en, this message translates to:
  /// **'Export CSV'**
  String get exportCsv;

  /// No description provided for @financialStatement.
  ///
  /// In en, this message translates to:
  /// **'Financial Statement'**
  String get financialStatement;

  /// No description provided for @dateFrom.
  ///
  /// In en, this message translates to:
  /// **'From Date'**
  String get dateFrom;

  /// No description provided for @dateTo.
  ///
  /// In en, this message translates to:
  /// **'To Date'**
  String get dateTo;

  /// No description provided for @filter.
  ///
  /// In en, this message translates to:
  /// **'Filter'**
  String get filter;

  /// No description provided for @reset.
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get reset;

  /// No description provided for @noRecordsFound.
  ///
  /// In en, this message translates to:
  /// **'No records found matching criteria'**
  String get noRecordsFound;

  /// No description provided for @recordedBy.
  ///
  /// In en, this message translates to:
  /// **'Recorded By'**
  String get recordedBy;

  /// No description provided for @recordedOn.
  ///
  /// In en, this message translates to:
  /// **'Recorded On'**
  String get recordedOn;

  /// No description provided for @correctionNotice.
  ///
  /// In en, this message translates to:
  /// **'This transaction has an auditable adjustment record.'**
  String get correctionNotice;

  /// No description provided for @correctExpense.
  ///
  /// In en, this message translates to:
  /// **'Make Correction / Reversal'**
  String get correctExpense;

  /// No description provided for @correctionReason.
  ///
  /// In en, this message translates to:
  /// **'Reason for Correction'**
  String get correctionReason;

  /// No description provided for @validationRequired.
  ///
  /// In en, this message translates to:
  /// **'This field is required'**
  String get validationRequired;

  /// No description provided for @validationPositiveAmount.
  ///
  /// In en, this message translates to:
  /// **'Amount must be greater than zero'**
  String get validationPositiveAmount;

  /// No description provided for @validationValidPhone.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid 10-digit mobile number'**
  String get validationValidPhone;

  /// No description provided for @successRecorded.
  ///
  /// In en, this message translates to:
  /// **'Record saved successfully to society ledger'**
  String get successRecorded;

  /// No description provided for @errorOccurred.
  ///
  /// In en, this message translates to:
  /// **'An error occurred while communicating with the database'**
  String get errorOccurred;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'gu', 'hi'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'gu':
      return AppLocalizationsGu();
    case 'hi':
      return AppLocalizationsHi();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
