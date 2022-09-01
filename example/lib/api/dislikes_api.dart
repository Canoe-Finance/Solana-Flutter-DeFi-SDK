import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dating_app/models/user_model.dart';
import 'package:flutter/material.dart';
import 'package:dating_app/constants/constants.dart';

class DislikesApi {
  /// Get firestore instance
  ///
  final _firestore = FirebaseFirestore.instance;

  Future<void> _saveDislike(String dislikedUserId) async {
    _firestore.collection(C_DISLIKES).add({
      DISLIKED_USER_ID: dislikedUserId,
      DISLIKED_BY_USER_ID: UserModel().user.userId,
      TIMESTAMP: FieldValue.serverTimestamp()
    }).then((_) {
      /// Update current user total disliked profiles
      UserModel().updateUserData(
          userId: UserModel().user.userId,
          data: {USER_TOTAL_DISLIKED: FieldValue.increment(1)});
    });
  }

  Future<void> dislikeUser(
      {required String dislikedUserId,
      required Function(bool) onDislikeResult}) async {
    /// Check if current user already disliked profile
    _firestore
        .collection(C_DISLIKES)
        .where(DISLIKED_BY_USER_ID, isEqualTo: UserModel().user.userId)
        .where(DISLIKED_USER_ID, isEqualTo: dislikedUserId)
        .get()
        .then((QuerySnapshot<Map<String, dynamic>> snapshot) async {
      if (snapshot.docs.isEmpty) {
        // Dislike user
        _saveDislike(dislikedUserId);
        onDislikeResult(true);
        debugPrint('dislikeUser() -> success');
      } else {
        onDislikeResult(false);
        debugPrint('You already disliked the user');
      }
    }).catchError((e) {
      debugPrint('dislikeUser() -> error: $e');
    });
  }

  /// Get disliked profiles for current user
  Future<List<DocumentSnapshot<Map<String, dynamic>>>> getDislikedUsers({
    required bool withLimit,
    bool loadMore = false,
    DocumentSnapshot<Map<String, dynamic>>? userLastDoc,
  }) async {
    /// Build query
    Query<Map<String, dynamic>> usersQuery = _firestore
        .collection(C_DISLIKES)
        .where(DISLIKED_BY_USER_ID, isEqualTo: UserModel().user.userId);

    /// Finalize query
    usersQuery = usersQuery.orderBy(TIMESTAMP, descending: true);

    /// Check load loadMore
    if (loadMore) {
      usersQuery = usersQuery.startAfterDocument(userLastDoc!);
    }

    // Check limit param
    if (withLimit) {
      usersQuery = usersQuery.limit(20);
    }

    final querySnapshot = await usersQuery.get().catchError((e) {
      debugPrint('getDislikedUsers() -> error: $e');
    });

    return querySnapshot.docs;
  }

  /// Undo disliked profile: if current user decides to like it again
  Future<void> deleteDislikedUser(String dislikedUserId) async {
    _firestore
        .collection(C_DISLIKES)
        .where(DISLIKED_USER_ID, isEqualTo: dislikedUserId)
        .where(DISLIKED_BY_USER_ID, isEqualTo: UserModel().user.userId)
        .get()
        .then((QuerySnapshot<Map<String, dynamic>> snapshot) async {
      /// Check if doc exists
      if (snapshot.docs.isNotEmpty) {
        // Get doc and delete it
        final ref = snapshot.docs.first;
        await ref.reference.delete();

        /// Decrement current user total dislikes
        final int currentUserDislikes = UserModel().user.userTotalDisliked - 1;

        await UserModel().updateUserData(
            userId: UserModel().user.userId,
            data: {USER_TOTAL_DISLIKED: currentUserDislikes});
        debugPrint('deleteDislike() -> success');
      } else {
        debugPrint('deleteDislike() -> doc does not exists');
      }
    }).catchError((e) {
      debugPrint('deleteDislike() -> error: $e');
    });
  }

  Future<void> deleteDislikedUsers() async {
    _firestore
        .collection(C_DISLIKES)
        .where(DISLIKED_BY_USER_ID, isEqualTo: UserModel().user.userId)
        .get()
        .then((QuerySnapshot<Map<String, dynamic>> snapshot) async {
      /// Check docs
      if (snapshot.docs.isNotEmpty) {
        // Loop docs to be deleted
        for (var doc in snapshot.docs) {
          await doc.reference.delete();
        }
        debugPrint('deleteDislikedUsers() -> deleted');
      }
    });
  }

  Future<void> deleteDislikedMeUsers() async {
    _firestore
        .collection(C_DISLIKES)
        .where(DISLIKED_USER_ID, isEqualTo: UserModel().user.userId)
        .get()
        .then((QuerySnapshot<Map<String, dynamic>> snapshot) async {
      /// Check docs
      if (snapshot.docs.isNotEmpty) {
        // Loop docs to be deleted
        for (var doc in snapshot.docs) {
          await doc.reference.delete();
        }
        debugPrint('deleteDislikedMeUsers() -> deleted');
      }
    });
  }
}
