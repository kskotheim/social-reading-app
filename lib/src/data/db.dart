import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:we_read/src/components/auth/user.dart';
import 'package:we_read/src/models/comment.dart';
import 'package:we_read/src/models/notification.dart';
import 'package:we_read/src/models/report.dart';

abstract class DatabaseManager {
  Future<void> createUser(String userId);
  Future<DocumentSnapshot> getUser(String userId);
  Stream<DocumentSnapshot> getUserStream(String userId);
  Future<void> updateUser(String userId, Map<String, dynamic> data);
  Future<void> deleteUser(String userId);

  Future<void> createComment(Comment comment);
  Future<Map<String, dynamic>> getComment(String bookmarkId);
  Future<List<DocumentSnapshot>> getComments(
      String book, int chapter, int paragraph, bool recent, int count);
  Stream<List<DocumentSnapshot>> getUserComments(String userId);
  Future<List<DocumentSnapshot>> userComments(String userId);
  Future<void> updateComment(String bookmarkId, Map<String, dynamic> data);
  Future<void> deleteComment(String bookmarkId);

  Future<void> createCommentToBeModerated(Comment comment);
  Stream<List<DocumentSnapshot>> commentsToBeModerated();
  Future<DocumentSnapshot> getCommentToBeModerated();
  Future<void> updateCommentToBeModerated(String commentToBeModeratedId, Map<String, dynamic> data);
  Future<void> deleteCommentToBeModerated(String commentToBeModeratedId);

  Future<void> createUserNotification(String userId, UserNotification notification);
  Stream<List<DocumentSnapshot>> userNotificationStream(String userId);
  Future<void> deleteNotification(String userId, String notificationId);

  Future<void> createReport(Report report);
  Stream<List<DocumentSnapshot>> reportStream();
  Future<void> updateReport(String reportId, Map<String, dynamic> data);
  Future<void> deleteReport(String reportId);

  // Future<void> createComment(String userId, String bookmarkId, String comment);
  // Future<Map<String, dynamic>> getComment(String commentId);
  // Future<void> updateComment(String commentId, Map<String, dynamic> data);
  // Future<void> deleteComment(String commentId);
}

class DB implements DatabaseManager {
  static final DB _instance = DB();
  static DB get instance => _instance;

  Firestore db = Firestore.instance;

  CollectionReference get commentsCollection => db.collection('Bookmarks');
  CollectionReference get commentsToBeModeratedCollection => db.collection('BookmarksToBeModerated');
  CollectionReference userNotificationCollection(String userId) => userDoc(userId).collection('Notifications');
  CollectionReference get reportsCollection => db.collection('Reports');
  DocumentReference commentsDoc(String bookmarkId) =>
      commentsCollection.document(bookmarkId);
  DocumentReference userDoc(String userId) =>
      db.collection(USERS).document(userId);
  DocumentReference commentToBeModeratedDoc(String commentId) =>
      commentsToBeModeratedCollection.document(commentId);
  DocumentReference userNotificationDoc(String userId, String notificationId) => 
      userNotificationCollection(userId).document(notificationId);
  DocumentReference reportsDoc(String documentId) => reportsCollection.document(documentId);


  // **** User methods ****

  Future<void> createUser(String userId) {
    return userDoc(userId)
        .setData({CREATED_AT: DateTime.now().millisecondsSinceEpoch, AMPERSANDS: 3.0, PERMISSION: User.PERMISSION_ONE, POSTS_APPROVED: 0});
  }

  Future<DocumentSnapshot> getUser(String userId) {
    return userDoc(userId).get();
  }

  Stream<DocumentSnapshot> getUserStream(String userId){
    return userDoc(userId).snapshots();
  }

  Future<void> updateUser(String userId, Map<String, dynamic> data) {
    return userDoc(userId).updateData(data);
  }

  Future<void> deleteUser(String userId) {
    return userDoc(userId).delete();
  }

  // **** Bookmark methods ****

  Future<void> createComment(Comment comment) {
    return commentsCollection.document().setData(
      {
        CREATED_BY: comment.userId,
        BOOK: comment.book,
        CHAPTER: comment.chapter,
        PARAGRAPH: comment.paragraph,
        TEXT: comment.text,
        CREATED_AT: DateTime.now().millisecondsSinceEpoch,
        TAGS: comment.tags,
        MODERATOR: comment.moderatorId
      },
    );
  }

  Future<Map<String, dynamic>> getComment(String bookmarkId) {
    return commentsDoc(bookmarkId).get().then((document) => document.data);
  }

