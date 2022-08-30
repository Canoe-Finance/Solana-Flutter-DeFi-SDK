import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dating_app/models/user_model.dart';
import 'package:flutter/material.dart';
import 'package:dating_app/constants/constants.dart';

class BlockedUsersApi {
  /// Get firestore instance
  ///
  final _firestore = FirebaseFirestore.instance;

  // Save blocked user in database
  Future<void> _saveBlockedUser(String blockedUserId) async {
    _firestore.collection(C_BLOCKED_USERS).add({
      BLOCKED_USER_ID: blockedUserId,
      BLOCKED_BY_USER_ID: UserModel().user.userId,
      TIMESTAMP: FieldValue.serverTimestamp()
    });
  }

  /// Get blocked profiles for current user
  Future<List<DocumentSnapshot<Map<String, dynamic>>>> getblockedUsers() async {
    /// Build query
    Query<Map<String, dynamic>> usersQuery = _firestore
        .collection(C_BLOCKED_USERS)
        .where(BLOCKED_BY_USER_ID, isEqualTo: UserModel().user.userId)
        .orderBy(TIMESTAMP, descending: true);

    final QuerySnapshot<Map<String, dynamic>> querySnapshot =
        await usersQuery.get().catchError((e) {
      debugPrint('getblockedUsers() -> error: ${e.toString()}');
    });

    return querySnapshot.docs;
  }


  /// Remove Blocked Profiles from the list
  Future<void> removeBlockedUsers(
    List<DocumentSnapshot<Map<String, dynamic>>> allUsers) async {
      
    // Get Blocked Profiles
    final List<DocumentSnapshot<Map<String, dynamic>>> blockedProfiles =
        (await _firestore
            .collection(C_BLOCKED_USERS)
            .where(BLOCKED_BY_USER_ID, isEqualTo: UserModel().user.userId)
            .get())
            .docs;
    // Remove Liked Profiles from the list
    if (blockedProfiles.isNotEmpty) {
      for (var blockedUser in blockedProfiles) {
        allUsers.removeWhere(
            (userDoc) => userDoc[USER_ID] == blockedUser[BLOCKED_USER_ID]);
      }
    }
  }

  /// Block user profile
  Future<bool> blockUser({required String blockedUserId}) async {
    /// Check if current user already blocked profile
    final query = await (_firestore
            .collection(C_BLOCKED_USERS)
            .where(BLOCKED_BY_USER_ID, isEqualTo: UserModel().user.userId)
            .where(BLOCKED_USER_ID, isEqualTo: blockedUserId)
            .get())
        .catchError((e) {
      // Debug error
      debugPrint('blockUser() -> error: ${e.toString()}');
    });

    if (query.docs.isEmpty) {
      // Save blocked user
      _saveBlockedUser(blockedUserId);

      // Debug
      debugPrint('blockUser() -> success');
      // Result
      return true;
    } else {
      // Debug
      debugPrint('blockUser() -> You already blocked this user');
      // Result
      return false;
    }
  }

  /// Check Blocked profile status
  Future<bool> isBlocked({
    required String blockedUserId,
    required String blockedByUserId,
  }) async {
    /// Check if current user already blocked profile
    final query = await (_firestore
            .collection(C_BLOCKED_USERS)
            .where(BLOCKED_BY_USER_ID, isEqualTo: blockedByUserId)
            .where(BLOCKED_USER_ID, isEqualTo: blockedUserId)
            .get())
        .catchError((e) {
      // Debug error
      debugPrint('isBlocked() -> error: ${e.toString()}');
    });

    return query.docs.isNotEmpty;
  }

  /// Undo blocked profile: if current user decides to like it again
  Future<void> deleteBlockedUser(String blockedUserId) async {
    _firestore
        .collection(C_BLOCKED_USERS)
        .where(BLOCKED_USER_ID, isEqualTo: blockedUserId)
        .where(BLOCKED_BY_USER_ID, isEqualTo: UserModel().user.userId)
        .get()
        .then((QuerySnapshot<Map<String, dynamic>> snapshot) async {
      /// Check if doc exists
      if (snapshot.docs.isNotEmpty) {
        // Get doc and delete it
        final ref = snapshot.docs.first;
        await ref.reference.delete();

        // Debug
        debugPrint('deleteblock() -> success');
      } else {
        // Debug
        debugPrint('deleteblock() -> doc does not exists');
      }
    }).catchError((e) {
      // Debug
      debugPrint('deleteblock() -> error: ${e.toString()}');
    });
  }

  // Delete Blocked Users
  Future<void> deleteBlockedUsers() async {
    _firestore
        .collection(C_BLOCKED_USERS)
        .where(BLOCKED_BY_USER_ID, isEqualTo: UserModel().user.userId)
        .get()
        .then((QuerySnapshot<Map<String, dynamic>> snapshot) async {
      // Check docs
      if (snapshot.docs.isNotEmpty) {
        // Loop docs to be deleted
        for (var doc in snapshot.docs) {
          await doc.reference.delete();
        }
        // Debug
        debugPrint('deleteblockedUsers() -> success');
      }
    });
  }
}
