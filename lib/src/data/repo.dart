import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:we_read/src/components/auth/user.dart';
import 'package:we_read/src/data/db.dart';
import 'package:we_read/src/models/comment.dart';
import 'package:we_read/src/models/notification.dart';
import 'package:we_read/src/models/report.dart';

abstract class RepositoryManager {
  Future<void> createComment(Comment comment, bool toBeModerated);
  Future<List<Comment>> getComments(
      String book, int chapter, int paragraph, bool recent, int count);
  Stream<List<Comment>> getUserComments(String userId);
  Future<List<Comment>> userComments(String userId);
  Future<void> deleteComment(String commentId);

  Stream<User> getUser(String userId);
  Future<User> getSingleUser(String userId);
  Future<String> getUsername(String userId);
  Future<void> updateUser(String userId, Map<String, dynamic> data);
  Future<void> incrementAmpersands(String user, double increment);
  Future<void> upvoteComment(String commentId);
  Future<Comment> getPostToBeApproved();
  Future<void> approveComment(Comment comment);
  Future<void> disapproveComment(String commentId);
  Future<void> updateCommentReviewStatus(String commentId, bool underReview);
  Future<void> notifyUser(String userId, UserNotification notification);
  Stream<List<UserNotification>> userNotificationStream(String userId);
  Future<void> deleteUserNotification(String userId, String notificationId);

  Future<void> resetUsername(String token);
  // Future<void> nukeUser(String token);
  Future<void> createReport(Report report);
  Stream<List<Report>> reportStream();
  Future<void> deleteReport(String reportId);


}

class Repo implements RepositoryManager {
  static Repo _instance = Repo();
  static Repo get instance => _instance;

  DatabaseManager db = DB();

  Future<void> createComment(Comment comment, bool toBeModerated) {
    if(toBeModerated){
      return db.createCommentToBeModerated(comment);
    } else {
      return db.createComment(comment);
    }
  }

  Future<List<Comment>> getComments(String book, int chapter, int paragraph, bool recent, int count) async {
    List<DocumentSnapshot> docs = await db.getComments(book, chapter, paragraph, recent, count);
    List<String> usernames = await Future.wait(docs.map((mark) async => await getUsername(mark.data[DB.CREATED_BY])));
    List<Comment> comments =List<Comment>.from(docs.map(Comment.fromDocumentSnapshot));
    int i = 0;
    comments.forEach(
      (comment) {
        comment.username = usernames[i];
        i++;
      },
    );
    return comments;
  }

  Stream<List<Comment>> getUserComments(String userId){
    return db.getUserComments(userId).map((documents) => documents.map(Comment.fromDocumentSnapshot).toList());
  }

  Future<List<Comment>> userComments(String userId) async {    
    List<DocumentSnapshot> docs = await db.userComments(userId);
    String username = await getUsername(userId);
    List<Comment> comments =List<Comment>.from(docs.map(Comment.fromDocumentSnapshot));
    comments.forEach(
      (comment) => comment.username = username,
    );
    return comments;
  }

  Future<void> deleteComment(String commentId){
    return db.deleteComment(commentId);
  }

  Stream<User> getUser(String userId) {
    return db.getUserStream(userId).map(
          User.fromDocumentSnapshot,
        );
  }

  Future<User> getSingleUser(String userId){
    return db.getUser(userId).then(User.fromDocumentSnapshot);
  }

  Future<String> getUsername(String userId) {
    return db.getUser(userId).then((document) {
      if(document.exists){
        return document.data[DB.NAME] ?? 'no-name';
      } else return 'no-user';
    });
  }

  Future<void> updateUser(String userId, Map<String, dynamic> data) {
    return db.updateUser(userId, data);
  }

  Future<void> incrementAmpersands(String userId, double increment) async {
    if(userId != null){
      Map<String, dynamic> userData = await db.getUser(userId).then((document) => document.data);
      double newAmpersands = (userData[DB.AMPERSANDS] ?? 0) + increment;
      return db.updateUser(userId, {DB.AMPERSANDS: newAmpersands});
    } else return Future.delayed(Duration(seconds: 0));

  }

  Future<void> upvoteComment(String commentId) async {
    int votes = await db.getComment(commentId).then((data) => data[DB.VOTES] ?? 0);
    return db.updateComment(commentId, {DB.VOTES: votes + 1});
  }

  Future<Comment> getPostToBeApproved() async {
    DocumentSnapshot comment = await db.getCommentToBeModerated();
    if(comment == null) return null;
    db.updateCommentToBeModerated(comment.documentID, {DB.UNDER_REVIEW: DateTime.now().millisecondsSinceEpoch});
    return Comment.fromDocumentSnapshot(comment);
  }

  Future<void> approveComment(Comment comment) async {
    return Future.wait(
      [
        db.deleteCommentToBeModerated(comment.id),
        db.createComment(comment),
      ]
    );
  }

  Future<void> disapproveComment(String commentId) async {
    return db.deleteCommentToBeModerated(commentId);
  }
  Future<void> updateCommentReviewStatus(String commentId, bool underReview) {
    return db.updateCommentToBeModerated(commentId, {DB.UNDER_REVIEW: underReview});
  }

  Future<void> notifyUser(String userId, UserNotification notification){
    return db.createUserNotification(userId, notification);
  }

  Stream<List<UserNotification>> userNotificationStream(String userId) {
    return db.userNotificationStream(userId).map((list) => list.map(UserNotification.fromDocumentSnapshot).toList());
  }
  Future<void> deleteUserNotification(String userId, String notificationId){
    return db.deleteNotification(userId, notificationId);
  }

  Future<void> resetUsername(String token){
    return db.updateUser(token, {DB.NAME: null});
  }

  // Future<void> nukeUser(String token) async {
    // List<Comment> usersComments = await getUserComments(token);
    // Future.wait(usersComments.map((comment) => db.deleteComment(comment.id)));
    // return db.deleteUser(token);
  // }  

  Future<void> createReport(Report report){
    return db.createReport(report);
  }

  Stream<List<Report>> reportStream() {
    return db.reportStream().map((documents) => documents.map(Report.fromDocumentSnapshot).toList());
  }

  Future<void> deleteReport(String reportId){
    return db.deleteReport(reportId);
  }
}
