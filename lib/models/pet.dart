import 'package:cloud_firestore/cloud_firestore.dart';

class Pet {
  final String id;
  final String name;
  final String type;
  final String breed;
  final DateTime birthDate;
  final String gender;
  final String? photoUrl;
  final String? photoBase64;
  final String userId;

  Pet({
    required this.id,
    required this.name,
    required this.type,
    required this.breed,
    required this.birthDate,
    required this.gender,
    required this.userId,
    this.photoUrl,
    this.photoBase64,
  });

  factory Pet.fromMap(Map<String, dynamic> map, String id) {
    return Pet(
      id: id,
      name: map['name'] ?? '',
      type: map['type'] ?? '',
      breed: map['breed'] ?? '',
      birthDate: (map['birthDate'] as Timestamp).toDate(),
      gender: map['gender'] ?? '',
      userId: map['userId'] ?? '',
      photoUrl: map['photoUrl'],
      photoBase64: map['photoBase64'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'type': type,
      'breed': breed,
      'birthDate': birthDate,
      'gender': gender,
      'userId': userId,
      'photoUrl': photoUrl,
      'photoBase64': photoBase64,
    };
  }

  // Gelişmiş yaş hesaplama
  String get age {
    final now = DateTime.now();
    final age = _calculateAge(birthDate, now);

    if (age.years > 0) {
      if (age.months > 0) {
        return '${age.years} yıl ${age.months} ay';
      } else {
        return '${age.years} yıl';
      }
    } else if (age.months > 0) {
      if (age.days > 0 && age.months < 2) {
        return '${age.months} ay ${age.days} gün';
      } else {
        return '${age.months} ay';
      }
    } else {
      return '${age.days} gün';
    }
  }

  // Yaş hesaplama (sadece yıl)
  int get ageInYears {
    final now = DateTime.now();
    return _calculateAge(birthDate, now).years;
  }

  // Yaş hesaplama (sadece ay)
  int get ageInMonths {
    final now = DateTime.now();
    final age = _calculateAge(birthDate, now);
    return (age.years * 12) + age.months;
  }

  // Yaş hesaplama (sadece gün)
  int get ageInDays {
    final now = DateTime.now();
    return now.difference(birthDate).inDays;
  }

  // Hayvan kategorisi (yaşa göre)
  String get ageCategory {
    final ageInMonths = this.ageInMonths;

    if (type.toLowerCase().contains('köpek') ||
        type.toLowerCase().contains('dog')) {
      if (ageInMonths < 12) return 'Yavru';
      if (ageInMonths < 84) return 'Yetişkin'; // 7 yaş
      return 'Yaşlı';
    } else if (type.toLowerCase().contains('kedi') ||
        type.toLowerCase().contains('cat')) {
      if (ageInMonths < 12) return 'Yavru';
      if (ageInMonths < 96) return 'Yetişkin'; // 8 yaş
      return 'Yaşlı';
    } else {
      // Genel kategoriler
      if (ageInMonths < 12) return 'Yavru';
      if (ageInMonths < 72) return 'Yetişkin'; // 6 yaş
      return 'Yaşlı';
    }
  }

  // İnsan yılı eşdeğeri (yaklaşık)
  String get humanAgeEquivalent {
    final ageInMonths = this.ageInMonths;

    if (type.toLowerCase().contains('köpek') ||
        type.toLowerCase().contains('dog')) {
      // Köpek yaşı hesaplama formülü
      if (ageInMonths < 24) {
        return '${(ageInMonths * 15 / 12).round()} insan yılı';
      } else {
        final humanAge = 24 + ((ageInMonths - 24) * 4 / 12);
        return '${humanAge.round()} insan yılı';
      }
    } else if (type.toLowerCase().contains('kedi') ||
        type.toLowerCase().contains('cat')) {
      // Kedi yaşı hesaplama formülü
      if (ageInMonths < 24) {
        return '${(ageInMonths * 12 / 12).round()} insan yılı';
      } else {
        final humanAge = 24 + ((ageInMonths - 24) * 4 / 12);
        return '${humanAge.round()} insan yılı';
      }
    } else {
      // Genel hesaplama
      return '${(ageInMonths * 6 / 12).round()} insan yılı';
    }
  }

  // Doğum günü kontrolü
  bool get isBirthdayToday {
    final now = DateTime.now();
    return birthDate.month == now.month && birthDate.day == now.day;
  }

  // Sonraki doğum günü
  DateTime get nextBirthday {
    final now = DateTime.now();
    DateTime nextBirthday = DateTime(now.year, birthDate.month, birthDate.day);

    if (nextBirthday.isBefore(now) || nextBirthday.isAtSameMomentAs(now)) {
      nextBirthday = DateTime(now.year + 1, birthDate.month, birthDate.day);
    }

    return nextBirthday;
  }

  // Sonraki doğum gününe kalan gün
  int get daysUntilBirthday {
    final now = DateTime.now();
    return nextBirthday.difference(now).inDays;
  }

  // Özel yaş hesaplama metodu
  _AgeCalculation _calculateAge(DateTime birth, DateTime now) {
    int years = now.year - birth.year;
    int months = now.month - birth.month;
    int days = now.day - birth.day;

    if (days < 0) {
      months--;
      days += _daysInMonth(now.month - 1 == 0 ? 12 : now.month - 1,
          now.month - 1 == 0 ? now.year - 1 : now.year);
    }

    if (months < 0) {
      years--;
      months += 12;
    }

    return _AgeCalculation(years: years, months: months, days: days);
  }

  int _daysInMonth(int month, int year) {
    switch (month) {
      case 1:
      case 3:
      case 5:
      case 7:
      case 8:
      case 10:
      case 12:
        return 31;
      case 4:
      case 6:
      case 9:
      case 11:
        return 30;
      case 2:
        return _isLeapYear(year) ? 29 : 28;
      default:
        return 30;
    }
  }

  bool _isLeapYear(int year) {
    return (year % 4 == 0 && year % 100 != 0) || (year % 400 == 0);
  }
}

class _AgeCalculation {
  final int years;
  final int months;
  final int days;

  _AgeCalculation(
      {required this.years, required this.months, required this.days});
}
