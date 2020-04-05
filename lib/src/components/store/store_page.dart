import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:we_read/src/components/auth/auth_logic.dart';
import 'package:we_read/src/components/store/store_logic.dart';
import 'package:we_read/src/logic/style_logic.dart';
import 'package:we_read/src/widgets/scaffold.dart';
import 'package:we_read/src/widgets/text_widgets.dart';
import 'package:we_read/src/widgets/widget_lib.dart';

class StorePage extends StatelessWidget {
  final StyleLogic styleLogic;
  final AuthLogic authLogic;

  StorePage({this.styleLogic, this.authLogic})
      : assert(styleLogic != null),
        assert(authLogic != null);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<StyleLogic>(
          create: (_) => styleLogic,
        ),
        Provider<StoreLogic>(
          create: (_) => authLogic.storeLogic,
        ),
      ],
      child: Consumer<StoreLogic>(
        builder: (context, logic, _) {
          return WeReadScaffold(
            body: 
            // StoreErrorListener(
            //   errorStream: logic.storeError,
            //   child: 
              StreamBuilder<StoreState>(
                  stream: logic.storeState,
                  builder: (context, snapshot) {
                    if (!snapshot.hasData || snapshot.data is StoreLoading) {
                      return Center(
                        child: CircularProgressIndicator(),
                      );
                    }

                    if (snapshot.data is StoreUnavailable) {
                      return Center(
                        child: Column(
                          children: <Widget>[
                            ChapterTitle('Store Unavailable'),
                            WeReadButton(
                              text: 'Back',
                              onPressed: () => Navigator.pop(context),
                            )
                          ],
                        ),
                      );
                    }

                    StoreLoaded store = snapshot.data;

                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: <Widget>[
                          Paragraph('Store'),
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              MediumText('Bundles of &:'),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children:  <Widget>[
                                        WeReadButton(
                                          text: '3 &\n\$2.99',
                                          onPressed: logic.buyThree,
                                        ),
                                        WeReadButton(
                                          text: '12 &\n\$9.99',
                                          onPressed: logic.buyTwelve,
                                        )
                                      ],
                              ),
                            ],
                          ),
                          authLogic.userIsPro
                            ? Paragraph('Thank you for your support!') 
                            : Column(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              MediumText('Subscriptions:'),
                              Paragraph('Subscribe to unlock double daily & limit'),
                              AboutAmpersandButton(),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: <Widget>[
                                  Container(
                                    width:
                                        MediaQuery.of(context).size.width * .4,
                                    child: Center(
                                      child: WeReadButton(
                                        text:
                                            '${store.offering.monthly.product.title}\n${store.offering.monthly.product.priceString}',
                                        onPressed: logic.subscribeMonth,
                                      ),
                                    ),
                                  ),
                                  Container(
                                    width:
                                        MediaQuery.of(context).size.width * .4,
                                    child: Center(
                                      child: WeReadButton(
                                        text:
                                            '${store.offering.annual.product.title}\n${store.offering.annual.product.priceString}',
                                        onPressed: logic.subscribeYear,
                                      ),
                                    ),
                                  )
                                ],
                              ),
                              WeReadButton(
                                text: 'Restore Subscription',
                                onPressed: logic.restorePurchases,
                              ),
                            ],
                          ),
                          snapshot.data is PurchasePending
                              ? CircularProgressIndicator()
                              : WeReadButton(
                                  text: 'Back',
                                  onPressed: () => Navigator.pop(context),
                                )
                        ],
                      ),
                    );
                  }),
            // ),
          );
        },
      ),
    );
  }
}

class StoreErrorListener extends StatefulWidget {
  final Widget child;
  final Stream errorStream;

  StoreErrorListener({this.child, this.errorStream}) : assert(child != null);

  @override
  _StoreErrorListenerState createState() => _StoreErrorListenerState();
}

class _StoreErrorListenerState extends State<StoreErrorListener> {
  @override
  void initState() {
    super.initState();
    widget.errorStream
        .listen((error) => Scaffold.of(context).showSnackBar(SnackBar(
              content: Text('Store Error: $error'),
            )));
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
