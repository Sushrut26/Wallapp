import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../models/calendar_event.dart';
import '../utils/input_validator.dart';

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
    try {
      final prefs = await SharedPreferences.getInstance();
      final eventsJson = prefs.getString('events');
      if (eventsJson != null && eventsJson.isNotEmpty) {
        final List<dynamic> decoded = json.decode(eventsJson);
        _events = decoded
            .map((item) {
              try {
                return CalendarEvent.fromJson(item);
              } catch (e) {
                debugPrint('Error parsing event item: $e');
                return null;
              }
            })
            .whereType<CalendarEvent>()
            .toList();
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error loading events: $e');
      _events = [];
    }
  }

  Future<void> _saveEvents() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final eventsJson =
          json.encode(_events.map((event) => event.toJson()).toList());
      await prefs.setString('events', eventsJson);
    } catch (e) {
      debugPrint('Error saving events: $e');
    }
  }

  Future<bool> addEvent({
    required String title,
    required String description,
    required DateTime startTime,
    required DateTime endTime,
    String? location,
    bool isAllDay = false,
    String color = 'blue',
  }) async {
    // Validate inputs
    final titleError = InputValidator.validateTitle(title);
    if (titleError != null) return false;

    final descError = InputValidator.validateDescription(description);
    if (descError != null) return false;

    if (location != null) {
      final locError = InputValidator.validateLocation(location);
      if (locError != null) return false;
    }

    if (!InputValidator.isValidDate(startTime) ||
        !InputValidator.isValidDate(endTime)) {
      return false;
    }

    if (endTime.isBefore(startTime)) return false;

    // Sanitize inputs
    final sanitizedTitle = InputValidator.sanitize(title);
    final sanitizedDescription = InputValidator.sanitize(description);
    final sanitizedLocation =
        location != null ? InputValidator.sanitize(location) : null;

    final event = CalendarEvent(
      id: const Uuid().v4(),
      title: sanitizedTitle,
      description: sanitizedDescription,
      startTime: startTime,
      endTime: endTime,
      location: sanitizedLocation,
      isAllDay: isAllDay,
      color: color,
    );
    _events.add(event);
    await _saveEvents();
    notifyListeners();
    return true;
  }

  Future<bool> updateEvent({
    required String id,
    String? title,
    String? description,
    DateTime? startTime,
    DateTime? endTime,
    String? location,
    bool? isAllDay,
    String? color,
  }) async {
    // Validate inputs if provided
    if (title != null) {
      final titleError = InputValidator.validateTitle(title);
      if (titleError != null) return false;
    }

    if (description != null) {
      final descError = InputValidator.validateDescription(description);
      if (descError != null) return false;
    }

    if (location != null) {
      final locError = InputValidator.validateLocation(location);
      if (locError != null) return false;
    }

    if (startTime != null && !InputValidator.isValidDate(startTime)) {
      return false;
    }

    if (endTime != null && !InputValidator.isValidDate(endTime)) {
      return false;
    }

    final index = _events.indexWhere((event) => event.id == id);
    if (index != -1) {
      _events[index] = _events[index].copyWith(
        title: title != null ? InputValidator.sanitize(title) : null,
        description:
            description != null ? InputValidator.sanitize(description) : null,
        startTime: startTime,
        endTime: endTime,
        location: location != null ? InputValidator.sanitize(location) : null,
        isAllDay: isAllDay,
        color: color,
      );
      await _saveEvents();
      notifyListeners();
      return true;
    }
    return false;
  }

  Future<void> deleteEvent(String id) async {
    _events.removeWhere((event) => event.id == id);
    await _saveEvents();
    notifyListeners();
  }
}
