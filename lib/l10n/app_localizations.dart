import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AppLocalizations {
  AppLocalizations(this.locale);

  final Locale locale;
  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      AppLocalizationsDelegate();

  Map<String, String>? _localizedStrings;

  Future<bool> load() async {
    String jsonString =
        await rootBundle.loadString('lib/l10n/${locale.languageCode}.json');
    Map<String, dynamic> jsonMap = json.decode(jsonString);

    _localizedStrings = jsonMap.map((key, value) {
      return MapEntry(key, value.toString());
    });

    return true;
  }

  String? translate(String key) {
    return _localizedStrings?[key];
  }

  // Commonly used translations
  String get appTitle => _localizedStrings?['app_title'] ?? 'Pawdiary';
  String get home => _localizedStrings?['home'] ?? 'Ana Sayfa';
  String get pets => _localizedStrings?['pets'] ?? 'Dostlarım';
  String get calendar => _localizedStrings?['calendar'] ?? 'Takvim';
  String get memories => _localizedStrings?['memories'] ?? 'Anılar';
  String get stats => _localizedStrings?['stats'] ?? 'İstatistik';
  String get settings => _localizedStrings?['settings'] ?? 'Ayarlar';
  String get login => _localizedStrings?['login'] ?? 'Giriş Yap';
  String get register => _localizedStrings?['register'] ?? 'Kayıt Ol';
  String get email => _localizedStrings?['email'] ?? 'E-posta';
  String get password => _localizedStrings?['password'] ?? 'Şifre';
  String get forgotPassword =>
      _localizedStrings?['forgot_password'] ?? 'Şifremi Unuttum';
  String get petName => _localizedStrings?['pet_name'] ?? 'İsim';
  String get petType => _localizedStrings?['pet_type'] ?? 'Tür';
  String get petBreed => _localizedStrings?['pet_breed'] ?? 'Cins';
  String get birthDate => _localizedStrings?['birth_date'] ?? 'Doğum Tarihi';
  String get gender => _localizedStrings?['gender'] ?? 'Cinsiyet';
  String get male => _localizedStrings?['male'] ?? 'Erkek';
  String get female => _localizedStrings?['female'] ?? 'Dişi';
  String get save => _localizedStrings?['save'] ?? 'Kaydet';
  String get cancel => _localizedStrings?['cancel'] ?? 'İptal';
  String get delete => _localizedStrings?['delete'] ?? 'Sil';
  String get edit => _localizedStrings?['edit'] ?? 'Düzenle';
  String get addPet => _localizedStrings?['add_pet'] ?? 'Evcil Hayvan Ekle';
  String get addNote => _localizedStrings?['add_note'] ?? 'Not Ekle';
  String get description => _localizedStrings?['description'] ?? 'Açıklama';
  String get photo => _localizedStrings?['photo'] ?? 'Fotoğraf';
  String get date => _localizedStrings?['date'] ?? 'Tarih';
  String get vaccination => _localizedStrings?['vaccination'] ?? 'Aşı';
  String get veterinarian => _localizedStrings?['veterinarian'] ?? 'Veteriner';
  String get appointment => _localizedStrings?['appointment'] ?? 'Randevu';
  String get reminder => _localizedStrings?['reminder'] ?? 'Hatırlatıcı';
  String get notifications =>
      _localizedStrings?['notifications'] ?? 'Bildirimler';
  String get theme => _localizedStrings?['theme'] ?? 'Tema';
  String get language => _localizedStrings?['language'] ?? 'Dil';
  String get logout => _localizedStrings?['logout'] ?? 'Çıkış Yap';
  String get welcome => _localizedStrings?['welcome'] ?? 'Hoş geldiniz!';
  String get noPets =>
      _localizedStrings?['no_pets'] ?? 'Henüz evcil dostunuz yok!';
  String get noNotes => _localizedStrings?['no_notes'] ?? 'Henüz anınız yok!';
}

class AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return ['en', 'tr'].contains(locale.languageCode);
  }

  @override
  Future<AppLocalizations> load(Locale locale) async {
    AppLocalizations localizations = AppLocalizations(locale);
    await localizations.load();
    return localizations;
  }

  @override
  bool shouldReload(AppLocalizationsDelegate old) => false;
}
