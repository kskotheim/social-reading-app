import 'package:cloud_firestore/cloud_firestore.dart';

class UserNotification{

  final String id;
  final String notification;
  final String fromUserId;

  UserNotification({this.id, this.notification, this.fromUserId});

  static UserNotification fromDocumentSnapshot(DocumentSnapshot snapshot){
    return UserNotification(fromUserId: snapshot.data[_FROM_USER_ID], notification: snapshot.data[_NOTIFICATION], id: snapshot.documentID);
  }

  Map<String, dynamic> get toJSON => {
    _FROM_USER_ID: fromUserId,
    _NOTIFICATION: notification,
  };

  static const String _FROM_USER_ID = 'From User Id';
  static const String _NOTIFICATION = 'Notification';

}