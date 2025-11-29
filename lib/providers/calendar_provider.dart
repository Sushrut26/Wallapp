import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../models/calendar_event.dart';

class CalendarProvider extends ChangeNotifier {
  List<CalendarEvent> _events = [];
  DateTime _selectedDate = DateTime.now();

  List<CalendarEvent> get events => _events;
  DateTime get selectedDate => _selectedDate;

  CalendarProvider() {
    _loadEvents();
  }

  void setSelectedDate(DateTime date) {
    _selectedDate = date;
    notifyListeners();
  }

  List<CalendarEvent> getEventsForDate(DateTime date) {
    return _events.where((event) {
      return event.startTime.year == date.year &&
          event.startTime.month == date.month &&
          event.startTime.day == date.day;
    }).toList();
  }

  Map<DateTime, List<CalendarEvent>> getEventsByDate() {
    final Map<DateTime, List<CalendarEvent>> eventMap = {};
    for (var event in _events) {
      final date = DateTime(
        event.startTime.year,
        event.startTime.month,
        event.startTime.day,
      );
      if (eventMap[date] == null) {
        eventMap[date] = [];
      }
      eventMap[date]!.add(event);
    }
    return eventMap;
  }

  Future<void> _loadEvents() async {
    final prefs = await SharedPreferences.getInstance();
    final eventsJson = prefs.getString('events');
    if (eventsJson != null) {
      final List<dynamic> decoded = json.decode(eventsJson);
      _events = decoded.map((item) => CalendarEvent.fromJson(item)).toList();
      notifyListeners();
    }
  }

  Future<void> _saveEvents() async {
    final prefs = await SharedPreferences.getInstance();
    final eventsJson =
        json.encode(_events.map((event) => event.toJson()).toList());
    await prefs.setString('events', eventsJson);
  }

  Future<void> addEvent({
    required String title,
    required String description,
    required DateTime startTime,
    required DateTime endTime,
    String? location,
    bool isAllDay = false,
    String color = 'blue',
  }) async {
    final event = CalendarEvent(
      id: const Uuid().v4(),
      title: title,
      description: description,
      startTime: startTime,
      endTime: endTime,
      location: location,
      isAllDay: isAllDay,
      color: color,
    );
    _events.add(event);
    await _saveEvents();
    notifyListeners();
  }

  Future<void> updateEvent({
    required String id,
    String? title,
    String? description,
    DateTime? startTime,
    DateTime? endTime,
    String? location,
    bool? isAllDay,
    String? color,
  }) async {
    final index = _events.indexWhere((event) => event.id == id);
    if (index != -1) {
      _events[index] = _events[index].copyWith(
        title: title,
        description: description,
        startTime: startTime,
        endTime: endTime,
        location: location,
        isAllDay: isAllDay,
        color: color,
      );
      await _saveEvents();
      notifyListeners();
    }
  }

  Future<void> deleteEvent(String id) async {
    _events.removeWhere((event) => event.id == id);
    await _saveEvents();
    notifyListeners();
  }
}
