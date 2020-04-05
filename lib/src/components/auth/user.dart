import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:we_read/src/data/db.dart';

class User {
  final String userId;
  final String userName;
  final num ampersands;
  final int postsApproved;
  final String permissionLevel;
  // this is set after subscription information is retrieved
  bool isPro = false;

  static const String PERMISSION_ONE = 'Initiate';
  static const String PERMISSION_TWO = 'Moderator';
  static const String PERMISSION_THREE = 'Arbiter';

  User({this.userId, this.userName, this.ampersands, this.permissionLevel = PERMISSION_ONE, this.postsApproved}) : assert(userId != null);

  // User.fromFirebaseUser(FirebaseUser user) : userId = user.uid;

  static User fromDocumentSnapshot(DocumentSnapshot document) {
    return User(
      userId: document.documentID,
      ampersands: document?.data[DB.AMPERSANDS] ?? 0.0,
      userName: document?.data[DB.NAME],
      permissionLevel: document?.data[DB.PERMISSION] ?? PERMISSION_ONE,
      postsApproved: document?.data[DB.POSTS_APPROVED],
    );
  }
}
