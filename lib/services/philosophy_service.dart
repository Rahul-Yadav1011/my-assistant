import '../data/philosophy_data.dart';

class PhilosophyService {
  PhilosophyService._();
  static final PhilosophyService instance = PhilosophyService._();

  PhilosophyEntry quoteOfTheDay() {
    final dayOfYear = _dayOfYear(DateTime.now());
    return philosophyQuotes[dayOfYear % philosophyQuotes.length];
  }

  List<PhilosophyEntry> quotesBySchool(String school) {
    return philosophyQuotes.where((q) => q.school == school).toList(growable: false);
  }

  List<PhilosophySchool> allSchools() => List.of(philosophySchools);

  int _dayOfYear(DateTime d) {
    final start = DateTime(d.year, 1, 1);
    return d.difference(start).inDays;
  }
}
