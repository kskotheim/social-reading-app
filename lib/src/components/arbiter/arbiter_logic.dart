import 'dart:async';

import 'package:we_read/src/data/repo.dart';
import 'package:we_read/src/logic/bloc_base.dart';
import 'package:we_read/src/models/report.dart';

class ArbiterLogic implements BlocBase{
  final RepositoryManager repo = Repo.instance;
  bool loading = true;


  // input stream
  StreamController<ArbiterEvent> _eventController = StreamController<ArbiterEvent>();
  // void _reportsLoaded(List<Report> reports) => _eventController.sink.add(ReportsLoaded(reports));

  // reports stream
  StreamController<List<Report>> _reportStreamController = StreamController<List<Report>>();
  void _reportsLoaded(List<Report> reports) => _reportStreamController.sink.add(reports);
  Stream<List<Report>> get reportStream => _reportStreamController.stream;

  // output stream
  StreamController<ArbiterState> _stateController = StreamController<ArbiterState>();
  Stream<ArbiterState> get arbiterStateStream => _stateController.stream;

  ArbiterLogic(){
    _eventController.stream.listen(_mapEventToState);
    repo.reportStream().listen((reports) {
      _reportsLoaded(reports);
    });
  }

  void _mapEventToState(ArbiterEvent event){
    // if(event is ReportsLoaded){
    //   _showReports(event.reports);
    // }
  }

  void deleteReport(String reportId) {
    repo.deleteReport(reportId);
  }


  @override
  void dispose() {
    _eventController.close();
    _stateController.close();
    _reportStreamController.close();
  }

}

class ArbiterEvent {}


class ArbiterState{}