  Future<List<DocumentSnapshot>> getComments(
      String book, int chapter, int paragraph, bool recent, int count) {
        
    if(chapter == -1){
      return commentsCollection
        .where(BOOK, isEqualTo: book)
        .orderBy(recent ? CREATED_AT : VOTES, descending: true)
        .limit(count)
        .getDocuments()
        .then((query) => query.documents);
    }
    // if(paragraph == -1){
    //   return commentsCollection
    //     .where(BOOK, isEqualTo: book)
    //     .where(CHAPTER, isEqualTo: chapter)
    //     .orderBy(recent ? CREATED_AT : VOTES, descending: recent ? true : false)
    //     .limit(count)
    //     .getDocuments()
    //     .then((query) => query.documents);
    // }

    return commentsCollection
        .where(BOOK, isEqualTo: book)
        .where(CHAPTER, isEqualTo: chapter)
        .where(PARAGRAPH, isEqualTo: paragraph)
        .orderBy(recent ? CREATED_AT : VOTES, descending: true)
        .limit(count)
        .getDocuments()
        .then((query) => query.documents);
  }

  Stream<List<DocumentSnapshot>> getUserComments(String userId){
    return commentsCollection.where(CREATED_BY, isEqualTo: userId).snapshots().map((query) => query.documents);
  }

  Future<List<DocumentSnapshot>> userComments(String userId){
    return commentsCollection.where(CREATED_BY, isEqualTo: userId).getDocuments().then((query) => query.documents);
  }

  Future<void> updateComment(String bookmarkId, Map<String, dynamic> data) {
    return commentsDoc(bookmarkId).updateData(data);
  }

  Future<void> deleteComment(String bookmarkId) {
    return commentsDoc(bookmarkId).delete();
  }

  Future<void> createCommentToBeModerated(Comment comment){
    return commentsToBeModeratedCollection.document().setData(
      {
        CREATED_BY: comment.userId,
        BOOK: comment.book,
        CHAPTER: comment.chapter,
        PARAGRAPH: comment.paragraph,
        TEXT: comment.text,
        CREATED_AT: DateTime.now().millisecondsSinceEpoch,
        TAGS: comment.tags,
        UNDER_REVIEW: 0
      }
    );
  }

  Stream<List<DocumentSnapshot>> commentsToBeModerated(){
    return commentsToBeModeratedCollection.snapshots().map((query) => query.documents); 
    // Avery / Jared 
  }

  Future<DocumentSnapshot> getCommentToBeModerated() {
    // get a single comment that has not been opened by a moderator in the past 5 minutes
    return commentsToBeModeratedCollection.where(UNDER_REVIEW, isLessThan: DateTime.now().millisecondsSinceEpoch - 300000).limit(1).getDocuments().then((query) {
      if(query.documents.length > 0) {
        return query.documents[0];
      }
      else return null;
    });
  }

  Future<void> updateCommentToBeModerated(String commentId, Map<String, dynamic> data){
    return commentToBeModeratedDoc(commentId).updateData(data);
  }

  Future<void> deleteCommentToBeModerated(String commentId){
    return commentToBeModeratedDoc(commentId).delete();
  }


  Future<void> createUserNotification(String userId, UserNotification notification){
    return userNotificationCollection(userId).document().setData(notification.toJSON);
  }
  Stream<List<DocumentSnapshot>> userNotificationStream(String userId){
    return userNotificationCollection(userId).snapshots().map((query) => query.documents);
  }
  Future<void> deleteNotification(String userId, String notificationId){
    return userNotificationDoc(userId, notificationId).delete();
  }

  Future<void> createReport(Report report){
    return reportsCollection.document().setData(report.toJSON);
  }

  Stream<List<DocumentSnapshot>> reportStream(){
    return reportsCollection.snapshots().map((list) => list.documents);
  }

  Future<void> updateReport(String reportId, Map<String, dynamic> data){
    return reportsDoc(reportId).updateData(data);
  }

  Future<void> deleteReport(String reportId){
    return reportsDoc(reportId).delete();
  }

  // **** Comment methods ****

  // Future<void> createComment(String userId, String bookmarkId, String comment) {

  //   return commentsCollection.document().setData(
  //     {
  //       CREATED_BY: userId,
  //       BOOKMARK: bookmarkId,
  //       TEXT: comment,
  //     }
  //   );

  // }

  // Future<Map<String, dynamic>> getComment(String commentId) {
  //   return commentDoc(commentId).get().then((document) => document.data);
  // }

  // Future<void> updateComment(String commentId, Map<String, dynamic> data) {
  //   return commentDoc(commentId).updateData(data);
  // }

  // Future<void> deleteComment(String commentId) {
  //   return commentDoc(commentId).delete();
  // }

  static const String USERS = 'Users';
  static const String NAME = 'Name';
  static const String AMPERSANDS = 'Ampersands';
  static const String PERMISSION = 'Permission';
  static const String POSTS_APPROVED = 'Posts Approved';
  static const String BOOKMARK = 'Bookmark';
  static const String BOOK = 'Book';
  static const String PARAGRAPH = 'Paragraph';
  static const String CHAPTER = 'Chapter';
  static const String UNDER_REVIEW = 'Under Review';
  static const String COMMENTS = 'Comments';
  static const String TEXT = 'Text';
  static const String TAGS = 'Tags';
  static const String VOTES = 'Votes';
  static const String CREATED_AT = 'CreatedAt';
  static const String CREATED_BY = 'CreatedBy';
  static const String MODERATOR = 'Moderator';
}
