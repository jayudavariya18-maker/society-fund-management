import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

/// AppLocalizations provides fully typed, zero-dependency localization for:
/// - English ('en')
/// - Gujarati ('gu')
/// - Hindi ('hi')
class AppLocalizations {
  final Locale locale;

  AppLocalizations(this.locale);

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations) ??
        AppLocalizations(const Locale('en'));
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  static const List<Locale> supportedLocales = [
    Locale('en'),
    Locale('gu'),
    Locale('hi'),
  ];

  static final Map<String, Map<String, String>> _localizedValues = {
    'en': {
      'appTitle': 'Bajrang Society',
      'tagline': 'Transparent Society Finance & Festival Management',
      'home': 'Home',
      'funds': 'Funds',
      'festivals': 'Festivals',
      'reports': 'Reports',
      'profile': 'Profile',
      'transactions': 'Transactions',
      'members': 'Members',
      'announcements': 'Announcements',
      'approvals': 'Registration Requests',
      'auditLogs': 'Audit History',
      'totalSocietyBalance': 'Total Society Balance',
      'generalFundBalance': 'General Fund',
      'festivalFundBalance': 'Festival Funds',
      'totalContributions': 'Total Received',
      'totalExpenses': 'Total Spent',
      'activeMembers': 'Active Members',
      'upcomingFestivals': 'Upcoming Festivals',
      'recentTransactions': 'Recent Transactions',
      'recentAnnouncements': 'Latest Announcements',
      'quickActions': 'Quick Actions',
      'viewAll': 'View All',
      'addContribution': 'Add Contribution',
      'addExpense': 'Add Expense',
      'createFestival': 'Create Festival',
      'createEvent': 'Add Event',
      'createAnnouncement': 'New Notice',
      'fundName': 'Fund Name',
      'fundType': 'Fund Type',
      'generalFund': 'General Society Fund',
      'festivalFund': 'Festival Fund',
      'openingBalance': 'Opening Balance',
      'currentBalance': 'Current Balance',
      'availableBalance': 'Available Balance',
      'amount': 'Amount',
      'inr': '₹',
      'member': 'Member / Donor',
      'flatNumber': 'Flat / Unit No.',
      'fullName': 'Full Name',
      'phoneNumber': 'Mobile Number',
      'contributionType': 'Contribution Type',
      'paymentMethod': 'Payment Method',
      'transactionReference': 'Transaction Reference / UTR',
      'paymentDate': 'Payment Date',
      'expenseDate': 'Expense Date',
      'notes': 'Notes / Remarks',
      'receiptNumber': 'Receipt Number',
      'vendorName': 'Vendor / Payee',
      'expenseCategory': 'Expense Category',
      'description': 'Description',
      'attachment': 'Attach Bill / Receipt',
      'status': 'Status',
      'typeMonthlyMaintenance': 'Monthly Maintenance',
      'typeGeneralDonation': 'General Donation',
      'typeFestivalContribution': 'Festival Contribution',
      'typeSpecialContribution': 'Special Contribution',
      'typeOther': 'Other',
      'catElectricity': 'Electricity',
      'catCleaning': 'Cleaning & Sanitation',
      'catSecurity': 'Security Guard',
      'catRepairs': 'Repairs & Maintenance',
      'catDecoration': 'Decoration & Lighting',
      'catFood': 'Food & Mahaprasad',
      'catSoundSystem': 'Sound & Orchestra',
      'catTransportation': 'Transportation',
      'catEventArrangements': 'Event Arrangements',
      'catMaintenance': 'General Maintenance',
      'catPrinting': 'Printing & Stationery',
      'catOther': 'Other',
      'methodCash': 'Cash',
      'methodUpi': 'UPI / QR Code',
      'methodBankTransfer': 'Bank Transfer / NEFT',
      'methodCheque': 'Cheque',
      'methodOther': 'Other',
      'statusPosted': 'Posted',
      'statusReversed': 'Reversed',
      'statusAdjusted': 'Adjusted',
      'statusPending': 'Pending Approval',
      'statusApproved': 'Approved',
      'statusRejected': 'Rejected',
      'loginTitle': 'Society Member Login',
      'loginSubtitle': 'Enter your registered mobile number to receive a secure OTP',
      'sendOtp': 'Send OTP',
      'verifyOtp': 'Verify & Login',
      'enterOtp': 'Enter 6-digit OTP',
      'resendOtp': 'Resend OTP',
      'newMemberPrompt': 'New resident in society?',
      'registerHere': 'Submit Registration Request',
      'registrationTitle': 'Resident Registration',
      'registrationSubtitle': 'Provide your details. An existing society resident will verify your request.',
      'additionalInfo': 'Additional Information (e.g. Ownership, Possession Date)',
      'submitRequest': 'Submit Request',
      'pendingTitle': 'Application Under Review',
      'pendingMessage': 'Your registration request has been submitted to society members for verification. Once any existing active member confirms your residency, your account will be activated.',
      'rejectedTitle': 'Application Rejected',
      'checkStatus': 'Refresh Status',
      'logout': 'Sign Out',
      'language': 'Language',
      'selectLanguage': 'Select Language',
      'english': 'English',
      'gujarati': 'ગુજરાતી',
      'hindi': 'हिन्दी',
      'approve': 'Approve Resident',
      'reject': 'Reject Request',
      'approvalNotes': 'Approval / Rejection Comments',
      'selfApprovalError': 'You cannot approve your own application. Another resident must verify you.',
      'approvalSuccess': 'Resident approved successfully! Member profile activated.',
      'rejectionSuccess': 'Resident request rejected.',
      'receiptTitle': 'Society Official Receipt',
      'downloadReceipt': 'Download PDF Receipt',
      'shareReceipt': 'Share Receipt',
      'printReceipt': 'Print Receipt',
      'exportPdf': 'Export PDF Report',
      'exportCsv': 'Export CSV',
      'financialStatement': 'Financial Statement',
      'dateFrom': 'From Date',
      'dateTo': 'To Date',
      'filter': 'Filter',
      'reset': 'Reset',
      'noRecordsFound': 'No records found matching criteria',
      'recordedBy': 'Recorded By',
      'recordedOn': 'Recorded On',
      'correctionNotice': 'This transaction has an auditable adjustment record.',
      'correctExpense': 'Make Correction / Reversal',
      'correctionReason': 'Reason for Correction',
      'validationRequired': 'This field is required',
      'validationPositiveAmount': 'Amount must be greater than zero',
      'validationValidPhone': 'Please enter a valid 10-digit mobile number',
      'successRecorded': 'Record saved successfully to society ledger',
      'errorOccurred': 'An error occurred while communicating with the database',
    },
    'gu': {
      'appTitle': 'બજરંગ સોસાયટી',
      'tagline': 'પારદર્શક સોસાયટી નાણાં અને ઉત્સવ વ્યવસ્થાપન',
      'home': 'મુખ્ય પૃષ્ઠ',
      'funds': 'ફંડ્સ',
      'festivals': 'ઉત્સવો',
      'reports': 'અહેવાલો',
      'profile': 'પ્રોફાઇલ',
      'transactions': 'લેવડ-દેવડ',
      'members': 'સભ્યો',
      'announcements': 'સૂચનાઓ',
      'approvals': 'નોંધણી વિનંતીઓ',
      'auditLogs': 'ઓડિટ ઇતિહાસ',
      'totalSocietyBalance': 'કુલ સોસાયટી બેલેન્સ',
      'generalFundBalance': 'સામાન્ય ફંડ',
      'festivalFundBalance': 'તહેવાર ફંડ્સ',
      'totalContributions': 'કુલ આવક',
      'totalExpenses': 'કુલ ખર્ચ',
      'activeMembers': 'સક્રિય સભ્યો',
      'upcomingFestivals': 'આગામી તહેવારો',
      'recentTransactions': 'તાજેતરના વ્યવહારો',
      'recentAnnouncements': 'તાજી સૂચનાઓ',
      'quickActions': 'ઝડપી ક્રિયાઓ',
      'viewAll': 'બધું જુઓ',
      'addContribution': 'આવક / ફાળો ઉમેરો',
      'addExpense': 'ખર્ચ ઉમેરો',
      'createFestival': 'નવો તહેવાર ઉમેરો',
      'createEvent': 'કાર્યક્રમ ઉમેરો',
      'createAnnouncement': 'નવી નોટિસ',
      'fundName': 'ફંડનું નામ',
      'fundType': 'ફંડનો પ્રકાર',
      'generalFund': 'સામાન્ય સોસાયટી ફંડ',
      'festivalFund': 'તહેવાર ફંડ',
      'openingBalance': 'શરૂઆતનું બેલેન્સ',
      'currentBalance': 'હાલનું બેલેન્સ',
      'availableBalance': 'ઉપલબ્ધ બેલેન્સ',
      'amount': 'રકમ',
      'inr': '₹',
      'member': 'સભ્ય / દાતા',
      'flatNumber': 'ફ્લેટ નંબર',
      'fullName': 'પૂરું નામ',
      'phoneNumber': 'મોબાઇલ નંબર',
      'contributionType': 'ફાળાનો પ્રકાર',
      'paymentMethod': 'ચુકવણી પદ્ધતિ',
      'transactionReference': 'રેફરન્સ / UTR નંબર',
      'paymentDate': 'ચુકવણી તારીખ',
      'expenseDate': 'ખર્ચ તારીખ',
      'notes': 'નોંધ / વિગત',
      'receiptNumber': 'પહોંચ નંબર',
      'vendorName': 'વેપારી / મેળવનાર',
      'expenseCategory': 'ખર્ચનો પ્રકાર',
      'description': 'વર્ણન',
      'attachment': 'બિલ / પહોંચ જોડો',
      'status': 'સ્થિતિ',
      'typeMonthlyMaintenance': 'માસિક મેન્ટેનન્સ',
      'typeGeneralDonation': 'સામાન્ય દાન',
      'typeFestivalContribution': 'તહેવાર ફાળો',
      'typeSpecialContribution': 'ખાસ ફાળો',
      'typeOther': 'અન્ય',
      'catElectricity': 'વીજળી બિલ',
      'catCleaning': 'સફાઈ અને કચરો',
      'catSecurity': 'સિક્યુરિટી ગાર્ડ',
      'catRepairs': 'સમારકામ અને જાળવણી',
      'catDecoration': 'ડેકોરેશન અને લાઇટિંગ',
      'catFood': 'ભોજન અને મહાપ્રસાદ',
      'catSoundSystem': 'સાઉન્ડ અને ઓર્કેસ્ટ્રા',
      'catTransportation': 'વાહન વ્યવહાર',
      'catEventArrangements': 'કાર્યક્રમ વ્યવસ્થા',
      'catMaintenance': 'સામાન્ય જાળવણી',
      'catPrinting': 'પ્રિન્ટિંગ અને સ્ટેશનરી',
      'catOther': 'અન્ય',
      'methodCash': 'રોકડ (Cash)',
      'methodUpi': 'UPI / QR કોડ',
      'methodBankTransfer': 'બેંક ટ્રાન્સફર / NEFT',
      'methodCheque': 'ચેક',
      'methodOther': 'અન્ય',
      'statusPosted': 'નોંધાયેલ',
      'statusReversed': 'રદ કરેલ',
      'statusAdjusted': 'સુધારેલ',
      'statusPending': 'મંજૂરી બાકી',
      'statusApproved': 'મંજૂર',
      'statusRejected': 'નામંજૂર',
      'loginTitle': 'સોસાયટી સભ્ય પ્રવેશ',
      'loginSubtitle': 'સુરક્ષિત OTP મેળવવા માટે તમારો નોંધાયેલ મોબાઇલ નંબર દાખલ કરો',
      'sendOtp': 'OTP મોકલો',
      'verifyOtp': 'ચકાસો અને પ્રવેશ કરો',
      'enterOtp': '૬-અંકનો OTP દાખલ કરો',
      'resendOtp': 'ફરીથી OTP મોકલો',
      'newMemberPrompt': 'સોસાયટીમાં નવા રહેવાસી છો?',
      'registerHere': 'નોંધણી વિનંતી મોકલો',
      'registrationTitle': 'રહેવાસી નોંધણી',
      'registrationSubtitle': 'તમારી વિગતો ભરો. સોસાયટીના કોઈપણ સક્રિય સભ્ય તેને ચકાસીને મંજૂર કરશે.',
      'additionalInfo': 'વધારાની માહિતી (દા.ત. માલિકી, કબજા તારીખ)',
      'submitRequest': 'વિનંતી સબમિટ કરો',
      'pendingTitle': 'અરજી ચકાસણી હેઠળ છે',
      'pendingMessage': 'તમારી નોંધણી વિનંતી સબમિટ થઈ ગઈ છે. સોસાયટીના કોઈપણ સક્રિય સભ્ય દ્વારા ચકાસણી પછી તમારું ખાતું શરૂ થશે.',
      'rejectedTitle': 'અરજી નામંજૂર થયેલ છે',
      'checkStatus': 'સ્થિતિ તપાસો',
      'logout': 'બહાર નીકળો (Sign Out)',
      'language': 'ભાષા',
      'selectLanguage': 'ભાષા પસંદ કરો',
      'english': 'English',
      'gujarati': 'ગુજરાતી',
      'hindi': 'हिन्दी',
      'approve': 'મંજૂરી આપો',
      'reject': 'નામંજૂર કરો',
      'approvalNotes': 'મંજૂરી / નામંજૂરી નોંધ',
      'selfApprovalError': 'તમે તમારી પોતાની અરજી મંજૂર કરી શકતા નથી. અન્ય રહેવાસીએ ચકાસણી કરવી પડશે.',
      'approvalSuccess': 'રહેવાસી સફળતાપૂર્વક મંજૂર કરવામાં આવ્યા! સભ્ય પ્રોફાઇલ સક્રિય થઈ.',
      'rejectionSuccess': 'રહેવાસી વિનંતી નામંજૂર કરવામાં આવી.',
      'receiptTitle': 'સોસાયટી સત્તાવાર પહોંચ',
      'downloadReceipt': 'પહોંચ PDF ડાઉનલોડ કરો',
      'shareReceipt': 'પહોંચ શેર કરો',
      'printReceipt': 'પહોંચ પ્રિન્ટ કરો',
      'exportPdf': 'PDF અહેવાલ નિકાસ કરો',
      'exportCsv': 'CSV નિકાસ કરો',
      'financialStatement': 'નાણાકીય હિસાબ પત્રક',
      'dateFrom': 'આ તારીખથી',
      'dateTo': 'આ તારીખ સુધી',
      'filter': 'ફિલ્ટર',
      'reset': 'રીસેટ',
      'noRecordsFound': 'કોઈ રેકોર્ડ મળ્યા નથી',
      'recordedBy': 'નોંધનાર',
      'recordedOn': 'નોંધણી તારીખ',
      'correctionNotice': 'આ વ્યવહારમાં સુધારેલ ઓડિટ રેકોર્ડ છે.',
      'correctExpense': 'ભૂલ સુધારો / રદ કરો',
      'correctionReason': 'સુધારાનું કારણ',
      'validationRequired': 'આ વિગત જરૂરી છે',
      'validationPositiveAmount': 'રકમ શૂન્ય કરતાં વધુ હોવી જોઈએ',
      'validationValidPhone': 'કૃપા કરીને માન્ય ૧૦-અંકનો મોબાઇલ નંબર દાખલ કરો',
      'successRecorded': 'વિગત સોસાયટી ખાતાવહીમાં સફળતાપૂર્વક નોંધાઈ ગઈ',
      'errorOccurred': 'ડેટાબેઝ સાથે સંપર્ક કરવામાં ભૂલ આવી',
    },
    'hi': {
      'appTitle': 'बजरंग सोसाइटी',
      'tagline': 'पारदर्शी सोसाइटी वित्त एवं उत्सव प्रबंधन',
      'home': 'होम',
      'funds': 'फंड्स',
      'festivals': 'त्योहार',
      'reports': 'रिपोर्ट्स',
      'profile': 'प्रोफाइल',
      'transactions': 'लेन-देन',
      'members': 'सदस्य',
      'announcements': 'सूचनाएं',
      'approvals': 'पंजीकरण अनुरोध',
      'auditLogs': 'ऑडिट इतिहास',
      'totalSocietyBalance': 'कुल सोसाइटी बैलेंस',
      'generalFundBalance': 'सामान्य फंड',
      'festivalFundBalance': 'त्योहार फंड्स',
      'totalContributions': 'कुल प्राप्त आय',
      'totalExpenses': 'कुल व्यय',
      'activeMembers': 'सक्रिय सदस्य',
      'upcomingFestivals': 'आगामी त्योहार',
      'recentTransactions': 'हाल के लेन-देन',
      'recentAnnouncements': 'नवीनतम सूचनाएं',
      'quickActions': 'त्वरित क्रियाएं',
      'viewAll': 'सभी देखें',
      'addContribution': 'योगदान / शुल्क जोड़ें',
      'addExpense': 'खर्च जोड़ें',
      'createFestival': 'नया त्योहार जोड़ें',
      'createEvent': 'कार्यक्रम जोड़ें',
      'createAnnouncement': 'नई सूचना जारी करें',
      'fundName': 'फंड का नाम',
      'fundType': 'फंड का प्रकार',
      'generalFund': 'सामान्य सोसाइटी फंड',
      'festivalFund': 'त्योहार फंड',
      'openingBalance': 'प्रारंभिक शेष (Opening)',
      'currentBalance': 'वर्तमान शेष (Balance)',
      'availableBalance': 'उपलब्ध शेष',
      'amount': 'राशि',
      'inr': '₹',
      'member': 'सदस्य / दाता',
      'flatNumber': 'फ्लैट / मकान नं.',
      'fullName': 'पूरा नाम',
      'phoneNumber': 'मोबाइल नंबर',
      'contributionType': 'योगदान का प्रकार',
      'paymentMethod': 'भुगतान विधि',
      'transactionReference': 'ट्रांजेक्शन / UTR नंबर',
      'paymentDate': 'भुगतान तिथि',
      'expenseDate': 'व्यय तिथि',
      'notes': 'टिप्पणी / विवरण',
      'receiptNumber': 'रसीद संख्या',
      'vendorName': 'विक्रेता / प्राप्तकर्ता',
      'expenseCategory': 'खर्च श्रेणी',
      'description': 'विवरण',
      'attachment': 'बिल / रसीद संलग्न करें',
      'status': 'स्थिति',
      'typeMonthlyMaintenance': 'मासिक रखरखाव (Maintenance)',
      'typeGeneralDonation': 'सामान्य दान',
      'typeFestivalContribution': 'त्योहार अंशदान',
      'typeSpecialContribution': 'विशेष अंशदान',
      'typeOther': 'अन्य',
      'catElectricity': 'बिजली बिल',
      'catCleaning': 'सफाई एवं स्वच्छता',
      'catSecurity': 'सुरक्षा गार्ड',
      'catRepairs': 'मरम्मत एवं रखरखाव',
      'catDecoration': 'सजावट एवं लाइटिंग',
      'catFood': 'खान-पान एवं महाप्रसाद',
      'catSoundSystem': 'साउंड एवं ऑर्केस्ट्रा',
      'catTransportation': 'परिवहन',
      'catEventArrangements': 'कार्यक्रम व्यवस्था',
      'catMaintenance': 'सामान्य रखरखाव',
      'catPrinting': 'प्रिंटिंग एवं स्टेशनरी',
      'catOther': 'अन्य',
      'methodCash': 'नकद (Cash)',
      'methodUpi': 'UPI / QR कोड',
      'methodBankTransfer': 'बैंक ट्रांसफर / NEFT',
      'methodCheque': 'चेक',
      'methodOther': 'अन्य',
      'statusPosted': 'दर्ज (Posted)',
      'statusReversed': 'रद्द (Reversed)',
      'statusAdjusted': 'संशोधित (Adjusted)',
      'statusPending': 'स्वीकृति प्रतीक्षारत',
      'statusApproved': 'स्वीकृत',
      'statusRejected': 'अस्वीकृत',
      'loginTitle': 'सोसाइटी सदस्य लॉगिन',
      'loginSubtitle': 'सुरक्षित OTP प्राप्त करने के लिए अपना पंजीकृत मोबाइल नंबर दर्ज करें',
      'sendOtp': 'OTP भेजें',
      'verifyOtp': 'सत्यापित करें और लॉगिन करें',
      'enterOtp': '६-अंकों का OTP दर्ज करें',
      'resendOtp': 'पुनः OTP भेजें',
      'newMemberPrompt': 'सोसाइटी में नए निवासी हैं?',
      'registerHere': 'पंजीकरण अनुरोध भेजें',
      'registrationTitle': 'निवासी पंजीकरण',
      'registrationSubtitle': 'अपना विवरण भरें। कोई भी मौजूदा सक्रिय सदस्य आपके विवरण को सत्यापित करेगा।',
      'additionalInfo': 'अतिरिक्त जानकारी (उदा. फ्लैट स्वामित्व, गृह प्रवेश तिथि)',
      'submitRequest': 'अनुरोध सबमिट करें',
      'pendingTitle': 'आवेदन समीक्षाधीन है',
      'pendingMessage': 'आपका पंजीकरण अनुरोध सोसाइटी सदस्यों को समीक्षा हेतु भेज दिया गया है। किसी भी सक्रिय सदस्य द्वारा पुष्टि किए जाने पर आपका खाता सक्रिय हो जाएगा।',
      'rejectedTitle': 'आवेदन अस्वीकृत कर दिया गया है',
      'checkStatus': 'स्थिति जांचें',
      'logout': 'साइन आउट',
      'language': 'भाषा',
      'selectLanguage': 'भाषा चुनें',
      'english': 'English',
      'gujarati': 'ગુજરાતી',
      'hindi': 'हिन्दी',
      'approve': 'स्वीकृत करें',
      'reject': 'अस्वीकृत करें',
      'approvalNotes': 'स्वीकृति / अस्वीकृति टिप्पणी',
      'selfApprovalError': 'आप स्वयं अपना आवेदन स्वीकृत नहीं कर सकते। किसी अन्य निवासी द्वारा सत्यापन आवश्यक है।',
      'approvalSuccess': 'निवासी को सफलतापूर्वक स्वीकृत किया गया! सदस्य प्रोफ़ाइल सक्रिय हुई।',
      'rejectionSuccess': 'निवासी अनुरोध अस्वीकृत कर दिया गया।',
      'receiptTitle': 'सोसाइटी आधिकारिक रसीद',
      'downloadReceipt': 'PDF रसीद डाउनलोड करें',
      'shareReceipt': 'रसीद साझा करें',
      'printReceipt': 'रसीद प्रिंट करें',
      'exportPdf': 'PDF रिपोर्ट निर्यात करें',
      'exportCsv': 'CSV निर्यात करें',
      'financialStatement': 'वित्तीय लेखा-जोखा विवरण',
      'dateFrom': 'इस तिथि से',
      'dateTo': 'इस तिथि तक',
      'filter': 'फ़िल्टर',
      'reset': 'रीसेट',
      'noRecordsFound': 'कोई रिकॉर्ड उपलब्ध नहीं है',
      'recordedBy': 'दर्जकर्ता',
      'recordedOn': 'दर्ज तिथि',
      'correctionNotice': 'इस लेन-देन में एक सत्यापन योग्य संशोधन रिकॉर्ड मौजूद है।',
      'correctExpense': 'संशोधन / रद्दीकरण करें',
      'correctionReason': 'संशोधन का कारण',
      'validationRequired': 'यह जानकारी आवश्यक है',
      'validationPositiveAmount': 'राशि शून्य से अधिक होनी चाहिए',
      'validationValidPhone': 'कृपया मान्य १०-अंकों का मोबाइल नंबर दर्ज करें',
      'successRecorded': 'प्रविष्टि सोसाइटी बहीखाते में सफलतापूर्वक दर्ज कर ली गई है',
      'errorOccurred': 'डेटाबेस के साथ संपर्क में त्रुटि उत्पन्न हुई',
    },
  };

  String _t(String key) {
    final lang = locale.languageCode;
    return _localizedValues[lang]?[key] ??
        _localizedValues['en']?[key] ??
        key;
  }

  // Getters for all keys
  String get appTitle => _t('appTitle');
  String get tagline => _t('tagline');
  String get home => _t('home');
  String get funds => _t('funds');
  String get festivals => _t('festivals');
  String get reports => _t('reports');
  String get profile => _t('profile');
  String get transactions => _t('transactions');
  String get members => _t('members');
  String get announcements => _t('announcements');
  String get approvals => _t('approvals');
  String get auditLogs => _t('auditLogs');

  String get totalSocietyBalance => _t('totalSocietyBalance');
  String get generalFundBalance => _t('generalFundBalance');
  String get festivalFundBalance => _t('festivalFundBalance');
  String get totalContributions => _t('totalContributions');
  String get totalExpenses => _t('totalExpenses');
  String get activeMembers => _t('activeMembers');
  String get upcomingFestivals => _t('upcomingFestivals');
  String get recentTransactions => _t('recentTransactions');
  String get recentAnnouncements => _t('recentAnnouncements');
  String get quickActions => _t('quickActions');
  String get viewAll => _t('viewAll');

  String get addContribution => _t('addContribution');
  String get addExpense => _t('addExpense');
  String get createFestival => _t('createFestival');
  String get createEvent => _t('createEvent');
  String get createAnnouncement => _t('createAnnouncement');

  String get fundName => _t('fundName');
  String get fundType => _t('fundType');
  String get generalFund => _t('generalFund');
  String get festivalFund => _t('festivalFund');
  String get openingBalance => _t('openingBalance');
  String get currentBalance => _t('currentBalance');
  String get availableBalance => _t('availableBalance');

  String get amount => _t('amount');
  String get inr => _t('inr');
  String get member => _t('member');
  String get flatNumber => _t('flatNumber');
  String get fullName => _t('fullName');
  String get phoneNumber => _t('phoneNumber');
  String get contributionType => _t('contributionType');
  String get paymentMethod => _t('paymentMethod');
  String get transactionReference => _t('transactionReference');
  String get paymentDate => _t('paymentDate');
  String get expenseDate => _t('expenseDate');
  String get notes => _t('notes');
  String get receiptNumber => _t('receiptNumber');
  String get vendorName => _t('vendorName');
  String get expenseCategory => _t('expenseCategory');
  String get description => _t('description');
  String get attachment => _t('attachment');
  String get status => _t('status');

  String get typeMonthlyMaintenance => _t('typeMonthlyMaintenance');
  String get typeGeneralDonation => _t('typeGeneralDonation');
  String get typeFestivalContribution => _t('typeFestivalContribution');
  String get typeSpecialContribution => _t('typeSpecialContribution');
  String get typeOther => _t('typeOther');

  String get catElectricity => _t('catElectricity');
  String get catCleaning => _t('catCleaning');
  String get catSecurity => _t('catSecurity');
  String get catRepairs => _t('catRepairs');
  String get catDecoration => _t('catDecoration');
  String get catFood => _t('catFood');
  String get catSoundSystem => _t('catSoundSystem');
  String get catTransportation => _t('catTransportation');
  String get catEventArrangements => _t('catEventArrangements');
  String get catMaintenance => _t('catMaintenance');
  String get catPrinting => _t('catPrinting');
  String get catOther => _t('catOther');

  String get methodCash => _t('methodCash');
  String get methodUpi => _t('methodUpi');
  String get methodBankTransfer => _t('methodBankTransfer');
  String get methodCheque => _t('methodCheque');
  String get methodOther => _t('methodOther');

  String get statusPosted => _t('statusPosted');
  String get statusReversed => _t('statusReversed');
  String get statusAdjusted => _t('statusAdjusted');
  String get statusPending => _t('statusPending');
  String get statusApproved => _t('statusApproved');
  String get statusRejected => _t('statusRejected');

  String get loginTitle => _t('loginTitle');
  String get loginSubtitle => _t('loginSubtitle');
  String get sendOtp => _t('sendOtp');
  String get verifyOtp => _t('verifyOtp');
  String get enterOtp => _t('enterOtp');
  String get resendOtp => _t('resendOtp');
  String get newMemberPrompt => _t('newMemberPrompt');
  String get registerHere => _t('registerHere');
  String get registrationTitle => _t('registrationTitle');
  String get registrationSubtitle => _t('registrationSubtitle');
  String get additionalInfo => _t('additionalInfo');
  String get submitRequest => _t('submitRequest');
  String get pendingTitle => _t('pendingTitle');
  String get pendingMessage => _t('pendingMessage');
  String get rejectedTitle => _t('rejectedTitle');
  String get checkStatus => _t('checkStatus');
  String get logout => _t('logout');
  String get language => _t('language');
  String get selectLanguage => _t('selectLanguage');
  String get english => _t('english');
  String get gujarati => _t('gujarati');
  String get hindi => _t('hindi');

  String get approve => _t('approve');
  String get reject => _t('reject');
  String get approvalNotes => _t('approvalNotes');
  String get selfApprovalError => _t('selfApprovalError');
  String get approvalSuccess => _t('approvalSuccess');
  String get rejectionSuccess => _t('rejectionSuccess');

  String get receiptTitle => _t('receiptTitle');
  String get downloadReceipt => _t('downloadReceipt');
  String get shareReceipt => _t('shareReceipt');
  String get printReceipt => _t('printReceipt');
  String get exportPdf => _t('exportPdf');
  String get exportCsv => _t('exportCsv');
  String get financialStatement => _t('financialStatement');
  String get dateFrom => _t('dateFrom');
  String get dateTo => _t('dateTo');
  String get filter => _t('filter');
  String get reset => _t('reset');
  String get noRecordsFound => _t('noRecordsFound');
  String get recordedBy => _t('recordedBy');
  String get recordedOn => _t('recordedOn');
  String get correctionNotice => _t('correctionNotice');
  String get correctExpense => _t('correctExpense');
  String get correctionReason => _t('correctionReason');

  String get validationRequired => _t('validationRequired');
  String get validationPositiveAmount => _t('validationPositiveAmount');
  String get validationValidPhone => _t('validationValidPhone');
  String get successRecorded => _t('successRecorded');
  String get errorOccurred => _t('errorOccurred');
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return ['en', 'gu', 'hi'].contains(locale.languageCode);
  }

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(AppLocalizations(locale));
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

extension AppLocalizationsX on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this);
}
