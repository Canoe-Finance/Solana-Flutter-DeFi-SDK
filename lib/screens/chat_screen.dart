import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dating_app/api/blocked_users_api.dart';
import 'package:dating_app/api/likes_api.dart';
import 'package:dating_app/api/matches_api.dart';
import 'package:dating_app/api/messages_api.dart';
import 'package:dating_app/api/notifications_api.dart';
import 'package:dating_app/constants/constants.dart';
import 'package:dating_app/datas/user.dart';
import 'package:dating_app/dialogs/common_dialogs.dart';
import 'package:dating_app/dialogs/progress_dialog.dart';
import 'package:dating_app/helpers/app_localizations.dart';
import 'package:dating_app/main.dart';
import 'package:dating_app/models/user_model.dart';
import 'package:dating_app/screens/profile_screen.dart';
import 'package:dating_app/widgets/chat_message.dart';
import 'package:dating_app/widgets/image_source_sheet.dart';
import 'package:dating_app/widgets/my_circular_progress.dart';
import 'package:dating_app/widgets/show_scaffold_msg.dart';
import 'package:dating_app/widgets/svg_icon.dart';
import 'package:flutter/material.dart';
import 'package:timeago/timeago.dart' as timeago;

class ChatScreen extends StatefulWidget {
  /// Get user object
  final User user;

  const ChatScreen({Key? key, required this.user}) : super(key: key);

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  // Variables
  final _textController = TextEditingController();
  final _messagesController = ScrollController();
  final _messagesApi = MessagesApi();
  final _matchesApi = MatchesApi();
  final _likesApi = LikesApi();
  final _notificationsApi = NotificationsApi();
  late Stream<QuerySnapshot<Map<String, dynamic>>> _messages;
  bool _isComposing = false;
  late AppLocalizations _i18n;
  late ProgressDialog _pr;
  // Block/Unblock profile feature - variables
  bool? _isRemoteUserBlocked;
  bool _isLocalUserBlocked = false;

  // Close dialog method
  void _close() => navigatorKey.currentState?.pop();

  // Update remote user blocked status
  void _remoteUserBlockedStatus(bool v) {
    if (mounted) {
      setState(() {
        _isRemoteUserBlocked = v;
      });
    }
  }

  /// *** Block remote user profile *** ///
  void _blockProfile() async {
    // Confirm dialog
    confirmDialog(context,
        positiveText: _i18n.translate("BLOCK"),
        message: _i18n.translate("this_profile_will_be_blocked"),
        negativeAction: _close, positiveAction: () async {
      // Hide confirm dialog
      _close();

      // Show processing dialog
      _pr.show(_i18n.translate("processing"));

      // Block profile
      if (await BlockedUsersApi()
        .blockUser(blockedUserId: widget.user.userId)) {
        // Hide progress dialog
        _pr.hide();

        final String msg = _i18n.translate("user_has_been_blocked");
        // Show success dialog
        showScaffoldMessage(message: msg, bgcolor: Colors.green);

        // Update blocked status
        _remoteUserBlockedStatus(true);
      } else {
        // Hide progress dialog
        _pr.hide();

        final String msg = _i18n.translate("you_have_already_blocked_this_user");
        // Show success dialog
        showScaffoldMessage(message: msg, bgcolor: Colors.red);

        // Update blocked status
        _remoteUserBlockedStatus(true);
      }
    });
  }

  /// *** UnBlock remote user profile *** ///
  void _unblockProfile() async {
    // Confirm dialog
    confirmDialog(context,
        positiveText: _i18n.translate("UNBLOCK"),
        message: _i18n.translate(
            "this_profile_will_be_removed_from_the_blocked_users_list"),
        negativeAction: _close, positiveAction: () async {
      // Hide confirm dialog
      _close();

      // Show processing dialog
      _pr.show(_i18n.translate("processing"));

      // Delete blocked profile from the list
      await BlockedUsersApi().deleteBlockedUser(widget.user.userId);

      // Hide progress dialog
      _close();

      final String msg = _i18n.translate("user_has_been_unblocked");
      // Show success dialog
      showScaffoldMessage(message: msg, bgcolor: Colors.green);

      // Update blocked status
      _remoteUserBlockedStatus(false);
    });
  }

  // Check the Blocked user on initState
  void _checkBlockedUser() {
    // Check Receiver user blocked status
    BlockedUsersApi()
      .isBlocked(
        blockedUserId: widget.user.userId, // Receiver user on chat
        blockedByUserId: UserModel().user.userId // Logged user on chat
      ).then((result) => _remoteUserBlockedStatus(result));

    // Check Local user blocked status
    BlockedUsersApi()
        .isBlocked(
            blockedUserId: UserModel().user.userId,
            blockedByUserId: widget.user.userId)
        .then((result) {
      if (mounted) {
        setState(() => _isLocalUserBlocked = result);
      }
    });
  }

  void _scrollMessageList() {
    /// Scroll to button
    _messagesController.animateTo(0.0,
        duration: const Duration(milliseconds: 500), curve: Curves.easeOut);
  }

