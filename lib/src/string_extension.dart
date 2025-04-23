import 'package:easy_localization/easy_localization.dart';

extension TranslationExtension on String {
  String translate() {
    // Use the tr() method from easy_localization
    return this.tr();
  }
}
