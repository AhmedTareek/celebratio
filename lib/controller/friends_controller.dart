import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:celebratio/Model/friend.dart';
import 'package:provider/provider.dart';
import '../app_state.dart';

class FriendsController extends ChangeNotifier {
  final BuildContext context;
  final TextEditingController searchController = TextEditingController();
  late ApplicationState _appState;
  List<Friend> _allFriends = [];
  List<Friend> _filteredFriends = [];




  FriendsController(this.context) {
    _appState = Provider.of<ApplicationState>(context, listen: false);
    _appState.addListener(fetchFriends); // problem if you are not in same page as
    // dispose will be called on this class
    searchController.addListener(_filterFriends);
  }

  List<Friend> get filteredFriends => _filteredFriends;

  void _filterFriends() {
    String query = searchController.text.toLowerCase();
    _filteredFriends = _allFriends
        .where((friend) => friend.name.toLowerCase().contains(query))
        .toList();
    notifyListeners();
  }

  Future<void> fetchFriends() async {
    try {
      var temp = await _appState.getFriends();
      _allFriends = temp.toList();
      _filterFriends();
    } catch (e) {
      log('Error fetching friends: $e');
    }
  }

  Future<void> addNewFriend(String email) async {
    if (email.isEmpty) {
      throw Exception('Email cannot be empty');
    }

    try {
      await _appState.addFriend(email: email);
      await fetchFriends();
    } catch (e) {
      log('Error adding friend: $e');
    }
  }

  Future<int> getUpcomingEventsCount(String userId) async {
    try {
      return await _appState.getUpcomingEventsCountByUserId(userId);
    } catch (e) {
      log('Error fetching events count: $e');
      return 0;
    }
  }

  @override
  void dispose() {
    _appState.removeListener(fetchFriends);
    searchController.dispose();
    super.dispose();
  }
}