  /// Get image from camera / gallery
  Future<void> _getImage() async {
    await showModalBottomSheet(
        context: context,
        backgroundColor: Colors.transparent,
        builder: (context) => ImageSourceSheet(
              onImageSelected: (image) async {
                if (image != null) {
                  await _sendMessage(type: 'image', imgFile: image);
                  // close modal
                  Navigator.of(context).pop();
                }
              },
            ));
  }

  // Send message
  Future<void> _sendMessage(
      {required String type, String? text, File? imgFile}) async {
    String textMsg = '';
    String imageUrl = '';

    // Check local user blocked status
    if (_isLocalUserBlocked) {
      final String msg = _i18n.translate(
          "oops_your_profile_has_been_blocked_by_this_user_so_you_can_send_a_message");
      // Show success dialog
      showScaffoldMessage(message: msg, bgcolor: Colors.red);
      return;
    }

    // Check message type
    switch (type) {
      case 'text':
        textMsg = text!;
        break;

      case 'image':
        // Show processing dialog
        _pr.show(_i18n.translate("sending"));

        /// Upload image file
        imageUrl = await UserModel().uploadFile(
            file: imgFile!,
            path: 'uploads/messages',
            userId: UserModel().user.userId);

        _pr.hide();
        break;
    }

    /// Save message for current user
    await _messagesApi.saveMessage(
        type: type,
        fromUserId: UserModel().user.userId,
        senderId: UserModel().user.userId,
        receiverId: widget.user.userId,
        userPhotoLink: widget.user.userProfilePhoto, // other user photo
        userFullName: widget.user.userFullname, // other user ful name
        textMsg: textMsg,
        imgLink: imageUrl,
        isRead: true);

    /// Save copy message for receiver
    await _messagesApi.saveMessage(
        type: type,
        fromUserId: UserModel().user.userId,
        senderId: widget.user.userId,
        receiverId: UserModel().user.userId,
        userPhotoLink: UserModel().user.userProfilePhoto, // current user photo
        userFullName: UserModel().user.userFullname, // current user ful name
        textMsg: textMsg,
        imgLink: imageUrl,
        isRead: false);

    /// Send push notification
    await _notificationsApi.sendPushNotification(
        nTitle: APP_NAME,
        nBody: '${UserModel().user.userFullname}, '
            '${_i18n.translate("sent_a_message_to_you")}',
        nType: 'message',
        nSenderId: UserModel().user.userId,
        nUserDeviceToken: widget.user.userDeviceToken);
  }

  @override
  void initState() {
    super.initState();
    _messages = _messagesApi.getMessages(widget.user.userId);
    // Check the blocked user
    _checkBlockedUser();
  }

