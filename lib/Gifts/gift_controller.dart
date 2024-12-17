import 'dart:convert';
import 'dart:io';

import 'package:celebratio/Model/fb_event.dart';
import 'package:celebratio/Model/fb_gift.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../app_state.dart';
import 'package:http/http.dart' as http;

class GiftController extends ChangeNotifier {
  final BuildContext context;
  final FbEvent event;

  List<FbGift> _allGifts = [];
  List<FbGift> _filteredGifts = [];
  final List<String> _giftPledgerNames = [];
  String _selectedFilter = 'All';
  String _sortType = "";
  String? _currentEventCreatorName;
  final ImagePicker _picker = ImagePicker();
  late ApplicationState _appState;
  // Getters
  List<FbGift> get filteredGifts => _filteredGifts;

  String get selectedFilter => _selectedFilter;

  String get sortType => _sortType;

  FbEvent get currentEvent => event;

  String? get currentEventCreatorName => _currentEventCreatorName;

  List<String> get giftPledgerNames => _giftPledgerNames;

  GiftController({
    required this.context,
    required this.event,
  });

  // Initialize the controller
  Future<void> init() async {
    _appState = Provider.of<ApplicationState>(context, listen: false);
    _currentEventCreatorName =
        await _appState.getUserNameById(currentEvent.createdBy);
    _appState.addListener(fetchGifts);
    await fetchGifts();
  }

  // Fetch gifts from the database
  Future<void> fetchGifts() async {
    try {
      var gifts = await _appState.getGiftsByEventId(event.id!);
      _allGifts = List.from(gifts);

      // loop over all gifts and get the pledger name for each pledged gift
      _giftPledgerNames.clear();
      for (var gift in _allGifts) {
        if (gift.status == 'Pledged') {
          var pledgerName = await _appState.getUserNameById(gift.pledgedBy!);
          _giftPledgerNames.add(pledgerName);
        } else {
          _giftPledgerNames.add('');
        }
      }
      filterGifts();
      print("Filtered gifts before calling notify listeners: $_filteredGifts");
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
  Future<void> addGift(FbGift gift) async {
    try {
      gift.eventId = event.id!;
      await _appState.addGift(gift);
      await fetchGifts();
    } catch (e) {
      print('Error adding gift: $e');
      rethrow;
    }
  }

  Future<XFile?> pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    return pickedFile;
  }

  Future<String?> uploadImage(File? imageFile) async {
    const String apiKey = 'f16ebd757c6b75bb4204d51b558c01a7';
    if (imageFile == null) {
      return null;
    }

    final request = http.MultipartRequest(
      'POST',
      Uri.parse('https://api.imgbb.com/1/upload?key=$apiKey'),
    );
    request.files
        .add(await http.MultipartFile.fromPath('image', imageFile.path));
    try {
      final response = await request.send();
      if (response.statusCode == 200) {
        final responseBody = await response.stream.bytesToString();
        final jsonResponse = jsonDecode(responseBody);
        return jsonResponse['data']['url'];
      } else if(context.mounted){
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(
                  'Image upload failed with status ${response.statusCode}')),
        );
        return null;
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error uploading image: $e')),
      );
      return null;
    }
  }

  // Delete gift
  Future<bool> deleteGift(String giftId) async {
    try {
      bool result = await _appState.deleteGift(giftId);
      if (result) {
        _allGifts.removeWhere((gift) => gift.id == giftId);
        filterGifts();
        return true;
      }
      return false;
    } catch (e) {
      print('Error deleting gift: $e');
      rethrow;
    }
  }

  Future<bool> editGift(FbGift gift) async {
    try {
      bool result = await _appState.updateGift(gift);
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
    required String creatorId,
    required String giftId,
    required String userId,
  }) async {
    try {
      bool result = await _appState.pledgeGift(
        creatorId: creatorId,
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

  Future<void> publishGift(FbGift gift) async {
    try {
      await _appState.publishGift(gift);
      await fetchGifts();
    } catch (e) {
      print('Error publishing gift: $e');
      rethrow;
    }
  }

  Future<void> publishEvent() async {
    try {
      await _appState.publishEvent(event); // you need to use new id now
    } catch (e) {
      print('Error publishing event: $e');
      rethrow;
    }
  }

  @override
  void dispose() {
    _appState.removeListener(fetchGifts);
    _allGifts.clear();
    _filteredGifts.clear();
    super.dispose();
  }
}
