import 'package:celebratio/Model/fb_event.dart';
import 'package:celebratio/Model/fb_gift.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../app_state.dart';

class GiftController extends ChangeNotifier {
  final BuildContext context;
  final FbEvent event;

  List<FbGift> _allGifts = [];
  List<FbGift> _filteredGifts = [];
  String _selectedFilter = 'All';
  String _sortType = "";
  String? _currentEventCreatorName;

  // Getters
  List<FbGift> get filteredGifts => _filteredGifts;

  String get selectedFilter => _selectedFilter;

  String get sortType => _sortType;

  FbEvent get currentEvent => event;

  String? get currentEventCreatorName => _currentEventCreatorName;

  GiftController({
    required this.context,
    required this.event,
  });

  // Initialize the controller
  Future<void> init() async {
    var appState = Provider.of<ApplicationState>(context, listen: false);
    _currentEventCreatorName =
        await appState.getUserNameById(currentEvent.createdBy!);
    print('Event creator name: $_currentEventCreatorName');
    await fetchGifts();
  }

  // Fetch gifts from the database
  Future<void> fetchGifts() async {
    try {
      var appState = Provider.of<ApplicationState>(context, listen: false);
      var gifts = await appState.getGiftsByEventId(event.id!);
      _allGifts = List.from(gifts);
      filterGifts();
      notifyListeners();
    } catch (e) {
      print('Error fetching gifts: $e');
    }
  }

  // Filter gifts based on selected filter
  void filterGifts() {
    if (_selectedFilter == 'All') {
      _filteredGifts = _allGifts.toList();
    } else {
      _filteredGifts =
          _allGifts.where((gift) => gift.status == _selectedFilter).toList();
    }
    sortGifts(); // Apply current sort after filtering
    notifyListeners();
  }

  // Sort gifts based on selected sort type
  void sortGifts() {
    if (_sortType == "Category") {
      _filteredGifts.sort((a, b) => a.category.compareTo(b.category));
    } else if (_sortType == "Name") {
      _filteredGifts.sort((a, b) => a.name.compareTo(b.name));
    }
  }

  // Update filter and refresh list
  void updateFilter(String filter) {
    _selectedFilter = filter;
    filterGifts();
  }

  // Update sort type and refresh list
  void updateSortType(String type) {
    _sortType = type;
    filterGifts();
  }

  // Clear sort type
  void clearSort() {
    _sortType = "";
    filterGifts();
  }

  // Add new gift
  Future<void> addGift({
    required String name,
    required String description,
    required String category,
    required double price,
  }) async {
    try {
      var appState = Provider.of<ApplicationState>(context, listen: false);
      await appState.addGift(
        eventId: event.id!,
        name: name,
        description: description,
        category: category,
        price: price,
      );
      await fetchGifts();
    } catch (e) {
      print('Error adding gift: $e');
      rethrow;
    }
  }

  // Delete gift
  Future<void> deleteGift(String giftId) async {
    try {
      var appState = Provider.of<ApplicationState>(context, listen: false);
      await appState.deleteGift(giftId: giftId);
      _allGifts.removeWhere((gift) => gift.id == giftId);
      filterGifts();
    } catch (e) {
      print('Error deleting gift: $e');
      rethrow;
    }
  }

  Future<bool> editGift({
    required String giftId,
    required String name,
    required double price,
    required String description,
    required String category,
  }) async {
    try {
      var appState = Provider.of<ApplicationState>(context, listen: false);
      bool result = await appState.editGift(
        giftId: giftId,
        updatedData: {
          'name': name,
          'price': price,
          'description': description,
          'category': category,
        },
      );
      if (result) {
        await fetchGifts();
        return true;
      }
      return false;
    } catch (e) {
      print('Error editing gift: $e');
      rethrow;
    }
  }

  Future<bool> pledgeGift({
    required String giftId,
    required String userId,
  }) async {
    try {
      var appState = Provider.of<ApplicationState>(context, listen: false);
      bool result = await appState.editGift(
        giftId: giftId,
        updatedData: {
          'status': 'Pledged',
          'pledgedBy': userId,
        },
      );
      if (result) {
        await fetchGifts();
        return true;
      }
      return false;
    } catch (e) {
      print('Error pledging gift: $e');
      rethrow;
    }
  }

  @override
  void dispose() {
    _allGifts.clear();
    _filteredGifts.clear();
    super.dispose();
  }
}
