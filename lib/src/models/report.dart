import 'package:cloud_firestore/cloud_firestore.dart';

class Report {
  final String userId;
  final String reportedContent;
  final String reportingUserId;
  final String documentId;
  final String reportedUsername;
  final String reportingUsername;

  Report({this.userId, this.reportedContent, this.reportingUserId, this.documentId, this.reportedUsername, this.reportingUsername}){
    assert(userId != null);
    assert(reportedContent != null);
    assert(reportingUserId != null);
  }

  Map<String, dynamic> get toJSON => {_USERID: userId, _REPORTED_CONTENT: reportedContent, _REPORTING_USERID: reportingUserId, _REPORTED_USERNAME: reportedUsername, _REPORTING_USERNAME: reportingUsername};

  static Report fromDocumentSnapshot(DocumentSnapshot snapshot){
    return Report(userId: snapshot.data['UserId'], reportedContent: snapshot.data[_REPORTED_CONTENT], reportingUserId: snapshot.data[_REPORTING_USERID], documentId: snapshot.documentID, reportedUsername: snapshot.data[_REPORTED_USERNAME], reportingUsername: snapshot.data[_REPORTING_USERNAME]);
  }
  static const String _USERID = 'UserId';
  static const String _REPORTED_CONTENT = 'Reported Content';
  static const String _REPORTING_USERID = 'Reporting UserId';
  static const String _REPORTING_USERNAME = 'Reporting Username';
  static const String _REPORTED_USERNAME = 'Reported Username';

}