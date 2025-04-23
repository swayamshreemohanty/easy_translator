import 'package:easy_localization/easy_localization.dart';

extension TranslationExtension on String {
  String translate() {
    return StringTranslateExtension(
      this,
    ).tr(); // Explicitly specify the extension
  }
}
