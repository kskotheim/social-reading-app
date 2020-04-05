import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:we_read/src/components/arbiter/arbiter_logic.dart';
import 'package:we_read/src/components/auth/auth_logic.dart';
import 'package:we_read/src/components/profile/other_user_profile.dart';
import 'package:we_read/src/logic/main_logic.dart';
import 'package:we_read/src/logic/style_logic.dart';
import 'package:we_read/src/models/report.dart';
import 'package:we_read/src/widgets/widget_lib.dart';

class ArbiterPage extends StatelessWidget {
  final StyleLogic styleLogic;
  final AuthLogic authLogic;
  final MainLogic mainLogic;

  ArbiterPage({this.styleLogic, this.authLogic, this.mainLogic}) {
    assert(authLogic != null, styleLogic != null);
    assert(mainLogic != null);
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<StyleLogic>(
          create: (_) => styleLogic,
        ),
        Provider<AuthLogic>(
          create: (_) => authLogic,
        ),
        Provider<ArbiterLogic>(
          create: (_) => ArbiterLogic(),
          dispose: (_, logic) => logic.dispose(),
        ),
      ],
      child: Consumer<ArbiterLogic>(
        builder: (context, logic, _) {
          return WeReadScaffold(
            body: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  BookTitle('Report Page'),
                  StreamBuilder<List<Report>>(
                      stream: logic.reportStream,
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) {
                          return Center(
                            child: CircularProgressIndicator(),
                          );
                        }
                        if (snapshot.hasData) {
                          List<Report> reports = snapshot.data;
                          if (reports.length == 0) {
                            return ChapterTitle('No Reports');
                          }
                          return Column(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: <Widget>[
                                  Paragraph('Reported  /  Reporting'),
                                  HorizontalSpace(20.0),
                                ],
                              ),
                              Column(
                                mainAxisSize: MainAxisSize.min,
                                children: reports
                                    .map(
                                      (report) => ListTile(
                                        leading: WeReadIconButton(
                                          icon: 'delete',
                                          onPressed: () => logic
                                              .deleteReport(report.documentId),
                                        ),
                                        trailing: Container(
                                          width: MediaQuery.of(context).size.width * .3,
                                          child: SingleChildScrollView(
                                            scrollDirection: Axis.horizontal,
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: <Widget>[
                                                WeReadButton(
                                                  text: report.reportedUsername ??
                                                      'unk',
                                                  onPressed: () => Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                          builder: (_) =>
                                                              OtherUserProfile(
                                                                report.userId,
                                                                authLogic:
                                                                    authLogic,
                                                                styleLogic:
                                                                    styleLogic,
                                                                mainLogic: mainLogic,
                                                              ))),
                                                ),
                                                WeReadButton(
                                                  text: report.reportingUsername ??
                                                      'unk',
                                                  onPressed: () => Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                          builder: (_) =>
                                                              OtherUserProfile(
                                                                report
                                                                    .reportingUserId,
                                                                authLogic:
                                                                    authLogic,
                                                                styleLogic:
                                                                    styleLogic,
                                                                mainLogic: mainLogic,
                                                              ))),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                        title:
                                            Paragraph(report.reportedContent),
                                      ),
                                    )
                                    .toList(),
                              ),
                            ],
                          );
                        }
                      }),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
