import 'package:flutter/material.dart' show BuildContext;
import '../../l10n/gen/app_localizations.dart' show AppLocalizations;

extension Localization on BuildContext {
  AppLocalizations get loc => AppLocalizations.of(this);
}
