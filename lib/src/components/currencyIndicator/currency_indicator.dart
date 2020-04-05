import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:we_read/src/components/auth/auth_logic.dart';
import 'package:we_read/src/components/currencyIndicator/currency_indicator_logic.dart';
import 'package:we_read/src/widgets/text_widgets.dart';
import 'package:we_read/src/widgets/widget_lib.dart';

class CurrencyIndicator extends StatelessWidget {
  final Executor executor;

  CurrencyIndicator({this.executor});

  @override
  Widget build(BuildContext context) {
    return Provider<CurrencyIndicatorLogic>(
      create: (_) =>
          CurrencyIndicatorLogic(authLogic: Provider.of<AuthLogic>(context, listen: false)),
      dispose: (_, logic) => logic.dispose(),
      child: Align(
        alignment: Alignment.topLeft,
        child: Consumer<CurrencyIndicatorLogic>(
          builder: (context, logic, _) {
            return StreamBuilder<double>(
              stream: logic.currencyStream,
              builder: (context, snapshot) {
                return CurrencyStreamListener(
                  notificationStream: logic.currencyNotificationStream,
                  executor: executor,
                  child: Padding(
                    padding: const EdgeInsets.all(2.0),
                    child: BorderContainer(
                      child: InfoText('&: ${snapshot.data}'),
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}

class CurrencyStreamListener extends StatefulWidget {
  final Stream<CurrencyNotification> notificationStream;
  final Widget child;
  final Executor executor;
  CurrencyStreamListener({this.notificationStream, this.child, this.executor});

  @override
  _CurrencyStreamListenerState createState() => _CurrencyStreamListenerState();
}

class _CurrencyStreamListenerState extends State<CurrencyStreamListener> {
  @override
  void initState() {
    widget.notificationStream.listen((CurrencyNotification data) {
      if (data is NotificationOfIncrease) {
        Scaffold.of(context).showSnackBar(
          SnackBar(
            duration: Duration(seconds: 1),
            content: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text('Earned &'),
              ],
            ),
          ),
        );
      }
      if (data is NotificationOfDecrease) {
        Scaffold.of(context).showSnackBar(
          SnackBar(
            duration: Duration(seconds: 1),
            content: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text('Deducted &'),
              ],
            ),
          ),
        );
      }
    });

    if(widget.executor != null){
      widget.executor.addFunction(() => Scaffold.of(context).hideCurrentSnackBar());
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}

class Executor {
  List<Function> _functionsToRun = [];

  void addFunction(Function f){
    _functionsToRun.add(f);
  }

  void runFunctions(){
    _functionsToRun.forEach((f) => f());
  }
}
