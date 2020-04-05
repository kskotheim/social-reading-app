import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:we_read/src/components/auth/auth_logic.dart';
import 'package:we_read/src/components/auth/user.dart';
import 'package:we_read/src/components/reports/report_logic.dart';
import 'package:we_read/src/logic/style_logic.dart';
import 'package:we_read/src/widgets/form_widgets.dart';
import 'package:we_read/src/widgets/widget_lib.dart';

class ReportDialog extends StatelessWidget {
  final User reportedUser;
  final AuthLogic authLogic;
  final StyleLogic styleLogic;
  ReportDialog({this.reportedUser, this.authLogic, this.styleLogic});
  @override
  Widget build(BuildContext context) {
    return Provider(
      create: (_) => styleLogic,
      child: Provider(
        create: (_) =>
            ReportLogic(reportedUser: reportedUser, authLogic: authLogic),
        dispose: (_, logic) => logic.dispose(),
        child: Consumer<ReportLogic>(
          builder: (context, logic, child) {
            ReportLogic reportLogic = Provider.of<ReportLogic>(context);
            return WeReadDialog(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  ChapterTitle('Report User'),
                  Paragraph('What are you reporting this user for?'),
                  // Row(
                  //   mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  //   children: <Widget>[
                  //     WeReadIconButton(
                  //       icon: 'list',
                  //       onPressed: logic.showReportRadioButtons,
                  //     ),
                  //     WeReadIconButton(
                  //       icon: 'text',
                  //       onPressed: logic.showReportTextField,
                  //     )
                  //   ],
                  // ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          StreamBuilder<bool>(
                              stream: logic.reportForCommentsOption,
                              builder: (context, snapshot) {
                                return Checkbox(
                                  value: snapshot.data ?? false,
                                  onChanged: logic.setReportForCommentsOption,
                                );
                              }),
                          Paragraph('Comments')
                        ],
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          StreamBuilder<bool>(
                              stream: logic.reportForUsernameOption,
                              builder: (context, snapshot) {
                                return Checkbox(
                                  value: snapshot.data ?? false,
                                  onChanged: logic.setReportForUsernameOption,
                                );
                              }),
                          Paragraph('Username'),
                        ],
                      ),
                      StreamTextField(
                        stream: reportLogic.reportField,
                        onChanged: reportLogic.reportFieldChanged,
                        hint: '(optional)',
                      ),
                    ],
                  ),

                  WeReadButton(
                    text: 'Submit',
                    onPressed: () {
                      reportLogic.submitReport();
                      Navigator.pop(context);
                    },
                  ),
                  WeReadButton(
                    text: 'Cancel',
                    onPressed: () => Navigator.pop(context),
                  )
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
