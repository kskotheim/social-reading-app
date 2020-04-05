import 'dart:async';

import 'package:we_read/src/components/auth/auth_logic.dart';
import 'package:we_read/src/data/repo.dart';
import 'package:we_read/src/logic/bloc_base.dart';

class CurrencyIndicatorLogic implements BlocBase {
  final AuthLogic authLogic;
  String _userId;
  RepositoryManager repo = Repo.instance;
  double _ampersands;

  // listen to the user and send updates of bookmarks to the output stream
  CurrencyIndicatorLogic({this.authLogic}) {
    assert(authLogic != null);
    _userId = authLogic.token;
    if (_userId != null) {
      repo.getUser(_userId).listen((user) {
        if(_ampersands != null) {
          if(_ampersands < user.ampersands){
            _notifyOfIncrease();
          }
          if(_ampersands > user.ampersands){
            _notifyOfDecrease();
          }
        }
        _ampersands = user.ampersands;
        _updateCurrencyStream(user.ampersands);
      });
    }
  }

  // output stream
  StreamController<double> _currencyController = StreamController<double>();
  Stream<double> get currencyStream => _currencyController.stream;
  void _updateCurrencyStream(double amt) => _currencyController.isClosed ? null : _currencyController.sink.add(amt);

  // output stream 2 - notifications
  StreamController<CurrencyNotification> _currencyNotificationController = StreamController<CurrencyNotification>();
  Stream<CurrencyNotification> get currencyNotificationStream => _currencyNotificationController.stream;
  void _notifyOfIncrease() => _currencyNotificationController.isClosed ? null : _currencyNotificationController.sink.add(NotificationOfIncrease());
  void _notifyOfDecrease() => _currencyNotificationController.isClosed ? null : _currencyNotificationController.sink.add(NotificationOfDecrease());

  @override
  void dispose() {
    _currencyController.close();
    _currencyNotificationController.close();
  }
}


class CurrencyNotification{}

class NotificationOfIncrease extends CurrencyNotification {}

class NotificationOfDecrease extends CurrencyNotification {}