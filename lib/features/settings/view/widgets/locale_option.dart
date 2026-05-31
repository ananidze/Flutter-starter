import 'package:flutter/material.dart';

class LocaleOption extends StatelessWidget {
  const LocaleOption({required this.locale, required this.label, super.key});

  final Locale? locale;
  final String label;

  @override
  Widget build(BuildContext context) {
    return RadioListTile<Locale?>(value: locale, title: Text(label));
  }
}

String localeLabel(Locale locale) => switch (locale.languageCode) {
  'en' => 'English',
  'es' => 'Español',
  _ => locale.toLanguageTag(),
};
