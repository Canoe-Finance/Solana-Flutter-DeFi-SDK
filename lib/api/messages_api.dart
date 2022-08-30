import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dating_app/api/conversations_api.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:dating_app/constants/constants.dart';
import 'package:dating_app/models/user_model.dart';

class MessagesApi {
  /// FINAL VARIABLES
  ///
  final _firestore = FirebaseFirestore.instance;
  final _conversationsApi = ConversationsApi();

  /// Get stream messages for current user
  Stream<QuerySnapshot<Map<String, dynamic>>> getMessages(String withUserId) {
    return _firestore
        .collection(C_MESSAGES)
        .doc(UserModel().user.userId)
        .collection(withUserId)
        .orderBy(TIMESTAMP)
        .snapshots();
  }

  /// Save chat message
  Future<void> saveMessage({
    required String type,
    required String senderId,
    required String receiverId,
    required String fromUserId,
    required String userPhotoLink,
    required String userFullName,
    required String textMsg,
    required String imgLink,
    required bool isRead,
  }) async {
    /// Save message
    await _firestore
        .collection(C_MESSAGES)
        .doc(senderId)
        .collection(receiverId)
        .doc()
        .set(<String, dynamic>{
      USER_ID: fromUserId,
      MESSAGE_TYPE: type,
      MESSAGE_TEXT: textMsg,
      MESSAGE_IMG_LINK: imgLink,
      TIMESTAMP: FieldValue.serverTimestamp(),
    });

    /// Save last conversation
    await _conversationsApi.saveConversation(
        type: type,
        senderId: senderId,
        receiverId: receiverId,
        userPhotoLink: userPhotoLink,
        userFullName: userFullName,
        textMsg: textMsg,
        isRead: isRead);
  }

  /// Delete current user chat
  Future<void> deleteChat(String withUserId, {bool isDoubleDel = false}) async {
    /// Get Chat for current user
    ///
    final List<DocumentSnapshot<Map<String, dynamic>>> _messages01 =
        (await _firestore
                .collection(C_MESSAGES)
                .doc(UserModel().user.userId)
                .collection(withUserId)
                .get())
            .docs;

    // Check messages sent by current user to be deleted
    if (_messages01.isNotEmpty) {
      // Loop messages to be deleted
      for (var msg in _messages01) {
        // Check msg type
        if (msg[MESSAGE_TYPE] == 'image' &&
            msg[USER_ID] == UserModel().user.userId) {
          /// Delete uploaded images by current user
          await FirebaseStorage.instance
              .refFromURL(msg[MESSAGE_IMG_LINK])
              .delete();
        }
        await msg.reference.delete();
      }

      // Delete current user conversation
      if (!isDoubleDel) {
        _conversationsApi.deleteConverce(withUserId);
      }
    }

    /// Check param
    if (isDoubleDel) {
      /// Get messages sent by onother user to be deleted
      final List<DocumentSnapshot<Map<String, dynamic>>> _messages02 =
          (await _firestore
                  .collection(C_MESSAGES)
                  .doc(withUserId)
                  .collection(UserModel().user.userId)
                  .get())
              .docs;

      // Check messages
      if (_messages02.isNotEmpty) {
        // Loop messages to be deleted
        for (var msg in _messages02) {
          // Check msg type
          if (msg[MESSAGE_TYPE] == 'image' && msg[USER_ID] == withUserId) {
            /// Delete uploaded images by onother user
            await FirebaseStorage.instance
                .refFromURL(msg[MESSAGE_IMG_LINK])
                .delete();
          }
          await msg.reference.delete();
        }
      }
    }
  }
}
