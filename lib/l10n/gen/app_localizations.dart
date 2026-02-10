import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'gen/app_localizations.dart';
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
  AppLocalizations(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

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
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en')
  ];

  /// 顯示特定城市的中心列表
  ///
  /// In en, this message translates to:
  /// **'All Centres in {city}'**
  String allCentresInCity(String city);

  /// No description provided for @allCentresInTheCity.
  ///
  /// In en, this message translates to:
  /// **'All Centres in the City'**
  String get allCentresInTheCity;

  /// No description provided for @apply.
  ///
  /// In en, this message translates to:
  /// **'Apply'**
  String get apply;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @capacity.
  ///
  /// In en, this message translates to:
  /// **'Capacity'**
  String get capacity;

  /// 顯示座位數，自動處理複數 (e.g. 1 Seat, 2 Seats)
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 Seat} other{{count} Seats}}'**
  String capacitySeats(int count);

  /// No description provided for @centres.
  ///
  /// In en, this message translates to:
  /// **'Centres'**
  String get centres;

  /// No description provided for @coworking.
  ///
  /// In en, this message translates to:
  /// **'Coworking'**
  String get coworking;

  /// No description provided for @date.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get date;

  /// No description provided for @dayOffice.
  ///
  /// In en, this message translates to:
  /// **'Day Office'**
  String get dayOffice;

  /// No description provided for @done.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get done;

  /// No description provided for @endTime.
  ///
  /// In en, this message translates to:
  /// **'End Time'**
  String get endTime;

  /// No description provided for @eventSpace.
  ///
  /// In en, this message translates to:
  /// **'Event Space'**
  String get eventSpace;

  /// No description provided for @locatedNearestCity.
  ///
  /// In en, this message translates to:
  /// **'Located nearest city'**
  String get locatedNearestCity;

  /// No description provided for @location.
  ///
  /// In en, this message translates to:
  /// **'Location'**
  String get location;

  /// No description provided for @locationPermissionDenied.
  ///
  /// In en, this message translates to:
  /// **'Location permission denied.'**
  String get locationPermissionDenied;

  /// No description provided for @locationPermissionPermanentlyDeniedMessage.
  ///
  /// In en, this message translates to:
  /// **'Location permissions are permanently denied, please enable them in settings.'**
  String get locationPermissionPermanentlyDeniedMessage;

  /// No description provided for @locationPermissionRequired.
  ///
  /// In en, this message translates to:
  /// **'Location Permission Required'**
  String get locationPermissionRequired;

  /// No description provided for @locationServiceDisabled.
  ///
  /// In en, this message translates to:
  /// **'Location services are disabled.'**
  String get locationServiceDisabled;

  /// No description provided for @meetingRoom.
  ///
  /// In en, this message translates to:
  /// **'Meeting Room'**
  String get meetingRoom;

  /// No description provided for @multipleCentresSelected.
  ///
  /// In en, this message translates to:
  /// **'Multiple Centres Selected'**
  String get multipleCentresSelected;

  /// No description provided for @noResultMatches.
  ///
  /// In en, this message translates to:
  /// **'No result matches your result criteria'**
  String get noResultMatches;

  /// No description provided for @openSettings.
  ///
  /// In en, this message translates to:
  /// **'Open Settings'**
  String get openSettings;

  /// No description provided for @pleaseSelectYourCity.
  ///
  /// In en, this message translates to:
  /// **'Please select your city'**
  String get pleaseSelectYourCity;

  /// No description provided for @reset.
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get reset;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @selectCentres.
  ///
  /// In en, this message translates to:
  /// **'Select Centres'**
  String get selectCentres;

  /// No description provided for @selectNearestCity.
  ///
  /// In en, this message translates to:
  /// **'Select Nearest City'**
  String get selectNearestCity;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @startTime.
  ///
  /// In en, this message translates to:
  /// **'Start Time'**
  String get startTime;

  /// No description provided for @unableToDetermineLocation.
  ///
  /// In en, this message translates to:
  /// **'Unable to determine location'**
  String get unableToDetermineLocation;

  /// No description provided for @videoConference.
  ///
  /// In en, this message translates to:
  /// **'Video Conference'**
  String get videoConference;
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {


  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en': return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.'
  );
}
