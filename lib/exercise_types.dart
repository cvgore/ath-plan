import 'package:flutter/material.dart' show Icons, IconData;

class ExerciseTypes {
  static const String CONSERVATOIRE = "CONSERVATOIRE";
  static const String LECTURE = "LECTURE";
  static const String EXERCISE = "EXERCISE";
  static const String LABORATORY = "LABORATORY";
  static const String PROJECT = "PROJECT";
  static const String LANG_COURSE = "LANG_COURSE";
  static const String PRACTICAL_LANG = "PRACTICAL_LANG";
  static const String WORK = "WORK";
  static const String RESERVED_LECTURE = "RESERVED_LECTURE";
  static const List<String> list = [
    ExerciseTypes.EXERCISE,
    ExerciseTypes.CONSERVATOIRE,
    ExerciseTypes.LABORATORY,
    ExerciseTypes.LANG_COURSE,
    ExerciseTypes.WORK,
    ExerciseTypes.PRACTICAL_LANG,
    ExerciseTypes.PROJECT,
    ExerciseTypes.LECTURE,
    ExerciseTypes.RESERVED_LECTURE,
  ];

  static IconData getIconByType(String type) {
    switch(type) {
      case ExerciseTypes.CONSERVATOIRE:
        return Icons.forum;
      case ExerciseTypes.LECTURE:
        return Icons.hearing;
      case ExerciseTypes.EXERCISE:
        return Icons.edit;
      case ExerciseTypes.LABORATORY:
        return Icons.desktop_windows;
      case ExerciseTypes.PROJECT:
        return Icons.insert_drive_file;
      case ExerciseTypes.LANG_COURSE:
        return Icons.translate;
      case ExerciseTypes.PRACTICAL_LANG:
        return Icons.mic;
      case ExerciseTypes.WORK:
        return Icons.work;
      case ExerciseTypes.RESERVED_LECTURE:
        return Icons.book;
    }
    return Icons.error_outline;
  }

  static String getLocalizedNameByType(String type) {
    switch(type) {
      case ExerciseTypes.CONSERVATOIRE:
        return 'konwersatorium';
      case ExerciseTypes.LECTURE:
        return 'wykład';
      case ExerciseTypes.EXERCISE:
        return 'ćwiczenia';
      case ExerciseTypes.LABORATORY:
        return 'laboratorium';
      case ExerciseTypes.PROJECT:
        return 'projekt';
      case ExerciseTypes.LANG_COURSE:
        return 'lektorat';
      case ExerciseTypes.PRACTICAL_LANG:
        return 'praktyczna nauka języka';
      case ExerciseTypes.WORK:
        return 'praca';
      case ExerciseTypes.RESERVED_LECTURE:
        return 'wykład rezerwowany';
    }
    return null;
  }

  static String getShortLocalNameByType(String type) {
    switch(type) {
      case ExerciseTypes.CONSERVATOIRE:
        return 'konwersatorium';
      case ExerciseTypes.LECTURE:
        return 'wykład';
      case ExerciseTypes.EXERCISE:
        return 'ćwiczenia';
      case ExerciseTypes.LABORATORY:
        return 'laboratorium';
      case ExerciseTypes.PROJECT:
        return 'projekt';
      case ExerciseTypes.LANG_COURSE:
        return 'lektorat';
      case ExerciseTypes.PRACTICAL_LANG:
        return 'prakt. nauka jęz.';
      case ExerciseTypes.WORK:
        return 'praca';
      case ExerciseTypes.RESERVED_LECTURE:
        return 'wykład rezerw.';
    }
    return null;
  }
}
