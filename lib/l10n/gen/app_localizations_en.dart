import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String allCentresInCity(String city) {
    return 'All Centres in $city';
  }

  @override
  String get allCentresInTheCity => 'All Centres in the City';

  @override
  String get apply => 'Apply';

  @override
  String get cancel => 'Cancel';

  @override
  String get capacity => 'Capacity';

  @override
  String capacitySeats(int count) {
    final intl.NumberFormat countNumberFormat = intl.NumberFormat.compact(
      locale: localeName,
      
    );
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countString Seats',
      one: '1 Seat',
    );
    return '$_temp0';
  }

  @override
  String get centres => 'Centres';

  @override
  String get coworking => 'Coworking';

  @override
  String get date => 'Date';

  @override
  String get dayOffice => 'Day Office';

  @override
  String get done => 'Done';

  @override
  String get endTime => 'End Time';

  @override
  String get eventSpace => 'Event Space';

  @override
  String get locatedNearestCity => 'Located nearest city';

  @override
  String get location => 'Location';

  @override
  String get locationPermissionDenied => 'Location permission denied.';

  @override
  String get locationPermissionPermanentlyDeniedMessage => 'Location permissions are permanently denied, please enable them in settings.';

  @override
  String get locationPermissionRequired => 'Location Permission Required';

  @override
  String get locationServiceDisabled => 'Location services are disabled.';

  @override
  String get meetingRoom => 'Meeting Room';

  @override
  String get multipleCentresSelected => 'Multiple Centres Selected';

  @override
  String get noResultMatches => 'No result matches your result criteria';

  @override
  String get openSettings => 'Open Settings';

  @override
  String get pleaseSelectYourCity => 'Please select your city';

  @override
  String get reset => 'Reset';

  @override
  String get save => 'Save';

  @override
  String get selectCentres => 'Select Centres';

  @override
  String get selectNearestCity => 'Select Nearest City';

  @override
  String get settings => 'Settings';

  @override
  String get startTime => 'Start Time';

  @override
  String get unableToDetermineLocation => 'Unable to determine location';

  @override
  String get videoConference => 'Video Conference';
}
