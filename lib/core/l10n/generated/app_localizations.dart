import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_hi.dart';
import 'app_localizations_mr.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
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

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
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
    Locale('hi'),
    Locale('mr'),
  ];

  /// The title of the application
  ///
  /// In en, this message translates to:
  /// **'WUA Mobile'**
  String get appTitle;

  /// No description provided for @welcome.
  ///
  /// In en, this message translates to:
  /// **'Welcome to Water User Association'**
  String get welcome;

  /// No description provided for @tagline.
  ///
  /// In en, this message translates to:
  /// **'Irrigation Management & Water Distribution'**
  String get tagline;

  /// No description provided for @login.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get login;

  /// No description provided for @welcomeBack.
  ///
  /// In en, this message translates to:
  /// **'Welcome Back'**
  String get welcomeBack;

  /// No description provided for @loginSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Access your irrigation services & water governance portal'**
  String get loginSubtitle;

  /// No description provided for @identifierLabel.
  ///
  /// In en, this message translates to:
  /// **'Mobile Number / Email'**
  String get identifierLabel;

  /// No description provided for @identifierHint.
  ///
  /// In en, this message translates to:
  /// **'Enter 10-digit mobile or email'**
  String get identifierHint;

  /// No description provided for @passwordHint.
  ///
  /// In en, this message translates to:
  /// **'Enter your account password'**
  String get passwordHint;

  /// No description provided for @rememberMe.
  ///
  /// In en, this message translates to:
  /// **'Remember me'**
  String get rememberMe;

  /// No description provided for @dontHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account?'**
  String get dontHaveAccount;

  /// No description provided for @farmerHelpline.
  ///
  /// In en, this message translates to:
  /// **'Kisan Helpline (Toll Free): 1800-180-1551'**
  String get farmerHelpline;

  /// No description provided for @register.
  ///
  /// In en, this message translates to:
  /// **'Register'**
  String get register;

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logout;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @phone.
  ///
  /// In en, this message translates to:
  /// **'Phone Number'**
  String get phone;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @forgotPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot Password?'**
  String get forgotPassword;

  /// No description provided for @submit.
  ///
  /// In en, this message translates to:
  /// **'Submit'**
  String get submit;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @confirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirm;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @refresh.
  ///
  /// In en, this message translates to:
  /// **'Refresh'**
  String get refresh;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @edit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @search.
  ///
  /// In en, this message translates to:
  /// **'Search...'**
  String get search;

  /// No description provided for @tryAgain.
  ///
  /// In en, this message translates to:
  /// **'Try Again'**
  String get tryAgain;

  /// No description provided for @roleFarmer.
  ///
  /// In en, this message translates to:
  /// **'Farmer'**
  String get roleFarmer;

  /// No description provided for @roleOfficial.
  ///
  /// In en, this message translates to:
  /// **'WUA Official'**
  String get roleOfficial;

  /// No description provided for @roleAdmin.
  ///
  /// In en, this message translates to:
  /// **'Department Officer'**
  String get roleAdmin;

  /// No description provided for @home.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// No description provided for @profile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @english.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// No description provided for @marathi.
  ///
  /// In en, this message translates to:
  /// **'Marathi'**
  String get marathi;

  /// No description provided for @hindi.
  ///
  /// In en, this message translates to:
  /// **'Hindi'**
  String get hindi;

  /// No description provided for @bills.
  ///
  /// In en, this message translates to:
  /// **'Bills'**
  String get bills;

  /// No description provided for @viewBills.
  ///
  /// In en, this message translates to:
  /// **'View Bills'**
  String get viewBills;

  /// No description provided for @payNow.
  ///
  /// In en, this message translates to:
  /// **'Pay Now'**
  String get payNow;

  /// No description provided for @billAmount.
  ///
  /// In en, this message translates to:
  /// **'Amount Due'**
  String get billAmount;

  /// No description provided for @dueDate.
  ///
  /// In en, this message translates to:
  /// **'Due Date'**
  String get dueDate;

  /// No description provided for @paid.
  ///
  /// In en, this message translates to:
  /// **'Paid'**
  String get paid;

  /// No description provided for @unpaid.
  ///
  /// In en, this message translates to:
  /// **'Unpaid'**
  String get unpaid;

  /// No description provided for @billHistory.
  ///
  /// In en, this message translates to:
  /// **'Bill History'**
  String get billHistory;

  /// No description provided for @payments.
  ///
  /// In en, this message translates to:
  /// **'Payments'**
  String get payments;

  /// No description provided for @paymentSuccessful.
  ///
  /// In en, this message translates to:
  /// **'Payment Successful'**
  String get paymentSuccessful;

  /// No description provided for @paymentFailed.
  ///
  /// In en, this message translates to:
  /// **'Payment Failed'**
  String get paymentFailed;

  /// No description provided for @transactionId.
  ///
  /// In en, this message translates to:
  /// **'Transaction ID'**
  String get transactionId;

  /// No description provided for @transactionHistory.
  ///
  /// In en, this message translates to:
  /// **'Transaction History'**
  String get transactionHistory;

  /// No description provided for @waterUsage.
  ///
  /// In en, this message translates to:
  /// **'Water Usage'**
  String get waterUsage;

  /// No description provided for @irrigationSchedule.
  ///
  /// In en, this message translates to:
  /// **'Irrigation Schedule'**
  String get irrigationSchedule;

  /// No description provided for @canalStatus.
  ///
  /// In en, this message translates to:
  /// **'Canal Status'**
  String get canalStatus;

  /// No description provided for @waterQuota.
  ///
  /// In en, this message translates to:
  /// **'Water Quota'**
  String get waterQuota;

  /// No description provided for @activeTurns.
  ///
  /// In en, this message translates to:
  /// **'Active Irrigation Turns'**
  String get activeTurns;

  /// No description provided for @notifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifications;

  /// No description provided for @noNotifications.
  ///
  /// In en, this message translates to:
  /// **'No notifications yet'**
  String get noNotifications;

  /// No description provided for @networkError.
  ///
  /// In en, this message translates to:
  /// **'No internet connection. Please check your network.'**
  String get networkError;

  /// No description provided for @serverError.
  ///
  /// In en, this message translates to:
  /// **'Server error. Please try again later.'**
  String get serverError;

  /// No description provided for @timeoutError.
  ///
  /// In en, this message translates to:
  /// **'Request timed out. Please try again.'**
  String get timeoutError;

  /// No description provided for @somethingWentWrong.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong'**
  String get somethingWentWrong;

  /// No description provided for @goodMorning.
  ///
  /// In en, this message translates to:
  /// **'Good Morning'**
  String get goodMorning;

  /// No description provided for @goodAfternoon.
  ///
  /// In en, this message translates to:
  /// **'Good Afternoon'**
  String get goodAfternoon;

  /// No description provided for @goodEvening.
  ///
  /// In en, this message translates to:
  /// **'Good Evening'**
  String get goodEvening;

  /// No description provided for @helloUser.
  ///
  /// In en, this message translates to:
  /// **'Hello User'**
  String get helloUser;

  /// No description provided for @gatNoMulshi.
  ///
  /// In en, this message translates to:
  /// **'Gat No. 142 • Mulshi WUA'**
  String get gatNoMulshi;

  /// No description provided for @nextCanalTurnTitle.
  ///
  /// In en, this message translates to:
  /// **'NEXT CANAL TURN • WARI'**
  String get nextCanalTurnTitle;

  /// No description provided for @inDays.
  ///
  /// In en, this message translates to:
  /// **'In 2 Days'**
  String get inDays;

  /// No description provided for @timeline.
  ///
  /// In en, this message translates to:
  /// **'Timeline'**
  String get timeline;

  /// No description provided for @gateNumber.
  ///
  /// In en, this message translates to:
  /// **'Gate #4'**
  String get gateNumber;

  /// No description provided for @outletFlow.
  ///
  /// In en, this message translates to:
  /// **'Outlet No. 12 • 50 Cusecs Flow'**
  String get outletFlow;

  /// No description provided for @turnDuration.
  ///
  /// In en, this message translates to:
  /// **'08:00 AM – 08:00 PM (12 Hours)'**
  String get turnDuration;

  /// No description provided for @waterBalance.
  ///
  /// In en, this message translates to:
  /// **'WATER BALANCE'**
  String get waterBalance;

  /// No description provided for @totalDues.
  ///
  /// In en, this message translates to:
  /// **'TOTAL DUES'**
  String get totalDues;

  /// No description provided for @waterUsedSummary.
  ///
  /// In en, this message translates to:
  /// **'79% used of 23,500 L'**
  String get waterUsedSummary;

  /// No description provided for @noLateSurcharge.
  ///
  /// In en, this message translates to:
  /// **'No late surcharge yet'**
  String get noLateSurcharge;

  /// No description provided for @currentPaniPattiBill.
  ///
  /// In en, this message translates to:
  /// **'CURRENT PANI PATTI BILL'**
  String get currentPaniPattiBill;

  /// No description provided for @rabiSeason.
  ///
  /// In en, this message translates to:
  /// **'Rabi Season (2024-25)'**
  String get rabiSeason;

  /// No description provided for @kharifSeason.
  ///
  /// In en, this message translates to:
  /// **'Kharif Season (2024-25)'**
  String get kharifSeason;

  /// No description provided for @due25Nov.
  ///
  /// In en, this message translates to:
  /// **'Due 25 Nov'**
  String get due25Nov;

  /// No description provided for @waterPerAcreLand.
  ///
  /// In en, this message translates to:
  /// **'18,500 L water for 4.5 Acres land'**
  String get waterPerAcreLand;

  /// No description provided for @payViaUpi.
  ///
  /// In en, this message translates to:
  /// **'Pay via UPI'**
  String get payViaUpi;

  /// No description provided for @baseWater.
  ///
  /// In en, this message translates to:
  /// **'Base Water'**
  String get baseWater;

  /// No description provided for @govtCessTax.
  ///
  /// In en, this message translates to:
  /// **'Govt Cess & Tax'**
  String get govtCessTax;

  /// No description provided for @wuaMaintenance.
  ///
  /// In en, this message translates to:
  /// **'WUA Maintenance'**
  String get wuaMaintenance;

  /// No description provided for @farmerServices.
  ///
  /// In en, this message translates to:
  /// **'FARMER SERVICES'**
  String get farmerServices;

  /// No description provided for @payBill.
  ///
  /// In en, this message translates to:
  /// **'Pay Bill'**
  String get payBill;

  /// No description provided for @canalWari.
  ///
  /// In en, this message translates to:
  /// **'Canal Wari'**
  String get canalWari;

  /// No description provided for @allBills.
  ///
  /// In en, this message translates to:
  /// **'All Bills'**
  String get allBills;

  /// No description provided for @myFarm.
  ///
  /// In en, this message translates to:
  /// **'My Farm'**
  String get myFarm;

  /// No description provided for @recentActivity.
  ///
  /// In en, this message translates to:
  /// **'RECENT ACTIVITY'**
  String get recentActivity;

  /// No description provided for @viewAll.
  ///
  /// In en, this message translates to:
  /// **'View All'**
  String get viewAll;

  /// No description provided for @paidViaUpi.
  ///
  /// In en, this message translates to:
  /// **'Paid via UPI'**
  String get paidViaUpi;

  /// No description provided for @navDashboard.
  ///
  /// In en, this message translates to:
  /// **'Dashboard'**
  String get navDashboard;

  /// No description provided for @navBills.
  ///
  /// In en, this message translates to:
  /// **'Bills'**
  String get navBills;

  /// No description provided for @navPayments.
  ///
  /// In en, this message translates to:
  /// **'Payments'**
  String get navPayments;

  /// No description provided for @navProfile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get navProfile;

  /// No description provided for @waterQuotaOverview.
  ///
  /// In en, this message translates to:
  /// **'Water Quota & Canal Allocation'**
  String get waterQuotaOverview;

  /// No description provided for @rotationalCanalTurns.
  ///
  /// In en, this message translates to:
  /// **'ROTATIONAL CANAL TURNS • वारी'**
  String get rotationalCanalTurns;

  /// No description provided for @cropConsumption.
  ///
  /// In en, this message translates to:
  /// **'Crop Consumption Breakdown'**
  String get cropConsumption;

  /// No description provided for @upcomingTurn.
  ///
  /// In en, this message translates to:
  /// **'Upcoming Irrigation Turn'**
  String get upcomingTurn;

  /// No description provided for @requestTurnSwap.
  ///
  /// In en, this message translates to:
  /// **'Request Turn Swap'**
  String get requestTurnSwap;

  /// No description provided for @canalHelpline.
  ///
  /// In en, this message translates to:
  /// **'Canal Control & Wari Helpline'**
  String get canalHelpline;

  /// No description provided for @failedToLoadWater.
  ///
  /// In en, this message translates to:
  /// **'Failed to load water usage'**
  String get failedToLoadWater;

  /// No description provided for @noTurnsFound.
  ///
  /// In en, this message translates to:
  /// **'No turns match the selected filter'**
  String get noTurnsFound;

  /// No description provided for @paniPattiBills.
  ///
  /// In en, this message translates to:
  /// **'Pani Patti Bills'**
  String get paniPattiBills;

  /// No description provided for @wuaSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Water Users Association • जल उपभोक्ता संस्था'**
  String get wuaSubtitle;

  /// No description provided for @paymentHistory.
  ///
  /// In en, this message translates to:
  /// **'Payment History'**
  String get paymentHistory;

  /// No description provided for @paymentSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Irrigation Dues & Transactions • भरणा इतिहास'**
  String get paymentSubtitle;

  /// No description provided for @filterAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get filterAll;

  /// No description provided for @filterPending.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get filterPending;

  /// No description provided for @filterOverdue.
  ///
  /// In en, this message translates to:
  /// **'Overdue'**
  String get filterOverdue;

  /// No description provided for @filterPaid.
  ///
  /// In en, this message translates to:
  /// **'Paid'**
  String get filterPaid;

  /// No description provided for @downloadReceipt.
  ///
  /// In en, this message translates to:
  /// **'Download Receipt'**
  String get downloadReceipt;

  /// No description provided for @markAllAsRead.
  ///
  /// In en, this message translates to:
  /// **'Mark all as read'**
  String get markAllAsRead;

  /// No description provided for @unread.
  ///
  /// In en, this message translates to:
  /// **'Unread'**
  String get unread;

  /// No description provided for @appSettings.
  ///
  /// In en, this message translates to:
  /// **'App Settings'**
  String get appSettings;

  /// No description provided for @helpAndSupport.
  ///
  /// In en, this message translates to:
  /// **'Help & Support'**
  String get helpAndSupport;

  /// No description provided for @logoutConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logoutConfirmTitle;

  /// No description provided for @logoutConfirmMessage.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to log out of your WUA account?'**
  String get logoutConfirmMessage;

  /// No description provided for @swipeAgainToExit.
  ///
  /// In en, this message translates to:
  /// **'Swipe back again to exit'**
  String get swipeAgainToExit;
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
      <String>['en', 'hi', 'mr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'hi':
      return AppLocalizationsHi();
    case 'mr':
      return AppLocalizationsMr();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