  @override
  void dispose() {
    _messages.drain();
    _textController.dispose();
    _messagesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    /// Initialization
    _i18n = AppLocalizations.of(context);
    _pr = ProgressDialog(context);

    return Scaffold(
      appBar: AppBar(
        // Show User profile info
        title: GestureDetector(
          child: ListTile(
            contentPadding: const EdgeInsets.only(left: 0),
            leading: CircleAvatar(
              backgroundColor: APP_PRIMARY_COLOR,
              backgroundImage: NetworkImage(widget.user.userProfilePhoto),
              onBackgroundImageError: (e, s) => {debugPrint(e.toString())},
            ),
            title: Text(widget.user.userFullname,
                style: const TextStyle(fontSize: 18)),
          ),
          onTap: () {
            /// Go to profile screen
            Navigator.of(context).push(MaterialPageRoute(
                builder: (context) =>
                    ProfileScreen(user: widget.user, showButtons: false)));
          },
        ),
        actions: <Widget>[
          /// Actions list
          PopupMenuButton<String>(
            initialValue: "",
            itemBuilder: (context) => <PopupMenuEntry<String>>[
              /// Delete Chat
              PopupMenuItem(
                  value: "delete_chat",
                  child: Row(
                    children: <Widget>[
                      SvgIcon("assets/icons/trash_icon.svg",
                          width: 20,
                          height: 20,
                          color: Theme.of(context).primaryColor),
                      const SizedBox(width: 5),
                      Text(_i18n.translate("delete_conversation")),
                    ],
                  )),

              /// Delete Match
              PopupMenuItem(
                  value: "delete_match",
                  child: Row(
                    children: <Widget>[
                      Icon(Icons.highlight_off,
                          color: Theme.of(context).primaryColor),
                      const SizedBox(width: 5),
                      Text(_i18n.translate("delete_match"))
                    ],
                  )),

              // Show Block/Unblock User acticon
              if (_isRemoteUserBlocked != null)
                PopupMenuItem(
                  value: "block",
                  child: Row(
                    children: <Widget>[
                      Icon(Icons.block,
                          color: Theme.of(context).primaryColor),
                      const SizedBox(width: 5),
                      Text(_isRemoteUserBlocked!
                          ? _i18n.translate("UNBLOCK")
                          : _i18n.translate("BLOCK"))
                    ],
                  )),

            ],
            onSelected: (val) {
              /// Control selected value
              switch (val) {
                case "delete_chat":

                  /// Delete chat
                  confirmDialog(context,
                      title: _i18n.translate("delete_conversation"),
                      message: _i18n.translate("conversation_will_be_deleted"),
                      negativeAction: () => Navigator.of(context).pop(),
                      positiveText: _i18n.translate("DELETE"),
                      positiveAction: () async {
                        // Close the confirm dialog
                        Navigator.of(context).pop();

                        // Show processing dialog
                        _pr.show(_i18n.translate("processing"));

                        /// Delete chat
                        await _messagesApi.deleteChat(widget.user.userId);

                        // Hide progress
                        await _pr.hide();
                      });
                  break;

                case "delete_match":
                  errorDialog(context,
                      title: _i18n.translate("delete_match"),
                      message:
                          "${_i18n.translate("are_you_sure_you_want_to_delete_your_match_with")}: "
                          "${widget.user.userFullname}?\n\n"
                          "${_i18n.translate("this_action_cannot_be_reversed")}",
                      positiveText: _i18n.translate("DELETE"),
                      negativeAction: () => Navigator.of(context).pop(),
                      positiveAction: () async {
                        // Show processing dialog
                        _pr.show(_i18n.translate("processing"));

                        /// Delete match
                        await _matchesApi.deleteMatch(widget.user.userId);

                        /// Delete chat
                        await _messagesApi.deleteChat(widget.user.userId);

                        /// Delete like
                        await _likesApi.deleteLike(widget.user.userId);

                        // Hide progress
                        _pr.hide();
                        // Hide dialog
                        Navigator.of(context).pop();
                        // Close chat screen
                        Navigator.of(context).pop();
                      });
                  break;

                  // Handle Block/Unblock profile
                  case "block":
                    // Check remote user blocked status
                    if (_isRemoteUserBlocked != null && _isRemoteUserBlocked!) {
                      // Unblock profile
                      _unblockProfile();
                    } else {
                      // Unblock profile
                      _blockProfile();
                    }
                    break;

              }
              debugPrint("Selected action: $val");
            },
          ),
        ],
      ),
      body: Column(
        children: <Widget>[
          /// how message list
          Expanded(child: _showMessages()),

          /// Text Composer
          Container(
            color: Colors.grey.withAlpha(50),
            child: ListTile(
                leading: IconButton(
                    icon: const SvgIcon("assets/icons/camera_icon.svg",
                        width: 20, height: 20),
                    onPressed: () async {
                      /// Send image file
                      await _getImage();

                      /// Update scroll
                      _scrollMessageList();
                    }),
                title: TextField(
                  controller: _textController,
                  minLines: 1,
                  maxLines: 4,
                  decoration: InputDecoration(
                      hintText: _i18n.translate("type_a_message"),
                      border: InputBorder.none),
                  onChanged: (text) {
                    setState(() {
                      _isComposing = text.isNotEmpty;
                    });
                  },
                ),
                trailing: IconButton(
                    icon: Icon(Icons.send,
                        color: _isComposing
                            ? Theme.of(context).primaryColor
                            : Colors.grey),
                    onPressed: _isComposing
                        ? () async {
                            /// Get text
                            final text = _textController.text.trim();

                            /// clear input text
                            _textController.clear();
                            setState(() {
                              _isComposing = false;
                            });

                            /// Send text message
                            await _sendMessage(type: 'text', text: text);

                            /// Update scroll
                            _scrollMessageList();
                          }
                        : null)),
          ),
        ],
      ),
    );
  }

  /// Build bubble message
  Widget _showMessages() {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: _messages,
        builder: (context, snapshot) {
          // Check data
          if (!snapshot.hasData) {
            return const MyCircularProgress();
          } else {
            return ListView.builder(
                controller: _messagesController,
                reverse: true,
                itemCount: snapshot.data!.docs.length,
                itemBuilder: (context, index) {
                  // Get message list
                  final List<DocumentSnapshot<Map<String, dynamic>>> messages =
                      snapshot.data!.docs.reversed.toList();
                  // Get message doc map
                  final Map<String, dynamic> msg = messages[index].data()!;

                  /// Variables
                  bool isUserSender;
                  String userPhotoLink;
                  final bool isImage = msg[MESSAGE_TYPE] == 'image';
                  final String textMessage = msg[MESSAGE_TEXT];
                  final String? imageLink = msg[MESSAGE_IMG_LINK];
                  final String timeAgo =
                      timeago.format(msg[TIMESTAMP].toDate());

                  /// Check user id to get info
                  if (msg[USER_ID] == UserModel().user.userId) {
                    isUserSender = true;
                    userPhotoLink = UserModel().user.userProfilePhoto;
                  } else {
                    isUserSender = false;
                    userPhotoLink = widget.user.userProfilePhoto;
                  }
                  // Show chat bubble
                  return ChatMessage(
                    isUserSender: isUserSender,
                    isImage: isImage,
                    userPhotoLink: userPhotoLink,
                    textMessage: textMessage,
                    imageLink: imageLink,
                    timeAgo: timeAgo,
                  );
                });
          }
        });
  }
}
