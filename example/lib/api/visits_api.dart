import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dating_app/api/notifications_api.dart';
import 'package:dating_app/constants/constants.dart';
import 'package:dating_app/models/user_model.dart';
import 'package:flutter/material.dart';

class VisitsApi {
  /// FINAL VARIABLES
  ///
  final _firestore = FirebaseFirestore.instance;
  final _notificationsApi = NotificationsApi();

  /// Save visit in database
  Future<void> _saveVisit({
    required String visitedUserId,
    required String userDeviceToken,
    required String nMessage,
  }) async {
    _firestore.collection(C_VISITS).add({
      VISITED_USER_ID: visitedUserId,
      VISITED_BY_USER_ID: UserModel().user.userId,
      TIMESTAMP: FieldValue.serverTimestamp()
    }).then((_) async {
      /// Update user total visits
      await UserModel().updateUserData(
          userId: visitedUserId,
          data: {USER_TOTAL_VISITS: FieldValue.increment(1)});

      /// Save notification in database
      await _notificationsApi.saveNotification(
        nReceiverId: visitedUserId,
        nType: 'visit',
        nMessage: nMessage,
      );

      /// Send push notification
      await _notificationsApi.sendPushNotification(
          nTitle: APP_NAME,
          nBody: nMessage,
          nType: 'visit',
          nSenderId: UserModel().user.userId,
          nUserDeviceToken: userDeviceToken);
    });
  }

  /// View user profile and increment visits
  Future<void> visitUserProfile(
      {required String visitedUserId,
      required String userDeviceToken,
      required String nMessage}) async {
    /// Check visit profile id: if current user does not record
    if (visitedUserId == UserModel().user.userId) return;

    /// Check if current user already visited profile
    _firestore
        .collection(C_VISITS)
        .where(VISITED_BY_USER_ID, isEqualTo: UserModel().user.userId)
        .where(VISITED_USER_ID, isEqualTo: visitedUserId)
        .get()
        .then((QuerySnapshot<Map<String, dynamic>> snapshot) async {
      if (snapshot.docs.isEmpty) {
        _saveVisit(
            visitedUserId: visitedUserId,
            userDeviceToken: userDeviceToken,
            nMessage: nMessage);
        debugPrint('visitUserProfile() -> success');
      } else {
        debugPrint('You already visited the user');
      }
    }).catchError((e) {
      debugPrint('visitUserProfile() -> error: $e');
    });
  }

  /// Get users who visited current user profile
  Future<List<DocumentSnapshot<Map<String, dynamic>>>> getUserVisits(
      {bool loadMore = false,
      DocumentSnapshot<Map<String, dynamic>>? userLastDoc}) async {
    /// Build query
    Query<Map<String, dynamic>> usersQuery = _firestore
        .collection(C_VISITS)
        .where(VISITED_USER_ID, isEqualTo: UserModel().user.userId);

    /// Check loadMore
    if (loadMore) {
      usersQuery = usersQuery.startAfterDocument(userLastDoc!);
    }

    /// Finalize query and limit data
    usersQuery = usersQuery.orderBy(TIMESTAMP, descending: true);
    usersQuery = usersQuery.limit(20);

    final QuerySnapshot<Map<String, dynamic>> querySnapshot =
        await usersQuery.get().catchError((e) {
      debugPrint('getUserVisits() -> error: $e');
    });

    return querySnapshot.docs;
  }

  Future<void> deleteVisitedUsers() async {
    _firestore
        .collection(C_VISITS)
        .where(VISITED_BY_USER_ID, isEqualTo: UserModel().user.userId)
        .get()
        .then((QuerySnapshot<Map<String, dynamic>> snapshot) async {
      /// Check docs
      if (snapshot.docs.isNotEmpty) {
        // Loop docs to be deleted
        for (var doc in snapshot.docs) {
          await doc.reference.delete();
        }
        debugPrint('deleteVisitedUsers() -> deleted');
      }
    });
  }
}
