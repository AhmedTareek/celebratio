import 'package:celebratio/Model/fb_event.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../app_state.dart';


class EventsController extends ChangeNotifier {
  final BuildContext context;
  final String? userUid;

  List<FbEvent> _allEvents = [];
  List<FbEvent> _filteredEvents = [];
  String _sortType = "";
  int _selectedButtonIndex = 0;
  final DateTime _today = DateTime.now();

  EventsController({required this.context, this.userUid});

  // Getters
  List<FbEvent> get filteredEvents => _filteredEvents;
  int get selectedButtonIndex => _selectedButtonIndex;
  String get sortType => _sortType;

  // Initialize the controller
  Future<void> init() async {
    await fetchEvents();
    filterEvents();
  }

  // Fetch events from the database
  Future<void> fetchEvents() async {
    try {
      var appState = Provider.of<ApplicationState>(context, listen: false);
      String uid = userUid ??  FirebaseAuth.instance.currentUser!.uid;
      List<FbEvent> friendsEvents = await appState.getEventsByFriendId(uid);

      _allEvents = friendsEvents.toList();
      filterEvents();
      notifyListeners();
    } catch (e) {
      print('Error fetching events: $e');
      // You might want to handle the error appropriately here
    }
  }

  // Filter events based on selected filter (Past, Current, Upcoming)
  void filterEvents() {
    _filteredEvents = _allEvents.where((event) {
      final date = event.date;
      if (_selectedButtonIndex == 0) {
        return date.isBefore(_today) && !_isSameDay(date, _today);
      } else if (_selectedButtonIndex == 1) {
        return _isSameDay(date, _today);
      }
      return date.isAfter(_today);
    }).toList();

    sortEvents(); // Apply current sort after filtering
    notifyListeners();
  }

  // Sort events based on selected sort type
  void sortEvents() {
    if (_sortType == "Category") {
      _filteredEvents.sort((a, b) => a.category.compareTo(b.category));
    } else if (_sortType == "Name") {
      _filteredEvents.sort((a, b) => a.name.compareTo(b.name));
    }
    notifyListeners();
  }

  // Update selected filter index and re-filter events
  void updateFilter(int index) {
    _selectedButtonIndex = index;
    filterEvents();
  }

  // Update sort type and re-sort events
  void updateSortType(String type) {
    _sortType = type;
    sortEvents();
  }

  // Delete an event
  Future<void> deleteEvent(String eventId) async {
    try {
      var appState = Provider.of<ApplicationState>(context, listen: false);
      await appState.deleteEvent(eventId: eventId);

      // Remove from local lists
      _allEvents.removeWhere((event) => event.id == eventId);
      filterEvents(); // This will also update filtered events
    } catch (e) {
      print('Error deleting event: $e');
      rethrow; // Rethrow to handle in UI
    }
  }

  // Helper method to check if two dates are the same day
  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  // Clear data when disposing
  @override
  void dispose() {
    _allEvents.clear();
    _filteredEvents.clear();
    super.dispose();
  }
}