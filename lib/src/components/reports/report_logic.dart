import 'dart:async';

import 'package:rxdart/rxdart.dart';
import 'package:we_read/src/components/auth/auth_logic.dart';
import 'package:we_read/src/components/auth/user.dart';
import 'package:we_read/src/data/repo.dart';
import 'package:we_read/src/logic/bloc_base.dart';
import 'package:we_read/src/models/report.dart';

class ReportLogic implements BlocBase {
  final AuthLogic authLogic;
  final User reportedUser;
  final RepositoryManager repo = Repo.instance;

  bool _reportForComments = false;
  bool _reportForUsername = false;

  // stream for 'report for comments' option
  BehaviorSubject<bool> _reportForCommentsOptionController = BehaviorSubject();
  Stream<bool> get reportForCommentsOption =>
      _reportForCommentsOptionController.stream;
  void setReportForCommentsOption(bool val) {
    _reportForComments = val;
    _reportForCommentsOptionController.sink.add(val);
  }

  // stream for 'report for username' option
  BehaviorSubject<bool> _reportForUsernameOptionController = BehaviorSubject();
  Stream<bool> get reportForUsernameOption =>
      _reportForUsernameOptionController.stream;
  void setReportForUsernameOption(bool val) {
    _reportForUsername = val;
    _reportForUsernameOptionController.sink.add(val);
  }

  // input stream
  StreamController<ReportEvent> _reportController =
      StreamController<ReportEvent>();
  void submitReport() => _reportController.sink.add(ReportSubmitted());

  // // Stream for whether to show text field or options
  // StreamController<ReportOptions> _reportOptionController =
  //     StreamController<ReportOptions>();
  // Stream<ReportOptions> get reportOptions => _reportOptionController.stream;
  // void showReportTextField() =>
  //     _reportOptionController.sink.add(ReportOptions.text);
  // void showReportRadioButtons() =>
  //     _reportOptionController.sink.add(ReportOptions.radio);

  // stream for report field
  String _report;
  BehaviorSubject<String> _reportFieldController = BehaviorSubject<String>();
  Stream<String> get reportField => _reportFieldController.stream;
  void reportFieldChanged(String field) {
    _report = field;
    _reportFieldController.sink.add(field);
  }

  ReportLogic({this.reportedUser, this.authLogic}) {
    assert(authLogic != null);
    assert(reportedUser != null);
    // showReportRadioButtons();
    _reportController.stream.listen(_mapEventToState);
  }

  void _mapEventToState(ReportEvent event) {
    if (event is ReportSubmitted) {
      String reportedContent = '';

      if (_report != null && _report.length > 0) {
        reportedContent += "Report: $_report; ";
      }
      if (_reportForComments) {
        reportedContent += "Reported for Comments; ";
      }
      if (_reportForUsername) {
        reportedContent += 'Reported for Username; ';
      }
      if (reportedContent.length > 0) {
        Report report = Report(
            reportingUserId: authLogic.token,
            reportedContent: reportedContent,
            userId: reportedUser.userId,
            reportingUsername: authLogic.username,
            reportedUsername: reportedUser.userName);
        repo.createReport(report);
      }
    }
  }

  @override
  void dispose() {
    _reportController.close();
    _reportFieldController.close();
    // _reportOptionController.close();
    _reportForCommentsOptionController.close();
    _reportForUsernameOptionController.close();
  }
}

class ReportEvent {}

class ReportSubmitted extends ReportEvent {}

class ReportState {}

enum ReportOptions { text, radio }
